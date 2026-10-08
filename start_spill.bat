@echo off
cd /d "%~dp0"
if exist "build\Hackerangrepet.exe" (
  start "Hackerangrepet" "build\Hackerangrepet.exe"
  exit /b 0
)
call "%~dp0bygg.bat"