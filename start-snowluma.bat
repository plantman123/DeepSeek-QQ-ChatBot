@echo off
chcp 65001 >nul
title SnowLuma v2.4.2  -  WebUI http://127.0.0.1:5099
cd /d "%~dp0SnowLuma"
echo ============================================================
echo  SnowLuma v2.4.2  (QQ - OneBot v11 bridge)
echo  WebUI : http://127.0.0.1:5099
echo ============================================================
echo.
".\node.exe" ".\index.mjs" %*
echo.
echo [SnowLuma stopped] Press any key to close this window.
pause >nul
