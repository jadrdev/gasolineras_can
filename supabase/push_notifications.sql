-- Notificaciones push de bajada de precio (1.0.5).
--
-- Se ejecuta en Supabase (SQL Editor o `supabase db query --remote -f`).
-- Se puede ejecutar más de una vez.
--
-- Piezas:
--   push_tokens              token FCM de cada dispositivo con sesión.
--   station_price_snapshots  último precio visto de cada gasolinera y
--                            combustible; la función price-alerts compara
--                            con él para saber si ha bajado.
--   register/unregister      la app solo toca push_tokens por estas funciones.
--   cron                     cada hora llama a la Edge Function price-alerts.

-- 1. Tokens de dispositivo -------------------------------------------------

create table if not exists public.push_tokens (
  token      text primary key,
  user_id    uuid not null references auth.users (id) on delete cascade,
  platform   text not null check (platform in ('ios', 'android')),
  updated_at timestamptz not null default now()
);
create index if not exists push_tokens_user_id_idx on public.push_tokens (user_id);

-- Sin políticas: la app no lee ni escribe la tabla directamente.
alter table public.push_tokens enable row level security;
revoke all on public.push_tokens from anon, authenticated;

-- Un mismo dispositivo puede cambiar de cuenta: el token pasa al usuario
-- que lo registra ahora.
create or replace function public.register_push_token(p_token text, p_platform text)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if auth.uid() is null then
    raise exception 'No hay usuario autenticado';
  end if;
  insert into public.push_tokens (token, user_id, platform, updated_at)
  values (p_token, auth.uid(), p_platform, now())
  on conflict (token) do update
    set user_id = excluded.user_id,
        platform = excluded.platform,
        updated_at = now();
end;
$$;

create or replace function public.unregister_push_token(p_token text)
returns void
language sql
security definer
set search_path = ''
as $$
  delete from public.push_tokens
  where token = p_token and user_id = auth.uid();
$$;

revoke all on function public.register_push_token(text, text) from public, anon;
revoke all on function public.unregister_push_token(text) from public, anon;
grant execute on function public.register_push_token(text, text) to authenticated;
grant execute on function public.unregister_push_token(text) to authenticated;

-- 2. Último precio visto ---------------------------------------------------

create table if not exists public.station_price_snapshots (
  station_id integer not null,
  fuel       text    not null,
  price      numeric(6, 3) not null,
  updated_at timestamptz not null default now(),
  primary key (station_id, fuel)
);

alter table public.station_price_snapshots enable row level security;
revoke all on public.station_price_snapshots from anon, authenticated;

-- 3. Ejecución cada hora ---------------------------------------------------
-- La Edge Function comprueba la cabecera x-cron-secret contra su secreto
-- CRON_SECRET; aquí se lee del Vault para no dejarlo escrito en cron.job.
-- Antes de esta parte hay que crear el secreto en el Vault con el mismo valor:
--   select vault.create_secret('<valor>', 'price_alerts_cron_secret');

create extension if not exists pg_cron;
create extension if not exists pg_net;

select cron.unschedule('price-alerts')
where exists (select 1 from cron.job where jobname = 'price-alerts');

select cron.schedule(
  'price-alerts',
  '7 * * * *',
  $$
  select net.http_post(
    url := 'https://dhfemojxqsfrfnedhede.supabase.co/functions/v1/price-alerts',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'x-cron-secret', (
        select decrypted_secret from vault.decrypted_secrets
        where name = 'price_alerts_cron_secret'
      )
    ),
    body := '{}'::jsonb,
    timeout_milliseconds := 60000
  );
  $$
);
