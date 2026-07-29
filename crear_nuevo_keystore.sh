#!/bin/bash
# Script para generar un nuevo keystore y certificado PEM
# para resetear el upload key en Google Play Console.
#
# IMPORTANTE:
# - Lee el archivo entero ANTES de ejecutarlo.
# - Guarda la contraseña que elijas en un gestor de contrasenas.
# - No compartas el .jks ni key.properties.

set -e

PROJECT_DIR="/Volumes/Seagate/FLUTTER/gasolineras_can"
APP_DIR="$PROJECT_DIR/android/app"
KEY_FILE="$APP_DIR/upload-keystore.jks"
PEM_FILE="$APP_DIR/upload_certificate.pem"
PROPS_FILE="$PROJECT_DIR/android/key.properties"

echo "=========================================="
echo " NUEVO KEYSTORE PARA Google Play Console"
echo " Application ID: com.jadrdev.gasolinera"
echo "=========================================="
echo ""

# Pregunta por contrasenas
read -s -p "Escribe la contrasena para el nuevo keystore (store y key iguales): " PASSWORD
echo ""
read -s -p "Repite la contrasena: " PASSWORD2
echo ""

if [ "$PASSWORD" != "$PASSWORD2" ]; then
    echo "ERROR: las contrasenas no coinciden."
    exit 1
fi

# Datos del certificado (puedes cambiarlos)
CN="Joshua A. Diaz Robayna"
OU="Desarrollo"
O="jadrdev"
L="Las Palmas"
ST="Las Palmas"
C="ES"

# Renombra el keystore antiguo si existe
if [ -f "$KEY_FILE" ]; then
    echo "Renombrando keystore antiguo..."
    mv "$KEY_FILE" "$APP_DIR/upload-keystore-ANTIGUO-$(date +%Y%m%d%H%M%S).jks"
fi

# Genera el nuevo keystore
echo "Generando nuevo keystore en $KEY_FILE..."
keytool -genkey -v \
  -keystore "$KEY_FILE" \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload \
  -storepass "$PASSWORD" \
  -keypass "$PASSWORD" \
  -dname "CN=$CN, OU=$OU, O=$O, L=$L, ST=$ST, C=$C"

# Genera el PEM
echo "Generando certificado PEM en $PEM_FILE..."
keytool -export -rfc \
  -keystore "$KEY_FILE" \
  -alias upload \
  -file "$PEM_FILE" \
  -storepass "$PASSWORD"

# Actualiza key.properties
echo "Actualizando android/key.properties..."
cat > "$PROPS_FILE" <<EOF
storeFile=../app/upload-keystore.jks
storePassword=$PASSWORD
keyAlias=upload
keyPassword=$PASSWORD
EOF

echo ""
echo "=========================================="
echo " LISTO"
echo "=========================================="
echo "Keystore:        $KEY_FILE"
echo "Certificado PEM: $PEM_FILE"
echo ""
echo "Pasos siguientes:"
echo "1. Sube upload_certificate.pem a Play Console"
echo "   Configuracion > Firma de aplicaciones > Reset upload key"
echo "2. Espera aprobacion de Google (puede tardar horas o dias)."
echo "3. Incrementa versionCode en pubspec.yaml."
echo "4. Ejecuta: flutter clean && flutter pub get && flutter build appbundle --release"
echo "5. Sube build/app/outputs/bundle/release/app-release.aab"
echo ""
echo "IMPORTANTE: guarda la contrasena en un lugar seguro."
echo "Sin ella no podras volver a firmar la app."
