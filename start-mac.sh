#!/usr/bin/env bash
# FakeGPS iPhone — Launcher para macOS
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV="$SCRIPT_DIR/.venv"
PORT="${PORT:-8765}"
URL="http://localhost:$PORT"

echo ""
echo "╔══════════════════════════════════════╗"
echo "║       FakeGPS iPhone — macOS         ║"
echo "╚══════════════════════════════════════╝"
echo ""

# 1. Verifica Python 3
if ! command -v python3 >/dev/null 2>&1; then
  echo "❌ Python 3 não encontrado!"
  echo "   Instale via Homebrew: brew install python3"
  exit 1
fi

# 2. Cria venv se não existir
if [ ! -d "$VENV" ]; then
  echo "==> Criando ambiente virtual em $VENV..."
  python3 -m venv "$VENV"
fi

# 3. Instala dependências
echo "==> Verificando dependências..."
"$VENV/bin/python3" -m pip install --upgrade pip >/dev/null 2>&1 || true
"$VENV/bin/pip" install -r "$SCRIPT_DIR/requirements.txt" >/dev/null 2>&1

echo ""
echo "🌐 Abrindo interface em $URL"
echo "   Conecte o iPhone via cabo USB e clique em 'Confiar'."
echo "   Pressione Ctrl+C para encerrar."
echo ""

# 4. Abre o navegador padrão do Mac
(sleep 2 && open "$URL" 2>/dev/null || true) &

# 5. Inicia o servidor
exec "$VENV/bin/python3" "$SCRIPT_DIR/server.py"
