-- Idioma de las notificaciones push (app 1.0.6).
--
-- Cada dispositivo guarda el idioma de la app (es, en, de) junto a su token,
-- y la función price-alerts escribe el aviso en ese idioma.
--
-- Compatible con la app 1.0.5, que llama a register_push_token sin idioma:
-- sus dispositivos se quedan en español. Hay que aplicarlo ANTES de publicar
-- la 1.0.6, que ya manda p_locale. Se puede ejecutar más de una vez.

alter table public.push_tokens
  add column if not exists locale text not null default 'es';

alter table public.push_tokens
  drop constraint if exists push_tokens_locale_check;
alter table public.push_tokens
  add constraint push_tokens_locale_check check (locale in ('es', 'en', 'de'));

-- La versión de dos parámetros se sustituye por una con p_locale opcional
-- (si convivieran las dos, una llamada sin idioma sería ambigua).
drop function if exists public.register_push_token(text, text);

create or replace function public.register_push_token(
  p_token text,
  p_platform text,
  p_locale text default null
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  -- Un idioma que la app no tiene cuenta como «sin idioma».
  v_locale text := case when p_locale in ('es', 'en', 'de') then p_locale end;
begin
  if auth.uid() is null then
    raise exception 'No hay usuario autenticado';
  end if;
  insert into public.push_tokens (token, user_id, platform, locale, updated_at)
  values (p_token, auth.uid(), p_platform, coalesce(v_locale, 'es'), now())
  on conflict (token) do update
    set user_id = excluded.user_id,
        platform = excluded.platform,
        -- Sin idioma (app 1.0.5) se conserva el que hubiera.
        locale = coalesce(v_locale, public.push_tokens.locale),
        updated_at = now();
end;
$$;

revoke all on function public.register_push_token(text, text, text) from public, anon;
grant execute on function public.register_push_token(text, text, text) to authenticated;
