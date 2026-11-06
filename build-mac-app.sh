#!/usr/bin/env bash
# Gera a estrutura do aplicativo nativo FakeGPS-iPhone.app para macOS
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="${1:-$SCRIPT_DIR}"
APP_NAME="FakeGPS iPhone.app"
APP_BUNDLE="$OUTPUT_DIR/$APP_NAME"

echo "==> Criando $APP_BUNDLE..."
rm -rf "$APP_BUNDLE"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources/app"

# 1. Copia arquivos da aplicação
cp "$SCRIPT_DIR/server.py" "$APP_BUNDLE/Contents/Resources/app/"
cp "$SCRIPT_DIR/index.html" "$APP_BUNDLE/Contents/Resources/app/"
cp "$SCRIPT_DIR/requirements.txt" "$APP_BUNDLE/Contents/Resources/app/"
if [ -f "$SCRIPT_DIR/fakegps-iphone.icns" ]; then
  cp "$SCRIPT_DIR/fakegps-iphone.icns" "$APP_BUNDLE/Contents/Resources/"
fi

# 2. Gera Info.plist
cat > "$APP_BUNDLE/Contents/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>FakeGPS-iPhone</string>
    <key>CFBundleIconFile</key>
    <string>fakegps-iphone</string>
    <key>CFBundleIdentifier</key>
    <string>com.maxxcleiton.fakegps-iphone</string>
    <key>CFBundleName</key>
    <string>FakeGPS iPhone</string>
    <key>CFBundleDisplayName</key>
    <string>FakeGPS iPhone</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.8</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.15</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>LSUIElement</key>
    <true/>
</dict>
</plist>
EOF

# 3. Executável nativo (Launcher)
cat > "$APP_BUNDLE/Contents/MacOS/FakeGPS-iPhone" << 'EOF'
#!/usr/bin/env bash
set -e

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

APP_DIR="$(cd "$(dirname "$0")/../Resources/app" && pwd)"
BUNDLE_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
PARENT_DIR="$(cd "$BUNDLE_DIR/.." && pwd)"
LOG_FILE="$HOME/Library/Logs/FakeGPS-iPhone.log"
mkdir -p "$HOME/Library/Logs"

exec >> "$LOG_FILE" 2>&1

# Se já existir venv na pasta pai (onde o usuário extraiu o zip), usa ela diretamente!
if [ -d "$PARENT_DIR/.venv" ]; then
  VENV="$PARENT_DIR/.venv"
elif [ -d "$APP_DIR/../../.venv" ]; then
  VENV="$APP_DIR/../../.venv"
else
  DATA_DIR="$HOME/Library/Application Support/FakeGPS-iPhone"
  mkdir -p "$DATA_DIR"
  VENV="$DATA_DIR/.venv"
fi

PORT="${PORT:-8765}"
URL="http://localhost:$PORT"

# Se o servidor já estiver em execução, apenas abre o navegador
if curl -s --connect-timeout 1 "$URL/api/status" >/dev/null 2>&1; then
  open "$URL"
  exit 0
fi

# Verifica se o Python 3 está presente
if ! command -v python3 >/dev/null 2>&1; then
  osascript -e 'display alert "Python 3 Necessário" message "O FakeGPS precisa do Python 3 no macOS. Execute xcode-select --install no Terminal para instalar."'
  exit 1
fi

# Cria venv se necessário
if [ ! -d "$VENV" ]; then
  python3 -m venv "$VENV"
fi

# Instala dependências se necessário
if ! "$VENV/bin/python3" -c "import pymobiledevice3, fastapi, uvicorn" >/dev/null 2>&1; then
  "$VENV/bin/python3" -m pip install --upgrade pip >/dev/null 2>&1 || true
  "$VENV/bin/pip" install -r "$APP_DIR/requirements.txt"
fi

# Abre o navegador padrão do macOS
(sleep 1.5 && open "$URL" 2>/dev/null || true) &

# Inicia o servidor
exec "$VENV/bin/python3" "$APP_DIR/server.py"
EOF

chmod 755 "$APP_BUNDLE/Contents/MacOS/FakeGPS-iPhone"

echo "✅ $APP_NAME criado com sucesso!"
