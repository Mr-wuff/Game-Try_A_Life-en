@echo off
chcp 65001 >nul
title Infinite Life Simulator

echo.
echo  ╔══════════════════════════════════════════════╗
echo  ║      Infinite Life Simulator — Launcher      ║
echo  ╚══════════════════════════════════════════════╝
echo.

REM ── Pre-flight checks ──
where ollama >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo  [ERROR] Ollama not found. Please run install.bat first.
    pause
    exit /b 1
)

where python >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo  [ERROR] Python not found. Please run install.bat first.
    pause
    exit /b 1
)

REM ── Check model (auto-pull if missing) ──
if not defined ILS_MODEL set ILS_MODEL=llama3.1:8b
echo  [INFO] AI Model: %ILS_MODEL%

ollama list 2>nul | findstr "%ILS_MODEL%" >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo  [INFO] Model %ILS_MODEL% not found. Downloading...
    ollama pull %ILS_MODEL%
)

REM ── Ensure Ollama is running ──
echo  [INFO] Starting Ollama service...
start /B ollama serve >nul 2>nul
timeout /t 2 /nobreak >nul

REM ── Start backend server ──
echo  [INFO] Starting backend server on port 8000...
cd backend
start /B "ILS-Backend" cmd /c "set ILS_MODEL=%ILS_MODEL% && python main.py"
cd ..

REM ── Wait for server to be ready ──
echo  [INFO] Waiting for server...
set RETRIES=0
:wait_loop
timeout /t 1 /nobreak >nul
curl -s http://127.0.0.1:8000/ >nul 2>nul
if %ERRORLEVEL% equ 0 goto :server_ready
set /a RETRIES+=1
if %RETRIES% geq 15 (
    echo  [ERROR] Server failed to start after 15 seconds.
    echo  Check if port 8000 is already in use.
    pause
    exit /b 1
)
goto :wait_loop

:server_ready
echo  [INFO] Server is ready!

REM ── Launch game client ──
echo  [INFO] Launching game...
echo.

if exist "InfiniteLifeSimulator.exe" (
    start "" "InfiniteLifeSimulator.exe"
) else if exist "InfiniteLifeSimulator.x86_64" (
    chmod +x InfiniteLifeSimulator.x86_64 2>nul
    start "" "InfiniteLifeSimulator.x86_64"
) else (
    echo  [WARNING] Game executable not found.
    echo  Please export the Godot project and place the executable
    echo  in this directory.
    echo.
    echo  The backend server is running at http://127.0.0.1:8000
    echo  You can run the game from the Godot editor instead.
)

echo.
echo  ────────────────────────────────────────────────
echo   Game is running!
echo   Keep this window open. Close it to stop the server.
echo  ────────────────────────────────────────────────
echo.
pause

REM ── Cleanup on exit ──
echo  [INFO] Shutting down...
taskkill /f /fi "WINDOWTITLE eq ILS-Backend" >nul 2>nul
taskkill /f /im python.exe /fi "WINDOWTITLE eq ILS-Backend" >nul 2>nul
