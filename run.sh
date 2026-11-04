#!/usr/bin/env bash
# Launcher para FakeGPS iPhone
set -e

DIR="/opt/fakegps-iphone"
# Se executado localmente na pasta do projeto, usa a pasta atual
if [ ! -d "$DIR" ] && [ -f "./server.py" ]; then
  DIR="$(pwd)"
fi

PYTHON="$DIR/.venv/bin/python3"
PORT="${PORT:-8765}"
URL="http://localhost:$PORT"

# 1. Verifica se usbmuxd está rodando
if ! pgrep -x usbmuxd >/dev/null 2>&1; then
  echo "==> Iniciando usbmuxd..."
  sudo usbmuxd 2>/dev/null || usbmuxd 2>/dev/null || true
fi

# 2. Se o servidor já estiver rodando, só abre o navegador
if curl -s --connect-timeout 1 "$URL/api/status" >/dev/null 2>&1; then
  echo "==> Servidor FakeGPS já está rodando em $URL"
  xdg-open "$URL" 2>/dev/null || true
  exit 0
fi

# 3. Abre o navegador após 1.5s
(sleep 1.5 && xdg-open "$URL" 2>/dev/null || true) &

# 4. Inicia o servidor
echo "==> Iniciando FakeGPS iPhone em $URL..."
echo "==> Pressione Ctrl+C para encerrar."
exec "$PYTHON" "$DIR/server.py"
