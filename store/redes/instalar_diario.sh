#!/bin/zsh
# Instala (o actualiza) la tarea de macOS que genera cada mañana a las 8:30 el
# post «La gasolina más barata hoy». Volver a ejecutarlo tras cambiar
# generar_diario.py o generar_capturas.py.
#
# Copia los scripts a ~/Library/Application Support/GasoCan/diario porque las
# tareas programadas no pueden leer el disco externo sin un permiso de
# privacidad. Los posts quedan en ~/GasoCan/posts/AAAA-MM-DD/.
#
# Quitarla: launchctl bootout gui/$(id -u)/com.gasocan.diario
#           rm ~/Library/LaunchAgents/com.gasocan.diario.plist
set -e
REPO=${0:A:h:h:h}
DEST="$HOME/Library/Application Support/GasoCan/diario"
POSTS="$HOME/GasoCan/posts"
PLIST="$HOME/Library/LaunchAgents/com.gasocan.diario.plist"
mkdir -p "$DEST" "$POSTS"
cp "$REPO/store/redes/generar_diario.py" "$REPO/store/generar_capturas.py" "$DEST/"

cat > "$DEST/lanzar.sh" <<SH
#!/bin/zsh
export GASOCAN_DIARIO="$POSTS"
cd "$DEST"
if SALIDA=\$(/usr/bin/python3 generar_diario.py); then
  osascript -e 'display notification "Imagen y texto listos para publicar" with title "GasoCan: post diario"'
  open "\$SALIDA"
else
  osascript -e 'display notification "No se pudo generar: mira ~/Library/Logs/gasocan-diario.log" with title "GasoCan: post diario"'
fi
SH
chmod +x "$DEST/lanzar.sh"

cat > "$PLIST" <<XML
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>com.gasocan.diario</string>
  <key>ProgramArguments</key>
  <array><string>/bin/zsh</string><string>$DEST/lanzar.sh</string></array>
  <key>StartCalendarInterval</key>
  <dict><key>Hour</key><integer>8</integer><key>Minute</key><integer>30</integer></dict>
  <key>StandardOutPath</key><string>$HOME/Library/Logs/gasocan-diario.log</string>
  <key>StandardErrorPath</key><string>$HOME/Library/Logs/gasocan-diario.log</string>
</dict>
</plist>
XML
launchctl bootout gui/$(id -u)/com.gasocan.diario 2>/dev/null || true
launchctl bootstrap gui/$(id -u) "$PLIST"
echo "Instalado: cada día a las 8:30 en $POSTS"
