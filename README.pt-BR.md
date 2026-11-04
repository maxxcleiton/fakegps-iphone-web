# FakeGPS iPhone para Linux 📍

> Simulador leve de localização virtual (Fake GPS) para iPhones conectados via USB no Linux (Ubuntu, Xubuntu, Debian, Mint).

[![Plataforma](https://img.shields.io/badge/plataforma-Linux-blue.svg)](https://github.com/maxxcleiton/fakegps-iphone-linux)
[![Suporte iOS](https://img.shields.io/badge/iOS-12%20a%2026%2B-green.svg)](https://github.com/maxxcleiton/fakegps-iphone-linux)
[![Arquitetura](https://img.shields.io/badge/arch-all-orange.svg)](https://github.com/maxxcleiton/fakegps-iphone-linux)

**Idiomas:** [🇺🇸 English](README.md) | [🇧🇷 Português](README.pt-BR.md)

---

## 🌟 Recursos Principais

* **Compatibilidade Universal:** Funciona desde o iOS 12 até o **iOS 17, 18 e iOS 26+**.
* **Sem Necessidade de Root / Sudo para Simular:** Comunica-se com o iOS diretamente via túnel RemoteXPC userspace (`pymobiledevice3`).
* **Interface Gráfica com Mapa:** Interface web moderna e escura construída com Leaflet e OpenStreetMap.
* **Busca por Cidades e Endereços:** Pesquise qualquer rua, bairro ou cidade do mundo via Nominatim.
* **Sessão Persistente:** Fixa a coordenada simulada no aparelho para que o iOS não restaure a localização real até que você clique em restaurar.
* **Botão de Desligar:** Inclui botão **"⏹ Desligar"** no cabeçalho para finalizar o servidor em segundo plano diretamente pelo navegador.
* **Integração com o Sistema:** Cria entrada no menu de aplicativos do Xubuntu/Ubuntu com ícone personalizado e comando `fakegps-iphone` no terminal.

---

## 📦 Como Instalar

### Método 1: Pacote `.deb` (Recomendado)

1. Baixe o pacote **`fakegps-iphone_1.0.1_all.deb`** na aba [Releases](https://github.com/maxxcleiton/fakegps-iphone-linux/releases).
2. Abra o terminal na pasta onde fez o download e execute:
   ```bash
   sudo apt install ./fakegps-iphone_1.0.1_all.deb
   ```
   *(O comando `apt install ./...` resolve e instala automaticamente dependências do sistema como `usbmuxd` e `python3-venv`).*

3. Para abrir:
   * Abra pelo **Menu de Aplicativos** (em *Desenvolvimento* ou *Acessórios*), ou
   * Digite no terminal:
     ```bash
     fakegps-iphone
     ```
   O aplicativo inicia o serviço e abre o navegador automaticamente em `http://localhost:8765`.

---

### Método 2: Rodar do Código Fonte

Se preferir rodar direto sem instalar o `.deb`:

1. Instale os pré-requisitos do sistema:
   ```bash
   sudo apt update && sudo apt install -y python3 python3-venv usbmuxd curl
   ```
2. Clone o repositório e execute:
   ```bash
   git clone https://github.com/maxxcleiton/fakegps-iphone-linux.git
   cd fakegps-iphone-linux
   python3 -m venv .venv
   .venv/bin/pip install -r requirements.txt
   ./start.sh
   ```

---

## 📱 Configuração no iPhone

1. **Primeira Conexão:** Ao plugar o iPhone na USB, desbloqueie a tela, toque em **"Confiar neste Computador"** e digite o código de desbloqueio.
2. **Modo Desenvolvedor (iOS 16+):**
   * Acesse **Ajustes** → **Privacidade e Segurança** → **Modo Desenvolvedor**.
   * Ative a opção e siga as instruções para reiniciar o aparelho.

---

## 🛠️ Como Recriar o Pacote `.deb`

Se você fizer alterações no código (`server.py`, `index.html`), gere um novo pacote `.deb` com:
```bash
./build-deb.sh
```
O arquivo `.deb` atualizado será gerado na raiz da pasta.

---

## 📄 Licença

Código aberto sob a licença [MIT](LICENSE).
