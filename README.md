# FakeGPS iPhone 📍

Simulador de localização GPS para iPhone conectado via cabo USB no Linux (Xubuntu 22.04, 24.04, 26.04+).

- Compatível com iOS 12 até iOS 18 e iOS 26+.
- Interface web interativa com OpenStreetMap e busca de cidades/endereços por texto.
- Sem necessidade de root/sudo para alterar o GPS (usa túnel userspace).
- Sessão persistente: o GPS falso fica fixado no aparelho até você mandar limpar.

---

## 📦 Como instalar em um PC novo

### Método 1: Pacote .deb (Recomendado)

1. Copie o arquivo `fakegps-iphone_1.0.0_all.deb` para a nova máquina (via pendrive, rede, etc.).
2. Abra o terminal na pasta onde está o arquivo e rode:
   ```bash
   sudo apt install ./fakegps-iphone_1.0.0_all.deb
   ```
   *(O `apt` baixa automaticamente o `usbmuxd`, `python3-venv` e configura o ambiente).*

3. Pronto! Para abrir, você pode:
   - Procurar por **FakeGPS iPhone** no menu de aplicativos do Xubuntu, ou
   - Digitar no terminal:
     ```bash
     fakegps-iphone
     ```

---

### Método 2: Sem instalar pacote (Rodar da pasta)

Se preferir rodar direto sem instalar o `.deb`:

1. Instale os pré-requisitos do sistema:
   ```bash
   sudo apt update && sudo apt install -y python3 python3-venv usbmuxd
   ```
2. Na pasta do projeto:
   ```bash
   python3 -m venv .venv
   .venv/bin/pip install -r requirements.txt
   ./start.sh
   ```

---

## 🛠️ Como recriar o arquivo .deb após modificações

Se fizer qualquer alteração no código (`server.py`, `index.html`), basta rodar:
```bash
./build-deb.sh
```
Um novo `.deb` será gerado automaticamente.

---

## 📱 Dicas no iPhone
1. **Primeira conexão:** Ao plugar o iPhone na USB, clique em **"Confiar neste Computador"** na tela do aparelho e digite sua senha de desbloqueio.
2. **Modo Desenvolvedor (iOS 16+):** Em *Ajustes* → *Privacidade e Segurança* → *Modo Desenvolvedor* (deve estar Ativado).
