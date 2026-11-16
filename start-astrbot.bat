@echo off
chcp 65001 >nul
title AstrBot v4.29.4  -  WebUI http://127.0.0.1:6185
cd /d "%~dp0AstrBot"
set "PYTHONNOUSERSITE=1"
set "TMP=%~dp0tmp"
set "TEMP=%~dp0tmp"
@REM  rem --- Route GitHub / external HTTP through the local proxy (needed by meme packs / plugin installs) ---
@REM  set "HTTP_PROXY=http://127.0.0.1:7890"
@REM  set "HTTPS_PROXY=http://127.0.0.1:7890"
@REM  set "NO_PROXY=localhost,127.0.0.1,::1"
if not exist "%~dp0tmp" mkdir "%~dp0tmp"
echo ============================================================
echo  AstrBot v4.29.4
echo  WebUI : http://127.0.0.1:6185
echo  OneBot: ws://127.0.0.1:6199/ws
echo ============================================================
echo.
"%~dp0tools\Python312\python.exe" "%~dp0run-astrbot.py" %*
echo.
echo [AstrBot stopped] Press any key to close this window.
pause >nul
