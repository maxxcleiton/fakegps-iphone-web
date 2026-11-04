@echo off
chcp 65001 >nul
title FakeGPS iPhone

echo ====================================================
echo             FakeGPS iPhone - Windows
echo ====================================================
echo.

:: 1. Verifica se o Python esta instalado
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERRO] Python 3 nao encontrado!
    echo Por favor, instale o Python em https://www.python.org/downloads/
    echo IMPORTANTE: Marque a opcao "Add python.exe to PATH" durante a instalacao.
    echo.
    pause
    exit /b 1
)

:: 2. Cria o ambiente virtual caso nao exista
if not exist ".venv" (
    echo [*] Criando ambiente virtual Python (.venv)...
    python -m venv .venv
    if %errorlevel% neq 0 (
        echo [ERRO] Falha ao criar o virtualenv.
        pause
        exit /b 1
    )
)

:: 3. Instala/Atualiza as dependencias
echo [*] Verificando dependencias...
.venv\Scripts\python.exe -m pip install --upgrade pip >nul 2>&1
.venv\Scripts\pip.exe install -r requirements.txt >nul 2>&1

:: 4. Avisos importantes sobre o iPhone no Windows
echo.
echo [DICA] No Windows, certifique-se de ter o aplicativo "Dispositivos Apple"
echo        (da Microsoft Store) ou o "iTunes" instalado para os drivers USB.
echo.
echo [*] Iniciando servidor em http://localhost:8765 ...
echo [*] Conecte o iPhone via USB e clique em "Confiar neste Computador".
echo.

:: 5. Abre o navegador padrao apos 2 segundos
start "" cmd /c "timeout /t 2 /nobreak >nul & start http://localhost:8765"

:: 6. Inicia o servidor Python
.venv\Scripts\python.exe server.py

pause
