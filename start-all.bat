@echo off
chcp 65001 >nul
cd /d "%~dp0"
echo Starting AstrBot first (OneBot server on port 6199) ...
start "AstrBot" cmd /k call "%~dp0start-astrbot.bat"
timeout /t 8 /nobreak >nul
echo Starting SnowLuma (QQ bridge, WebUI on port 5099) ...
start "SnowLuma" cmd /k call "%~dp0start-snowluma.bat"
echo.
echo Both windows have been launched.
echo   AstrBot  WebUI : http://127.0.0.1:6185
echo   SnowLuma WebUI : http://127.0.0.1:5099
timeout /t 5 /nobreak >nul
