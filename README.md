# FakeGPS iPhone 📍

> Modern, lightweight virtual location spoofer for connected iPhones. Cross-platform web interface for **Linux**, **Windows**, and **macOS**.

[![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20Windows%20%7C%20macOS-blue.svg)](https://github.com/maxxcleiton/fakegps-iphone-web)
[![iOS Support](https://img.shields.io/badge/iOS-12%20to%2026%2B-green.svg)](https://github.com/maxxcleiton/fakegps-iphone-web)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**Languages:** [🇺🇸 English](README.md) | [🇧🇷 Português](README.pt-BR.md)

<p align="center">
  <img src="screenshot.png" alt="FakeGPS iPhone Web Interface" width="900">
</p>

---

## 🌟 Key Features

* **Universal iOS Support:** Works on iOS 12 through **iOS 17, 18, and iOS 26+**.
* **Cross-Platform:** Runs seamlessly on **Linux (Ubuntu, Xubuntu, Debian, Mint)**, **Windows**, and **macOS**.
* **No Root / Sudo Required for Spoofing:** Communicates with iOS via in-process userspace RemoteXPC tunnel (`pymobiledevice3`).
* **Interactive Map GUI:** Clean dark-themed web interface powered by Leaflet and OpenStreetMap. Single-world bounds prevent disorienting map loops.
* **City & Address Search:** Search any street, landmark, or city worldwide via Nominatim.
* **Persistent Session:** Coordinates remain fixed on the iPhone until you click "Restore Real GPS".
* **One-Click Server Shutdown:** Includes a dedicated **"⏹ Desligar"** (Stop) button in the header to cleanly terminate the server from the browser.
* **Standalone Windows `.exe`:** No Python installation needed on Windows—just download and double-click!
* **Xcode Simulator Support (macOS):** In addition to physical iPhones connected via USB, automatically detects and controls running **iOS Simulators** in Xcode with 1-click on the map, eliminating manual coordinate typing in GPX files or Xcode's Custom Location prompt!

---

## 🚀 Quick Start by Operating System

### 🪟 Windows (10 / 11)

1. **Prerequisite:** Ensure you have **Apple Devices** (from Microsoft Store) or **iTunes** installed so Windows has the official Apple USB drivers.
2. **Download:** Get the standalone **`FakeGPS-iPhone.exe`** from the [Releases](https://github.com/maxxcleiton/fakegps-iphone-web/releases) page.
3. **Run:** Double-click **`FakeGPS-iPhone.exe`**.
   * It starts the local service and opens your browser at `http://localhost:8765` automatically!
   *(Alternative: Download `FakeGPS-iPhone-Windows.zip` and run `start.bat` if you prefer).*

---

### 🐧 Linux
 
#### Option A: Debian, Ubuntu, Xubuntu, Linux Mint (.deb)
1. Download the **`fakegps-iphone_*_all.deb`** package from the [Releases](https://github.com/maxxcleiton/fakegps-iphone-web/releases) page.
2. Install via terminal:
   ```bash
   sudo apt install ./fakegps-iphone_*_all.deb
   ```
3. Open **FakeGPS iPhone** from your application menu or run `fakegps-iphone` in terminal.

#### Option B: Rocky Linux, Fedora, RHEL, Arch, or Run from Source
1. Install prerequisites:
   * **Rocky Linux / RHEL / Fedora:**
     ```bash
     sudo dnf install -y epel-release && sudo crb enable
     sudo dnf install -y python3 python3-pip git usbmuxd libimobiledevice
     sudo systemctl enable --now usbmuxd
     ```
   * **Arch Linux / Manjaro:**
     ```bash
     sudo pacman -S python python-pip git usbmuxd libimobiledevice
     sudo systemctl enable --now usbmuxd
     ```
2. Clone and launch:
   ```bash
   git clone https://github.com/maxxcleiton/fakegps-iphone-web.git
   cd fakegps-iphone-web
   ./start.sh
   ```

---

### 🍎 macOS (Physical iPhone or Xcode Simulator)

On Mac, FakeGPS seamlessly works with both **physical iPhones via USB** and the **Xcode iOS Simulator**!

#### How to Launch:
1. Download **`FakeGPS-iPhone-macOS.zip`** from [Releases](https://github.com/maxxcleiton/fakegps-iphone-web/releases) (or clone the repository).
2. Extract the ZIP and run in Terminal:
   ```bash
   ./start-mac.sh
   ```
3. Your browser will open automatically at `http://localhost:8765`.

#### 📱 Using with Xcode Simulator (iOS Simulator):
- **The Xcode Hassle:** By default, changing coordinates in Apple's Simulator requires going to `Features > Location > Custom Location...` and manually typing latitude/longitude decimal digits every time, with no visual map or address search.
- **With FakeGPS:** Just keep your Simulator open (`booted`). FakeGPS automatically detects it! Search any address or click anywhere on the interactive map to teleport the Simulator immediately.

#### 🔌 Using with Physical iPhone via USB:
- Simply plug your iPhone in via USB, tap "Trust This Computer", and spoof as usual. *(macOS natively includes Apple's USB communication drivers).*

---

## 📱 iPhone Setup

1. **USB Trust:** Connect your iPhone via USB, unlock the screen, tap **"Trust This Computer"**, and enter your passcode.
2. **Developer Mode (iOS 16+):**
   * Go to **Settings** → **Privacy & Security** → **Developer Mode**.
   * Toggle it **On** and follow the prompt to reboot your device.

---

## 🛠️ Building Packages Locally

To rebuild the Debian package locally on Linux:
```bash
./build-deb.sh
```

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the [issues page](https://github.com/maxxcleiton/fakegps-iphone-web/issues).

---

## 📄 License

Open source under the [MIT License](LICENSE).
