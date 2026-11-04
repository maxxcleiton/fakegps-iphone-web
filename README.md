# FakeGPS iPhone for Linux 📍

> Lightweight virtual location spoofer for connected iPhones on Linux (Ubuntu, Xubuntu, Debian, Mint).

[![Platform](https://img.shields.io/badge/platform-Linux-blue.svg)](https://github.com/maxxcleiton/fakegps-iphone-linux)
[![iOS Support](https://img.shields.io/badge/iOS-12%20to%2026%2B-green.svg)](https://github.com/maxxcleiton/fakegps-iphone-linux)
[![Architecture](https://img.shields.io/badge/arch-all-orange.svg)](https://github.com/maxxcleiton/fakegps-iphone-linux)

**Languages:** [🇺🇸 English](README.md) | [🇧🇷 Português](README.pt-BR.md)

---

## 🌟 Key Features

* **Universal iOS Support:** Works on iOS 12 through **iOS 17, 18, and iOS 26+**.
* **No Root / Sudo Required for Spoofing:** Communicates with iOS via in-process userspace RemoteXPC tunnel (`pymobiledevice3`).
* **Interactive Map GUI:** Clean dark-themed web interface powered by Leaflet and OpenStreetMap.
* **City & Address Search:** Search any street, landmark, or city worldwide via Nominatim.
* **Persistent Session:** Fixes the simulated coordinates on the iPhone so iOS does not revert back to the real location until you decide to clear it.
* **One-Click Server Shutdown:** Includes a dedicated **"⏹ Desligar"** (Stop) button in the web header to cleanly shut down the server when done.
* **Native Desktop Integration:** Installs a menu entry with an icon in your desktop environment (XFCE, GNOME, KDE) and provides a `fakegps-iphone` command.

---

## 📦 Installation

### Method 1: Download `.deb` Package (Recommended)

1. Download the latest **`fakegps-iphone_1.0.1_all.deb`** from the [Releases](https://github.com/maxxcleiton/fakegps-iphone-linux/releases) section.
2. Open a terminal in the folder where you downloaded the file and run:
   ```bash
   sudo apt install ./fakegps-iphone_1.0.1_all.deb
   ```
   *(Using `apt install ./...` automatically resolves and installs system prerequisites like `usbmuxd` and `python3-venv`).*

3. Launch the app:
   * Click **FakeGPS iPhone** in your application menu (under *Development* or *Accessories*), or
   * Run in terminal:
     ```bash
     fakegps-iphone
     ```
   The application will automatically start the background service and open your browser at `http://localhost:8765`.

---

### Method 2: Run from Source

If you prefer to run directly without installing a `.deb` package:

1. Install system prerequisites:
   ```bash
   sudo apt update && sudo apt install -y python3 python3-venv usbmuxd curl
   ```
2. Clone the repository and run:
   ```bash
   git clone https://github.com/maxxcleiton/fakegps-iphone-linux.git
   cd fakegps-iphone-linux
   python3 -m venv .venv
   .venv/bin/pip install -r requirements.txt
   ./start.sh
   ```

---

## 📱 iPhone Setup

1. **First Connection:** When connecting your iPhone via USB, unlock the screen and tap **"Trust This Computer"** and enter your passcode.
2. **Developer Mode (iOS 16+):**
   * Go to **Settings** → **Privacy & Security** → **Developer Mode**.
   * Toggle it **On** and follow the prompt to reboot your iPhone.

---

## 🛠️ Building the `.deb` Package

If you modify `server.py` or `index.html`, you can re-generate the `.deb` package at any time:
```bash
./build-deb.sh
```
The output `.deb` will be generated in the root of the repository.

---

## 📄 License

Open source under the [MIT License](LICENSE).
