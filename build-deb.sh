#!/usr/bin/env bash
# Script para gerar o pacote .deb do FakeGPS iPhone
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSION="1.0.7"
PKG_NAME="fakegps-iphone_${VERSION}_all"
BUILD_DIR="$SCRIPT_DIR/build_deb/$PKG_NAME"

echo "==> Preparando estrutura do pacote .deb em $BUILD_DIR..."
rm -rf "$SCRIPT_DIR/build_deb"
mkdir -p "$BUILD_DIR/DEBIAN"
mkdir -p "$BUILD_DIR/opt/fakegps-iphone"
mkdir -p "$BUILD_DIR/usr/bin"
mkdir -p "$BUILD_DIR/usr/share/applications"
mkdir -p "$BUILD_DIR/usr/share/icons/hicolor/scalable/apps"

# 1. Arquivos da aplicação
cp "$SCRIPT_DIR/server.py" "$BUILD_DIR/opt/fakegps-iphone/"
cp "$SCRIPT_DIR/index.html" "$BUILD_DIR/opt/fakegps-iphone/"
cp "$SCRIPT_DIR/requirements.txt" "$BUILD_DIR/opt/fakegps-iphone/"
cp "$SCRIPT_DIR/run.sh" "$BUILD_DIR/opt/fakegps-iphone/"
chmod 755 "$BUILD_DIR/opt/fakegps-iphone/run.sh"

# 2. Ícone
cp "$SCRIPT_DIR/fakegps-iphone.svg" "$BUILD_DIR/usr/share/icons/hicolor/scalable/apps/"

# 3. Atalho de menu (.desktop)
cat > "$BUILD_DIR/usr/share/applications/fakegps-iphone.desktop" << 'EOF'
[Desktop Entry]
Name=FakeGPS iPhone
Comment=Simulador de Localização Virtual para iPhone via USB
Exec=/usr/bin/fakegps-iphone
Icon=fakegps-iphone
Terminal=false
Type=Application
Categories=Development;Utility;
Keywords=gps;fake;iphone;location;map;
EOF
chmod 644 "$BUILD_DIR/usr/share/applications/fakegps-iphone.desktop"

# 4. Binário no PATH (/usr/bin/fakegps-iphone)
cat > "$BUILD_DIR/usr/bin/fakegps-iphone" << 'EOF'
#!/usr/bin/env bash
exec /opt/fakegps-iphone/run.sh "$@"
EOF
chmod 755 "$BUILD_DIR/usr/bin/fakegps-iphone"

# 5. Metadados do Debian (control)
cat > "$BUILD_DIR/DEBIAN/control" << EOF
Package: fakegps-iphone
Version: $VERSION
Section: utils
Priority: optional
Architecture: all
Maintainer: SM Informatica
Depends: python3, python3-venv, usbmuxd, curl
Description: Fake GPS e Simulador de Localização para iPhone via USB
 Ferramenta leve com interface web e mapa interativo para simular
 coordenadas GPS em iPhones conectados via USB no Linux.
 Compatível com iOS 12 até iOS 18 / iOS 26+.
EOF

# 6. Script de pós-instalação (postinst)
cat > "$BUILD_DIR/DEBIAN/postinst" << 'EOF'
#!/bin/bash
set -e

APP_DIR="/opt/fakegps-iphone"

echo "=========================================================="
echo "Configurando ambiente Python do FakeGPS iPhone..."
echo "=========================================================="

# Cria o virtualenv com python3 da máquina
if [ ! -d "$APP_DIR/.venv" ]; then
    python3 -m venv "$APP_DIR/.venv"
fi

# Instala as dependências isoladas
echo "Instalando bibliotecas necessárias (pymobiledevice3, fastapi, uvicorn)..."
"$APP_DIR/.venv/bin/python3" -m pip install --upgrade pip >/dev/null 2>&1 || true
"$APP_DIR/.venv/bin/pip" install -r "$APP_DIR/requirements.txt"

# Atualiza cache de ícones e atalhos
if which update-desktop-database >/dev/null 2>&1; then
    update-desktop-database -q /usr/share/applications || true
fi
if which gtk-update-icon-cache >/dev/null 2>&1; then
    gtk-update-icon-cache -q /usr/share/icons/hicolor || true
fi

echo ""
echo "=========================================================="
echo "✅ FakeGPS iPhone instalado com sucesso!"
echo "   Para abrir:"
echo "   - Digite 'fakegps-iphone' no terminal, OU"
echo "   - Abra pelo menu de aplicativos do Xubuntu."
echo "=========================================================="
EOF
chmod 755 "$BUILD_DIR/DEBIAN/postinst"

# 7. Script pré-remoção (prerm)
cat > "$BUILD_DIR/DEBIAN/prerm" << 'EOF'
#!/bin/bash
pkill -f "/opt/fakegps-iphone/server.py" 2>/dev/null || true
EOF
chmod 755 "$BUILD_DIR/DEBIAN/prerm"

# 8. Script pós-remoção (postrm)
cat > "$BUILD_DIR/DEBIAN/postrm" << 'EOF'
#!/bin/bash
if [ "$1" = "purge" ] || [ "$1" = "remove" ]; then
    rm -rf /opt/fakegps-iphone
fi
if which update-desktop-database >/dev/null 2>&1; then
    update-desktop-database -q /usr/share/applications || true
fi
EOF
chmod 755 "$BUILD_DIR/DEBIAN/postrm"

# 9. Construção do pacote
OUTPUT_DEB="$SCRIPT_DIR/${PKG_NAME}.deb"
dpkg-deb --build --root-owner-group "$BUILD_DIR" "$OUTPUT_DEB"

rm -rf "$SCRIPT_DIR/build_deb"

echo ""
echo "🎉 Pacote gerado com sucesso:"
echo "   $OUTPUT_DEB"
echo ""
echo "Para instalar em qualquer máquina Ubuntu/Xubuntu:"
echo "   sudo apt install ./${PKG_NAME}.deb"
