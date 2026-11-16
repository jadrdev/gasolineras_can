-- «Colaborador»: quien ha dado una propina («Invítame a un café»).
--
-- Es un agradecimiento simbólico (insignia e iconos de la app), así que basta
-- con una marca en el perfil que el propio usuario activa al pagar. No hay
-- verificación del recibo: lo peor que pasa si alguien llama a la función a
-- mano es que se lleva la insignia.
--
-- Hay que aplicarlo antes de publicar la 1.0.7. Se puede ejecutar más de una vez.

alter table public.users
  add column if not exists colaborador boolean not null default false;

create or replace function public.marcar_colaborador()
returns void
language sql
security definer
set search_path = ''
as $$
  update public.users set colaborador = true where id = auth.uid();
$$;

revoke all on function public.marcar_colaborador() from public, anon;
grant execute on function public.marcar_colaborador() to authenticated;
