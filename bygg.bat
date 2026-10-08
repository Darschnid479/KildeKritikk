@echo off
setlocal EnableExtensions EnableDelayedExpansion
cd /d "%~dp0"
chcp 65001 >nul
color 0B

echo.
echo =====================================================
echo        H A C K E R A N G R E P E T   3 D
echo             GODOT 4 / WINDOWS - KILDEKRITIKK
echo =====================================================
echo.
echo PROSJEKTMAPPE: %CD%
echo.

REM Guard against accidentally running this file inside the older .NET/Blazor folder.
if not exist "project.godot" goto WRONG_FOLDER
if not exist "scenes\Main.tscn" goto WRONG_FOLDER
if not exist "scripts\main.gd" goto WRONG_FOLDER
findstr /C:"run/main_scene=" "project.godot" >nul 2>&1
if errorlevel 1 goto WRONG_FOLDER

echo [OK] Godot-prosjektet har project.godot og startscenen.
echo.
set "GODOT_EXE="

REM Prefer a local portable copy; then search Windows PATH.
for %%F in ("%CD%\Godot_v*-stable_win64.exe" "%CD%\Godot_v*-win64.exe") do (
  if exist "%%~fF" set "GODOT_EXE=%%~fF"
)
if not defined GODOT_EXE (
  for %%N in (godot godot4 Godot) do (
    if not defined GODOT_EXE (
      for /f "delims=" %%P in ('where %%N 2^>nul') do (
        if not defined GODOT_EXE set "GODOT_EXE=%%P"
      )
    )
  )
)

if not defined GODOT_EXE (
  echo [1/4] Godot ikke funnet. Laster ned bærbar Godot 4.5.1...
  powershell -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; $u='https://github.com/godotengine/godot/releases/download/4.5.1-stable/Godot_v4.5.1-stable_win64.exe.zip'; $z=Join-Path (Get-Location) 'Godot-portable.zip'; Invoke-WebRequest -Uri $u -OutFile $z; Expand-Archive -LiteralPath $z -DestinationPath (Get-Location) -Force; Remove-Item $z -Force"
  if errorlevel 1 goto DOWNLOAD_FAILED
  for %%F in ("%CD%\Godot_v*-stable_win64.exe" "%CD%\Godot_v*-win64.exe") do (
    if exist "%%~fF" set "GODOT_EXE=%%~fF"
  )
)
if not defined GODOT_EXE goto DOWNLOAD_FAILED

echo [1/4] Godot: !GODOT_EXE!
set "BUILD_GODOT=!GODOT_EXE!"
set "TRY_CONSOLE=!GODOT_EXE:.exe=_console.exe!"
if exist "!TRY_CONSOLE!" set "BUILD_GODOT=!TRY_CONSOLE!"

echo [2/4] Importerer 3D-prosjektet...
"!BUILD_GODOT!" --headless --path . --import
if errorlevel 1 goto IMPORT_FAILED

echo [3/4] Bygger en Windows EXE dersom eksportmaler er installert...
if not exist "build" mkdir "build"
"!BUILD_GODOT!" --headless --path . --export-release "Windows Desktop" "build\Hackerangrepet.exe"
if errorlevel 1 (
  echo [MERK] Windows-eksport feilet, ofte fordi eksportmaler mangler.
  echo [MERK] Spillet kan likevel kjores direkte med Godot.
) else (
  echo [OK] EXE laget: %CD%\build\Hackerangrepet.exe
)

echo [4/4] Starter 3D-spillet direkte i Godot...
"!GODOT_EXE!" --path . --rendering-method gl_compatibility
if errorlevel 1 echo [FEIL] Spillet stoppet. Kopier feilmeldingen til ChatGPT.
echo.
pause
exit /b 0

:WRONG_FOLDER
echo =====================================================
echo [FEIL] DU ER I FEIL MAPPE ELLER MANGLER PROSJEKTFILER.
echo =====================================================
echo.
echo Denne mappen inneholder ikke et komplett Godot-prosjekt.
echo Hvis du ser Hackerangrepet_NET10_Blazor i stien over,
echo har du startet .bat-filen fra det GAMLE C#-prosjektet.
echo.
echo KORREKT: Pakk ut Godot-ZIPen, ga inn i
 echo   KildeKritikk_Godot_GitHub
echo og dobbeltklikk bygg.bat DER. Ikke kopier bare .bat-filen.
echo.
echo Disse filene ma ligge ved siden av bygg.bat:
echo   project.godot
 echo   scenes\Main.tscn
 echo   scripts\main.gd
echo.
pause
exit /b 2

:DOWNLOAD_FAILED
echo [FEIL] Klarte ikke finne eller laste ned Godot.
echo Last ned fra: https://godotengine.org/download/windows/
echo Legg den utpakkede Godot .exe i prosjektmappen.
pause
exit /b 3

:IMPORT_FAILED
echo [FEIL] Godot fikk ikke importert prosjektet.
echo Send hele feilmeldingen over til ChatGPT.
echo Kontroller spesielt at banen over ikke er Blazor-prosjektet.
pause
exit /b 4