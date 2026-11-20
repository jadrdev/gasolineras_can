-- Puntos de recarga con mapaREVE (Red Eléctrica) + Open Charge Map (app 1.0.10).
--
-- La Edge Function charging-stations junta cada 15 minutos en charging_stations:
--   - las ubicaciones de mapaREVE: estado de cada cargador en tiempo real y
--     precio publicado por el operador, con IVA, en la franja de esa hora
--     (cada 15 min son 4 peticiones por consulta y hora; el límite es 5);
--   - los puntos de Open Charge Map (tabla charging_points, que charging-sync
--     sigue cargando una vez al día) que no coinciden con ninguno de REVE.
-- La app 1.0.10 lee esta tabla; las anteriores siguen con charging_points,
-- que no cambia (así no enseñan datos de REVE citando a Open Charge Map).
--
-- Antes de la parte 2 hay que tener:
--   - el secreto REVE_API_KEY en las Edge Functions (supabase secrets set)
--   - la función desplegada: supabase functions deploy charging-stations --no-verify-jwt
-- Usa el mismo secreto del cron que price-alerts (price_alerts_cron_secret).
-- Se puede ejecutar más de una vez.

-- 1. Tabla -------------------------------------------------------------------

create table if not exists public.charging_stations (
  id             text primary key,            -- «reve:<id>» u «ocm:<id>»
  source         text not null,               -- reve u ocm
  name           text not null,
  operator       text,
  address        text,
  town           text,
  postcode       text,
  latitude       double precision not null,
  longitude      double precision not null,
  -- [{"type": "ccs", "label": "CCS (Type 2)", "kw": 50, "quantity": 2,
  --   "price_kwh": 0.46}, ...]  (price_kwh solo en los de REVE)
  connectors     jsonb not null default '[]'::jsonb,
  max_kw         numeric(6, 1),
  points         integer,                     -- cargadores
  available      integer,                     -- libres ahora (solo REVE)
  occupied       integer,                     -- cargando, bloqueados o reservados
  out_of_order   integer,                     -- averiados o fuera de servicio
  -- operational, not_operational o unknown
  status         text not null default 'unknown',
  price_kwh      numeric(5, 3),               -- €/kWh con IVA; el más barato
  free           boolean not null default false,
  -- reve: publicado por el operador; ocm: aportado por la comunidad
  price_source   text,
  extra_fees     boolean not null default false, -- cobra también por tiempo o conexión
  usage_cost     text,                        -- texto del precio tal como viene
  source_updated timestamptz,                 -- última actualización en la fuente
  synced_at      timestamptz not null default now()
);

create index if not exists charging_stations_lat_lon_idx
  on public.charging_stations (latitude, longitude);

alter table public.charging_stations enable row level security;
drop policy if exists "Puntos de recarga visibles" on public.charging_stations;
create policy "Puntos de recarga visibles" on public.charging_stations
  for select to anon, authenticated using (true);
revoke insert, update, delete on public.charging_stations from anon, authenticated;

-- 2. Cada 15 minutos ------------------------------------------------------------

create extension if not exists pg_cron;
create extension if not exists pg_net;

select cron.unschedule('charging-stations')
where exists (select 1 from cron.job where jobname = 'charging-stations');

-- A los 5, 20, 35 y 50 de cada hora (charging-sync va a las 04:20 UTC).
select cron.schedule(
  'charging-stations',
  '5,20,35,50 * * * *',
  $$
  select net.http_post(
    url := 'https://dhfemojxqsfrfnedhede.supabase.co/functions/v1/charging-stations',
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
