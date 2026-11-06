# FakeGPS iPhone 📍

> Simulador moderno e leve de localização virtual (Fake GPS) para iPhones conectados via USB. Interface web multiplataforma para **Linux**, **Windows** e **macOS**.

[![Plataforma](https://img.shields.io/badge/plataforma-Linux%20%7C%20Windows%20%7C%20macOS-blue.svg)](https://github.com/maxxcleiton/fakegps-iphone-web)
[![Suporte iOS](https://img.shields.io/badge/iOS-12%20a%2026%2B-green.svg)](https://github.com/maxxcleiton/fakegps-iphone-web)
[![Licença: MIT](https://img.shields.io/badge/Licen%C3%A7a-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**Idiomas:** [🇺🇸 English](README.md) | [🇧🇷 Português](README.pt-BR.md)

<p align="center">
  <img src="screenshot.png" alt="Interface Web do FakeGPS iPhone" width="900">
</p>

---

## 🌟 Recursos Principais

* **Compatibilidade Universal:** Funciona desde o iOS 12 até o **iOS 17, 18 e iOS 26+**.
* **Multiplataforma Real:** Roda de forma idêntica no **Linux (Ubuntu, Xubuntu, Debian, Mint)**, **Windows** e **macOS**.
* **Sem Necessidade de Root / Sudo:** Comunica-se com o iOS diretamente via túnel RemoteXPC userspace (`pymobiledevice3`).
* **Interface Gráfica com Mapa:** Interface web limpa em tema escuro (Leaflet + OpenStreetMap). Limites geográficos travados para evitar repetições confusas da Terra.
* **Busca por Cidades e Endereços:** Pesquise qualquer rua, ponto turístico ou cidade do mundo via Nominatim.
* **Sessão Persistente:** Fixa a coordenada simulada no aparelho para que o iOS não restaure o GPS real sozinho.
* **Botão Desligar:** Botão **"⏹ Desligar"** no cabeçalho para finalizar o servidor em segundo plano diretamente pelo navegador.
* **Executável `.exe` para Windows:** Não precisa de Python instalado no Windows—basta baixar e dar dois cliques!

---

## 🚀 Como Usar por Sistema Operacional

### 🪟 Windows (10 / 11)

1. **Pré-requisito:** Certifique-se de ter o app **Dispositivos Apple (Apple Devices)** (da Microsoft Store) ou o **iTunes** instalado para que o Windows possua os drivers USB oficiais da Apple.
2. **Download:** Baixe o executável **`FakeGPS-iPhone.exe`** na aba [Releases](https://github.com/maxxcleiton/fakegps-iphone-web/releases).
3. **Execução:** Dê dois cliques em **`FakeGPS-iPhone.exe`**.
   * Ele inicia o serviço e abre o navegador em `http://localhost:8765` automaticamente!
   *(Alternativa: Baixe `FakeGPS-iPhone-Windows.zip` e execute `start.bat` se preferir).*

---

### 🐧 Linux

#### Opção A: Debian, Ubuntu, Xubuntu, Linux Mint (.deb)
1. Baixe o pacote **`fakegps-iphone_*_all.deb`** na aba [Releases](https://github.com/maxxcleiton/fakegps-iphone-web/releases).
2. Instale no terminal:
   ```bash
   sudo apt install ./fakegps-iphone_*_all.deb
   ```
3. Abra pelo menu de aplicativos (**FakeGPS iPhone**) ou digite `fakegps-iphone` no terminal.

#### Opção B: Rocky Linux, Fedora, RHEL, Arch ou direto do código
1. Instale os pré-requisitos:
   * **Rocky Linux / RHEL / Fedora:**
     ```bash
     sudo dnf install -y python3 python3-pip git usbmuxd libimobiledevice
     sudo systemctl enable --now usbmuxd
     ```
   * **Arch Linux / Manjaro:**
     ```bash
     sudo pacman -S python python-pip git usbmuxd libimobiledevice
     sudo systemctl enable --now usbmuxd
     ```
2. Clone e inicie:
   ```bash
   git clone https://github.com/maxxcleiton/fakegps-iphone-web.git
   cd fakegps-iphone-web
   ./start.sh
   ```

---

### 🍎 macOS

1. Baixe o arquivo **`FakeGPS-iPhone-macOS.zip`** na aba [Releases](https://github.com/maxxcleiton/fakegps-iphone-web/releases).
2. Extraia o ZIP e execute no Terminal:
   ```bash
   ./start-mac.sh
   ```
   *(O macOS já possui os serviços de comunicação USB da Apple integrados nativamente no sistema).*

---

## 📱 Configuração no iPhone

1. **Confirmação USB:** Ao plugar o iPhone na USB, desbloqueie a tela, toque em **"Confiar neste Computador"** e digite seu código de tela.
2. **Modo Desenvolvedor (iOS 16+):**
   * Vá em **Ajustes** → **Privacidade e Segurança** → **Modo Desenvolvedor**.
   * Ative a opção e siga as instruções na tela para reiniciar o aparelho.

---

## 🛠️ Como Recriar o Pacote `.deb` no Linux

Se você alterar arquivos do código, recrie o `.deb` com:
```bash
./build-deb.sh
```

---

## 📄 Licença

Código aberto sob a licença [MIT](LICENSE).
