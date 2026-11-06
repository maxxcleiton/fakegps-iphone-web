#!/usr/bin/env bash
# FakeGPS iPhone — Launcher para Linux
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV="$SCRIPT_DIR/.venv"
HOST="${HOST:-localhost}"
PORT="${PORT:-8765}"
URL="http://$HOST:$PORT"

echo ""
echo "╔══════════════════════════════════════╗"
echo "║       FakeGPS iPhone — Linux         ║"
echo "╚══════════════════════════════════════╝"
echo ""

# 1. Verifica Python 3
if ! command -v python3 >/dev/null 2>&1; then
  echo "❌ Python 3 não encontrado!"
  echo "   Debian/Ubuntu:    sudo apt install python3 python3-venv usbmuxd"
  echo "   Rocky/RHEL/Fedora: sudo dnf install python3 python3-pip usbmuxd"
  exit 1
fi

# 2. Cria venv se não existir
if [ ! -d "$VENV" ]; then
  echo "==> Criando ambiente virtual em $VENV..."
  python3 -m venv "$VENV" || python3 -m venv "$VENV" --without-pip
  if [ ! -f "$VENV/bin/pip" ]; then
    echo "==> Instalando pip no ambiente virtual..."
    curl -sS https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py
    "$VENV/bin/python3" /tmp/get-pip.py
  fi
fi

# 3. Instala dependências
if ! "$VENV/bin/python3" -c "import pymobiledevice3, fastapi, uvicorn" >/dev/null 2>&1; then
  echo "==> Instalando dependências..."
  "$VENV/bin/python3" -m pip install --upgrade pip >/dev/null 2>&1 || true
  "$VENV/bin/pip" install -r "$SCRIPT_DIR/requirements.txt"
fi

# 4. Verifica usbmuxd
if ! pgrep -x usbmuxd >/dev/null 2>&1; then
  echo "⚠️  usbmuxd não está em execução. Tentando iniciar..."
  sudo systemctl start usbmuxd 2>/dev/null || sudo usbmuxd 2>/dev/null || usbmuxd 2>/dev/null || true
fi

echo "🌐 Abrindo interface em $URL"
echo "   Conecte o iPhone via USB antes de usar."
echo "   Pressione Ctrl+C para encerrar."
echo ""

# 5. Abre navegador após 2 segundos
(sleep 2 && xdg-open "$URL" 2>/dev/null || true) &

# 6. Inicia servidor
exec "$VENV/bin/python3" "$SCRIPT_DIR/server.py"
