#!/usr/bin/env bash
# Guarda en Supabase la clave .p8 de «Sign in with Apple» (Key ID 722AK4C752)
# como secreto APPLE_SIGNIN_KEY de la función apple-revoke, sin mostrarla.
#
# Uso: supabase/configurar_apple.sh ~/Downloads/AuthKey_722AK4C752.p8
set -euo pipefail
KEY_FILE="${1:-}"
if [[ -z "$KEY_FILE" || ! -f "$KEY_FILE" ]] || ! grep -q "BEGIN PRIVATE KEY" "$KEY_FILE"; then
  echo "Indica la ruta del .p8 de Sign in with Apple." >&2
  exit 1
fi
cd "$(dirname "$0")/.."
supabase secrets set --remote=dhfemojxqsfrfnedhede APPLE_SIGNIN_KEY="$(cat "$KEY_FILE")"
echo "Listo. Guarda el .p8 en un sitio seguro: Apple no deja volver a descargarlo."
