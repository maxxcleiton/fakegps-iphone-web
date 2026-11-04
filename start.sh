#!/usr/bin/env bash
# FakeGPS iPhone — script de inicialização
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV="$SCRIPT_DIR/.venv"
PYTHON="$VENV/bin/python3"
PORT="${PORT:-8765}"

echo ""
echo "╔══════════════════════════════════════╗"
echo "║      FakeGPS iPhone — Iniciando      ║"
echo "╚══════════════════════════════════════╝"
echo ""

# Verifica venv
if [ ! -f "$PYTHON" ]; then
  echo "❌ Ambiente virtual não encontrado em $VENV"
  echo "   Execute: python3 -m venv .venv --without-pip && .venv/bin/python3 /tmp/get-pip.py && .venv/bin/pip install pymobiledevice3 fastapi uvicorn"
  exit 1
fi

# Verifica pymobiledevice3
if ! "$PYTHON" -c "import pymobiledevice3" 2>/dev/null; then
  echo "❌ pymobiledevice3 não instalado. Execute:"
  echo "   $VENV/bin/pip install pymobiledevice3 fastapi uvicorn"
  exit 1
fi

# Verifica usbmuxd
if ! pgrep -x usbmuxd > /dev/null; then
  echo "⚠️  usbmuxd não está rodando. Iniciando..."
  sudo usbmuxd || echo "   (Pode precisar de sudo)"
fi

echo "🌐 Abrindo interface em http://localhost:$PORT"
echo "   Conecte o iPhone via USB antes de usar."
echo "   Pressione Ctrl+C para encerrar."
echo ""

# Abre navegador automaticamente após 2s (em background)
(sleep 2 && xdg-open "http://localhost:$PORT" 2>/dev/null || true) &

# Inicia servidor
PORT="$PORT" "$PYTHON" "$SCRIPT_DIR/server.py"
