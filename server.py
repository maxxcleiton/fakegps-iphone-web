"""
FakeGPS iPhone — Servidor Web Local
Compatível com iOS 12 até iOS 18 / iOS 26+
Conexão persistente direta via API Python (pymobiledevice3)
"""

import asyncio
import logging
import os
import re
import shutil
import sys
import webbrowser
from contextlib import AsyncExitStack, asynccontextmanager
from pathlib import Path
from typing import Optional

import uvicorn
from fastapi import FastAPI, HTTPException
from fastapi.responses import FileResponse
from pydantic import BaseModel

from pymobiledevice3.usbmux import select_devices_by_connection_type
from pymobiledevice3.lockdown import create_using_usbmux
from pymobiledevice3.remote import userspace_tunnel
from pymobiledevice3.services.dvt.instruments.dvt_provider import DvtProvider
from pymobiledevice3.services.dvt.instruments.location_simulation import LocationSimulation

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    handlers=[logging.StreamHandler()],
)
log = logging.getLogger("fakegps")

MODEL_NAMES = {
    "iPhone13,1": "iPhone 12 mini",
    "iPhone13,2": "iPhone 12",
    "iPhone13,3": "iPhone 12 Pro",
    "iPhone13,4": "iPhone 12 Pro Max",
    "iPhone14,2": "iPhone 13 Pro",
    "iPhone14,3": "iPhone 13 Pro Max",
    "iPhone14,4": "iPhone 13 mini",
    "iPhone14,5": "iPhone 13",
    "iPhone14,7": "iPhone 14",
    "iPhone14,8": "iPhone 14 Plus",
    "iPhone15,2": "iPhone 14 Pro",
    "iPhone15,3": "iPhone 14 Pro Max",
    "iPhone15,4": "iPhone 15",
    "iPhone15,5": "iPhone 15 Plus",
    "iPhone16,1": "iPhone 15 Pro",
    "iPhone16,2": "iPhone 15 Pro Max",
    "iPhone17,1": "iPhone 16 Pro",
    "iPhone17,2": "iPhone 16 Pro Max",
    "iPhone17,3": "iPhone 16",
    "iPhone17,4": "iPhone 16 Plus",
}


class LocationManager:
    def __init__(self):
        self.lock = asyncio.Lock()
        self.stack: Optional[AsyncExitStack] = None
        self.loc_sim: Optional[LocationSimulation] = None

        self.serial: Optional[str] = None
        self.device_name: str = "iPhone"
        self.ios_version: str = ""
        self.is_simulator: bool = False
        self.status: str = "disconnected"  # disconnected | connected | simulating | error
        self.status_msg: str = "Aguardando dispositivo..."
        self.current_lat: Optional[float] = None
        self.current_lng: Optional[float] = None
        self.keep_alive: bool = True
        self.refresh_interval: float = max(0.5, float(os.environ.get("GPS_REFRESH_INTERVAL", "2.0")))

    async def detect_simulator(self) -> Optional[tuple[str, str]]:
        """Verifica se há um Simulador do Xcode aberto no macOS (status Booted)."""
        if sys.platform != "darwin" or not shutil.which("xcrun"):
            return None
        try:
            proc = await asyncio.create_subprocess_exec(
                "xcrun", "simctl", "list", "devices", "booted",
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE,
            )
            stdout, _ = await proc.communicate()
            if proc.returncode != 0:
                return None

            output = stdout.decode("utf-8", errors="replace")
            for line in output.splitlines():
                line = line.strip()
                if "(Booted)" in line:
                    m = re.match(r"^(.*?)\s*\(([A-F0-9\-]+)\)\s*\(Booted\)", line, re.IGNORECASE)
                    if m:
                        name = m.group(1).strip()
                        udid = m.group(2).strip()
                        return (name, udid)
                    return ("iPhone", "booted")
        except Exception as e:
            log.debug("Erro ao verificar simulador: %s", e)
        return None

    async def detect_device(self):
        """Verifica se há um iPhone físico via USB ou Simulador do Xcode (macOS)."""
        # 1. Tenta detectar iPhone físico na USB
        try:
            devices = await select_devices_by_connection_type(connection_type="USB")
            if devices:
                device = devices[0]
                was_simulator = self.is_simulator
                self.is_simulator = False
                self.serial = device.serial

                if self.status == "disconnected" or not self.ios_version or was_simulator:
                    try:
                        ld = await create_using_usbmux(serial=self.serial)
                        raw_type = getattr(ld, "product_type", "iPhone")
                        self.device_name = MODEL_NAMES.get(raw_type, raw_type)
                        self.ios_version = str(getattr(ld, "product_version", ""))
                        if self.status != "simulating":
                            self.status = "connected"
                            self.status_msg = f"{self.device_name} (iOS {self.ios_version}) Conectado via USB"
                        log.info(
                            "Dispositivo USB detectado: %s (iOS %s) [%s]",
                            self.device_name,
                            self.ios_version,
                            self.serial,
                        )
                    except Exception as e:
                        log.warning("Falha ao ler lockdown info: %s", e)
                        self.status = "connected"
                        self.status_msg = "iPhone Conectado via USB (aguardando liberação de tela)"
                return device
        except Exception as e:
            log.debug("Erro ao verificar USB: %s", e)

        # 2. Se no macOS, tenta detectar Simulador do Xcode aberto
        sim_info = await self.detect_simulator()
        if sim_info:
            sim_name, sim_udid = sim_info
            self.is_simulator = True
            self.serial = sim_udid
            self.device_name = f"{sim_name} (Simulador)"
            self.ios_version = "Simulator"
            if self.status != "simulating":
                self.status = "connected"
                self.status_msg = f"{self.device_name} Conectado"
            return "simulator"

        # 3. Nenhum dispositivo encontrado
        if self.status != "disconnected":
            log.info("Dispositivo desconectado.")
            await self._reset_internal(clean=False)
        self.status = "disconnected"
        if sys.platform == "darwin":
            self.status_msg = "Aguardando iPhone via USB ou Simulador do Xcode aberto..."
        else:
            self.status_msg = "Nenhum iPhone conectado na USB."
        return None

    async def ensure_connected(self):
        """Garante que a sessão de simulação está pronta."""
        if self.is_simulator:
            return

        if self.loc_sim is not None:
            return

        device = await self.detect_device()
        if self.is_simulator:
            return

        if not device or not self.serial:
            raise RuntimeError("Nenhum iPhone detectado via USB ou Simulador aberto.")

        log.info("Iniciando sessão DVT com o iPhone %s...", self.serial)
        self.status_msg = "Iniciando sessão de GPS simulado..."

        new_stack = AsyncExitStack()
        try:
            major = 17
            if self.ios_version:
                try:
                    major = int(self.ios_version.split(".")[0])
                except ValueError:
                    major = 17

            if major >= 17:
                log.info("Estabelecendo tunnel userspace RSD para iOS %s...", self.ios_version)
                rsd = await userspace_tunnel.establish_userspace_rsd(serial=self.serial)
                dvt = await new_stack.enter_async_context(DvtProvider(rsd))
            else:
                log.info("Conectando direto via lockdown para iOS %s...", self.ios_version)
                ld = await create_using_usbmux(serial=self.serial)
                dvt = await new_stack.enter_async_context(DvtProvider(ld))

            loc_sim = await new_stack.enter_async_context(LocationSimulation(dvt))
            self.stack = new_stack
            self.loc_sim = loc_sim
            log.info("Sessão DVT pronta para receber coordenadas.")
        except Exception as e:
            await new_stack.aclose()
            log.exception("Falha ao abrir sessão DVT")
            self.status = "error"
            self.status_msg = f"Erro ao iniciar sessão DVT: {e}"
            raise

    async def _send_location_unlocked(self, lat: float, lng: float):
        """Envia a coordenada para o Simulador ou iPhone USB (deve ser chamado sob self.lock)."""
        await self.ensure_connected()

        if self.is_simulator:
            target = self.serial if self.serial else "booted"
            coords = f"{lat:.6f},{lng:.6f}"
            proc = await asyncio.create_subprocess_exec(
                "xcrun", "simctl", "location", target, "set", coords,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE,
            )
            _, stderr = await proc.communicate()
            if proc.returncode != 0:
                err_msg = stderr.decode("utf-8", errors="replace").strip()
                raise RuntimeError(f"Falha no xcrun simctl: {err_msg}")
        else:
            await self.loc_sim.set(lat, lng)

        self.current_lat = lat
        self.current_lng = lng
        self.status = "simulating"
        self.status_msg = f"GPS Simulado: {lat:.5f}, {lng:.5f}"

    async def set_location(self, lat: float, lng: float, keep_alive: Optional[bool] = None):
        """Aplica a coordenada no iPhone físico ou no Simulador do Xcode."""
        async with self.lock:
            if keep_alive is not None:
                self.keep_alive = keep_alive
            try:
                alvo = "Simulador iOS" if self.is_simulator else "iPhone USB"
                log.info("Enviando coordenadas para %s: %.6f, %.6f", alvo, lat, lng)
                await self._send_location_unlocked(lat, lng)
                log.info("Localização fixada com sucesso!")
            except Exception as e:
                log.exception("Erro ao aplicar localização")
                if not self.is_simulator:
                    await self._reset_internal(clean=False)
                raise RuntimeError(f"Falha ao enviar coordenada: {e}")

    async def refresh_location(self):
        """Reenvia periodicamente a localização ativa para evitar expiração no iOS."""
        async with self.lock:
            if (
                not self.keep_alive
                or self.status != "simulating"
                or self.current_lat is None
                or self.current_lng is None
            ):
                return

            try:
                await self._send_location_unlocked(self.current_lat, self.current_lng)
                log.debug(
                    "GPS reenviado (keep-alive): %.6f, %.6f",
                    self.current_lat,
                    self.current_lng,
                )
            except Exception as e:
                log.warning("Falha ao reenviar GPS (keep-alive): %s", e)
                if not self.is_simulator:
                    await self._reset_internal(clean=False)

    async def set_keep_alive(self, enabled: bool):
        """Atualiza o estado de reenvio automático sem limpar as coordenadas."""
        async with self.lock:
            self.keep_alive = enabled
            log.info("Reenvio automático de GPS (keep-alive): %s", "ativado" if enabled else "desativado")

    async def clear_location(self):
        """Restaura o GPS real do aparelho ou limpa o simulador."""
        async with self.lock:
            if self.is_simulator:
                try:
                    log.info("Limpando simulação de localização no Simulador Xcode...")
                    target = self.serial if self.serial else "booted"
                    proc = await asyncio.create_subprocess_exec(
                        "xcrun", "simctl", "location", target, "clear",
                        stdout=asyncio.subprocess.PIPE,
                        stderr=asyncio.subprocess.PIPE,
                    )
                    await proc.communicate()
                except Exception as e:
                    log.warning("Erro ao limpar localização no simulador: %s", e)
            elif self.loc_sim is not None:
                try:
                    log.info("Limpando simulação de localização...")
                    await self.loc_sim.clear()
                except Exception as e:
                    log.warning("Erro ao chamar clear(): %s", e)

            self.current_lat = None
            self.current_lng = None
            self.status = "connected"
            self.status_msg = f"{self.device_name} Conectado (GPS Restaurado)"
            log.info("GPS restaurado.")

    async def disconnect(self):
        """Encerra a sessão de forma limpa."""
        async with self.lock:
            await self._reset_internal(clean=True)

    async def _reset_internal(self, clean: bool = True):
        if self.is_simulator and clean:
            try:
                target = self.serial if self.serial else "booted"
                proc = await asyncio.create_subprocess_exec(
                    "xcrun", "simctl", "location", target, "clear",
                    stdout=asyncio.subprocess.PIPE,
                    stderr=asyncio.subprocess.PIPE,
                )
                await proc.communicate()
            except Exception:
                pass
        elif self.loc_sim and clean:
            try:
                await self.loc_sim.clear()
            except Exception:
                pass
        if self.stack:
            try:
                await self.stack.aclose()
            except Exception:
                pass
        self.stack = None
        self.loc_sim = None
        self.current_lat = None
        self.current_lng = None
        self.is_simulator = False
        self.status = "disconnected"


manager = LocationManager()


async def background_monitor():
    """Monitora a conexão do iPhone a cada 2.5s."""
    while True:
        try:
            await manager.detect_device()
        except Exception as e:
            log.debug("Monitor loop exception: %s", e)
        await asyncio.sleep(2.5)


async def location_heartbeat():
    """Reenvia periodicamente o GPS simulado para manter o timestamp atualizado no iOS."""
    while True:
        await asyncio.sleep(manager.refresh_interval)
        try:
            await manager.refresh_location()
        except Exception as e:
            log.debug("Location heartbeat exception: %s", e)


def get_resource_path(relative_path: str) -> Path:
    """Retorna o caminho do arquivo, compatível com PyInstaller (.exe) e execução normal."""
    if getattr(sys, "frozen", False) and hasattr(sys, "_MEIPASS"):
        base_path = Path(sys._MEIPASS)
    else:
        base_path = Path(__file__).parent
    return base_path / relative_path


@asynccontextmanager
async def lifespan(app: FastAPI):
    monitor_task = asyncio.create_task(background_monitor())
    heartbeat_task = asyncio.create_task(location_heartbeat())

    # Se executado como .exe compilado (PyInstaller), abre o navegador automaticamente
    if getattr(sys, "frozen", False):
        async def _open_browser():
            await asyncio.sleep(1.2)
            webbrowser.open("http://localhost:8765")

        asyncio.create_task(_open_browser())

    yield
    monitor_task.cancel()
    heartbeat_task.cancel()
    await manager.disconnect()


app = FastAPI(title="FakeGPS iPhone", lifespan=lifespan)


class LocationRequest(BaseModel):
    lat: float
    lng: float
    keep_alive: bool = True


class KeepAliveRequest(BaseModel):
    keep_alive: bool


@app.get("/api/status")
async def api_status():
    return {
        "status": manager.status,
        "message": manager.status_msg,
        "device_name": manager.device_name,
        "ios_version": manager.ios_version,
        "is_simulator": manager.is_simulator,
        "current_lat": manager.current_lat,
        "current_lng": manager.current_lng,
        "keep_alive": manager.keep_alive,
        "refresh_interval": manager.refresh_interval,
    }


@app.post("/api/location")
async def api_set_location(req: LocationRequest):
    if not (-90.0 <= req.lat <= 90.0 and -180.0 <= req.lng <= 180.0):
        raise HTTPException(status_code=400, detail="Coordenadas fora do intervalo válido.")

    try:
        await manager.set_location(req.lat, req.lng, keep_alive=req.keep_alive)
        return {"ok": True, "lat": req.lat, "lng": req.lng, "keep_alive": manager.keep_alive}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/api/keep-alive")
async def api_set_keep_alive(req: KeepAliveRequest):
    await manager.set_keep_alive(req.keep_alive)
    return {"ok": True, "keep_alive": manager.keep_alive}


@app.delete("/api/location")
async def api_clear_location():
    try:
        await manager.clear_location()
        return {"ok": True, "message": "GPS restaurado para localização real."}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/api/reconnect")
async def api_reconnect():
    await manager.disconnect()
    await manager.detect_device()
@app.post("/api/shutdown")
async def api_shutdown():
    log.info("Recebida solicitação para desligar o servidor...")
    async def _stop():
        await asyncio.sleep(0.5)
        os._exit(0)
    asyncio.create_task(_stop())
    return {"ok": True, "message": "Servidor encerrando..."}


@app.get("/")
async def index():
    return FileResponse(get_resource_path("index.html"))


if __name__ == "__main__":
    host = os.environ.get("HOST", "127.0.0.1")
    port = int(os.environ.get("PORT", 8765))
    uvicorn.run(app, host=host, port=port)
