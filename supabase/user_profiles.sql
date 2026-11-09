-- Perfil (public.users) para cada cuenta y permiso para editarlo.
--
-- Antes nada creaba la fila al registrarse y la tabla solo tenía política de
-- lectura, así que guardar combustible, litros o matrícula fallaba siempre
-- ("No se encontró el perfil"). Se puede ejecutar más de una vez.

-- 1. Crear el perfil al registrarse.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.users (id, email)
  values (new.id, coalesce(new.email, new.id::text))
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- 2. Perfiles de las cuentas que ya existían.
insert into public.users (id, email)
select id, coalesce(email, id::text) from auth.users
on conflict (id) do nothing;

-- 3. Cada uno edita solo su perfil, y solo estas columnas (no id ni email).
drop policy if exists "Users can update themselves" on public.users;
create policy "Users can update themselves" on public.users
  for update to authenticated
  using (auth.uid() = id)
  with check (auth.uid() = id);

revoke update on public.users from anon, authenticated;
grant update (preferred_fuel, tank_liters, license_plate)
  on public.users to authenticated;
