@echo off
setlocal
cd /d "%~dp0"
title Trading Bot - Starter

echo ============================================
echo   Trading Bot wird gestartet...
echo ============================================
echo.

REM --- 1. Ollama (lokale KI) sicherstellen -----------------------------
echo [1/3] Pruefe Ollama (lokale KI)...
curl -s -o nul -w "" http://localhost:11434/api/tags >nul 2>&1
if errorlevel 1 (
    echo       Ollama laeuft noch nicht -^> starte es im Hintergrund...
    start "Ollama" /min ollama serve
    timeout /t 3 /nobreak >nul
) else (
    echo       Ollama laeuft bereits.
)
echo.

REM --- 2. Backend (der eigentliche Bot: Analyse, MT5-Trading, Scheduler) ---
echo [2/3] Starte Backend (Bot-Logik, Port 8000)...
netstat -ano | findstr ":8000" | findstr "LISTENING" >nul 2>&1
if errorlevel 1 (
    start "Trading Bot - Backend" cmd /k "cd /d "%~dp0backend" && "%~dp0.venv\Scripts\python.exe" -m uvicorn app.main:app --port 8000"
    timeout /t 3 /nobreak >nul
) else (
    echo       Backend laeuft bereits auf Port 8000.
)
echo.

REM --- 3. Frontend (das Dashboard im Browser) --------------------------
echo [3/3] Starte Dashboard (Port 5173)...
netstat -ano | findstr ":5173" | findstr "LISTENING" >nul 2>&1
if errorlevel 1 (
    start "Trading Bot - Dashboard" cmd /k "cd /d "%~dp0frontend" && npm run dev"
    timeout /t 5 /nobreak >nul
) else (
    echo       Dashboard laeuft bereits auf Port 5173.
)
echo.

echo Oeffne Dashboard im Browser...
start "" "http://localhost:5173"

echo.
echo ============================================
echo   Fertig! Zwei Fenster sind offen geblieben
echo   (Backend + Dashboard) - die muessen laufen
echo   bleiben, damit der Bot aktiv ist. Dieses
echo   Fenster kannst du schliessen.
echo.
echo   MetaTrader 5 verbindet sich automatisch
echo   im Hintergrund, sobald der Bot das erste
echo   Mal einen Scan macht (kann bis zu 15 Min.
echo   dauern, oder "Jetzt scannen" im Dashboard
echo   klicken).
echo ============================================
echo.
pause
