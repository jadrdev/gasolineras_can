#!/usr/bin/env bash
# Configura los secretos de las push de bajada de precio en Supabase.
#
# Uso:
#   supabase/configurar_push.sh ~/Downloads/gasolineras-can-firebase-adminsdk-xxxx.json
#
# El .json es la clave de la cuenta de servicio de Firebase:
#   Firebase Console > ⚙️ Configuración del proyecto > Cuentas de servicio >
#   «Generar nueva clave privada».
#
# Hace tres cosas, sin mostrar ninguna clave por pantalla:
#   1. Guarda el .json como secreto FIREBASE_SERVICE_ACCOUNT de las funciones.
#   2. Genera una clave aleatoria para el cron y la guarda como CRON_SECRET.
#   3. Guarda esa misma clave en el Vault de la base (price_alerts_cron_secret),
#      que es de donde la lee el cron cada hora.
# Se puede repetir: sustituye las claves anteriores.

set -euo pipefail

PROJECT_REF=dhfemojxqsfrfnedhede
SA_FILE="${1:-}"

if [[ -z "$SA_FILE" || ! -f "$SA_FILE" ]]; then
  echo "Indica la ruta del .json de la cuenta de servicio de Firebase." >&2
  exit 1
fi
if ! grep -q '"type": *"service_account"' "$SA_FILE"; then
  echo "Ese archivo no parece una clave de cuenta de servicio de Firebase." >&2
  exit 1
fi

cd "$(dirname "$0")/.."

CRON_SECRET="$(openssl rand -hex 32)"
SQL_FILE="$(mktemp)"
trap 'rm -f "$SQL_FILE"' EXIT

echo "1/3 Guardando la cuenta de servicio de Firebase…"
supabase secrets set --remote="$PROJECT_REF" \
  FIREBASE_SERVICE_ACCOUNT="$(cat "$SA_FILE")"

echo "2/3 Guardando la clave del cron en las funciones…"
supabase secrets set --remote="$PROJECT_REF" CRON_SECRET="$CRON_SECRET"

echo "3/3 Guardando la clave del cron en el Vault (te pedirá confirmar)…"
cat >"$SQL_FILE" <<SQL
do \$\$
declare existing uuid;
begin
  select id into existing from vault.secrets where name = 'price_alerts_cron_secret';
  if existing is null then
    perform vault.create_secret('$CRON_SECRET', 'price_alerts_cron_secret');
  else
    perform vault.update_secret(existing, '$CRON_SECRET');
  end if;
end
\$\$;
SQL
supabase db query --remote="$PROJECT_REF" -f "$SQL_FILE"

echo "Listo. Ya puedes borrar el .json de Descargas si quieres."
