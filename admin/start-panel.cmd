@echo off
setlocal
cd /d "%~dp0"
set PORT=3107
start "" "http://127.0.0.1:%PORT%/"
where py >nul 2>nul
if %errorlevel%==0 (
  py -3 no_cache_server.py
  exit /b
)
where python >nul 2>nul
if %errorlevel%==0 (
  python no_cache_server.py
  exit /b
)
echo No encontre Python para abrir el panel local.
echo Abre index.html manualmente o instala Python desde python.org.
pause
