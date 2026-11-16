-- Puntos de recarga de coches eléctricos e híbridos enchufables (app 1.0.7).
--
-- La Edge Function charging-sync descarga una vez al día los puntos de
-- Canarias de Open Charge Map (licencia CC BY 4.0, hay que citarlo en la app)
-- y los guarda aquí. La app solo lee esta tabla, así la clave de Open Charge
-- Map no va dentro de la app.
--
-- Antes de la parte 2 hay que tener:
--   - el secreto OCM_API_KEY en las Edge Functions (supabase secrets set)
--   - la función desplegada: supabase functions deploy charging-sync --no-verify-jwt
-- Usa el mismo secreto del cron que price-alerts (price_alerts_cron_secret).
-- Se puede ejecutar más de una vez.

-- 1. Tabla -------------------------------------------------------------------

create table if not exists public.charging_points (
  id           integer primary key,          -- ID de Open Charge Map
  name         text not null,
  operator     text,
  address      text,
  town         text,
  postcode     text,
  latitude     double precision not null,
  longitude    double precision not null,
  -- [{"type": "ccs", "label": "CCS (Type 2)", "kw": 50, "quantity": 2}, ...]
  connectors   jsonb not null default '[]'::jsonb,
  max_kw       numeric(6, 1),
  points       integer,
  -- operational, not_operational o unknown
  status       text not null default 'unknown',
  -- Precio leído del texto de la comunidad; null si no se entiende.
  price_kwh    numeric(5, 3),
  free         boolean not null default false,
  usage_cost   text,                         -- texto original del precio
  ocm_updated  timestamptz,                  -- última revisión en Open Charge Map
  synced_at    timestamptz not null default now()
);

create index if not exists charging_points_lat_lon_idx
  on public.charging_points (latitude, longitude);

-- Lectura pública (como los precios de las gasolineras); escritura solo la
-- función, que usa la service role.
alter table public.charging_points enable row level security;
drop policy if exists "Puntos de recarga visibles" on public.charging_points;
create policy "Puntos de recarga visibles" on public.charging_points
  for select to anon, authenticated using (true);
revoke insert, update, delete on public.charging_points from anon, authenticated;

-- 2. Descarga diaria -----------------------------------------------------------

create extension if not exists pg_cron;
create extension if not exists pg_net;

select cron.unschedule('charging-sync')
where exists (select 1 from cron.job where jobname = 'charging-sync');

-- Cada día a las 04:20 (UTC).
select cron.schedule(
  'charging-sync',
  '20 4 * * *',
  $$
  select net.http_post(
    url := 'https://dhfemojxqsfrfnedhede.supabase.co/functions/v1/charging-sync',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'x-cron-secret', (
        select decrypted_secret from vault.decrypted_secrets
        where name = 'price_alerts_cron_secret'
      )
    ),
    body := '{}'::jsonb,
    timeout_milliseconds := 120000
  );
  $$
);
