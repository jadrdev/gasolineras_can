-- Borrado de cuenta desde la app (requisito 5.1.1(v) de App Store).
--
-- Se ejecuta UNA vez en Supabase: Dashboard > SQL Editor > pegar y "Run".
-- La app la llama con supabase.rpc('delete_my_account') y solo puede borrar
-- al usuario que la llama (auth.uid()); nadie puede borrar a otro.

create or replace function public.delete_my_account()
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  uid uuid := auth.uid();
begin
  if uid is null then
    raise exception 'No hay usuario autenticado';
  end if;

  delete from public.favorites where user_id = uid;
  delete from public.users where id = uid;
  delete from auth.users where id = uid;
end;
$$;

revoke all on function public.delete_my_account() from public, anon;
grant execute on function public.delete_my_account() to authenticated;
