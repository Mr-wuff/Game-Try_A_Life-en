@echo off
chcp 65001 >nul
title Infinite Life Simulator — First-Time Setup
echo.
echo  ╔══════════════════════════════════════════════╗
echo  ║   Infinite Life Simulator — Installer        ║
echo  ║   First-time setup: Python, Ollama, AI Model ║
echo  ╚══════════════════════════════════════════════╝
echo.

REM ── Step 1: Check Python ──
echo [1/4] Checking Python installation...
python --version >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo.
    echo  [ERROR] Python not found!
    echo  Please install Python 3.10 or newer from:
    echo  https://www.python.org/downloads/
    echo.
    echo  IMPORTANT: During installation, check the box
    echo  "Add Python to PATH"
    echo.
    pause
    start https://www.python.org/downloads/
    exit /b 1
)
for /f "tokens=2" %%v in ('python --version 2^>^&1') do echo          Found Python %%v — OK

REM ── Step 2: Install Python dependencies ──
echo.
echo [2/4] Installing Python dependencies...
cd backend
pip install -r requirements.txt --quiet
if %ERRORLEVEL% neq 0 (
    echo  [WARNING] pip install had issues. Trying with --user flag...
    pip install -r requirements.txt --user --quiet
)
cd ..
echo          Dependencies installed — OK

REM ── Step 3: Check / Install Ollama ──
echo.
echo [3/4] Checking Ollama installation...
where ollama >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo.
    echo  [INFO] Ollama not found on this system.
    echo  Opening the Ollama download page...
    echo.
    echo  After installing Ollama, run this script again.
    echo.
    start https://ollama.com/download
    pause
    exit /b 1
)
echo          Ollama found — OK

REM ── Step 4: Pull AI Model ──
echo.
echo [4/4] Downloading AI model...
echo.

REM Check if model already exists
ollama list 2>nul | findstr "llama3.1:8b" >nul 2>nul
if %ERRORLEVEL% equ 0 (
    echo          Model llama3.1:8b already downloaded — OK
    goto :done
)

echo  Downloading llama3.1:8b (~4.7 GB)
echo  This may take 5-30 minutes depending on your internet speed.
echo  Please be patient...
echo.
ollama pull llama3.1:8b
if %ERRORLEVEL% neq 0 (
    echo.
    echo  [ERROR] Model download failed. Please check your internet
    echo  connection and try again.
    pause
    exit /b 1
)

:done
echo.
echo  ╔══════════════════════════════════════════════╗
echo  ║   Installation complete!                     ║
echo  ║                                              ║
echo  ║   To play: double-click  launcher.bat        ║
echo  ║                                              ║
echo  ║   To use a different AI model:               ║
echo  ║   set ILS_MODEL=llama3.2:3b                  ║
echo  ║   (before running launcher.bat)              ║
echo  ╚══════════════════════════════════════════════╝
echo.
pause
