-- Favoritos en tiempo real.
--
-- La app escucha la tabla favorites (filtrada por user_id) para que la
-- estrella cambie al momento en todos los dispositivos. La publicación
-- supabase_realtime estaba vacía y Supabase rechazaba la suscripción
-- ("Unable to subscribe ... check Realtime is enabled"); la app reintentaba
-- cada pocos segundos. La política "Users can view own favorites" hace que
-- cada uno reciba solo los suyos.
-- REPLICA IDENTITY FULL: los DELETE llevan user_id y pasan el filtro.

alter table public.favorites replica identity full;

do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'favorites'
  ) then
    alter publication supabase_realtime add table public.favorites;
  end if;
end
$$;
