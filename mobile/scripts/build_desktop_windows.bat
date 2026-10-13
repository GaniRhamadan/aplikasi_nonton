@echo off
REM === Build Script Anirama untuk Windows Desktop ===

echo ==============================================
echo  Building Anirama for Windows Desktop (Release)
echo ==============================================

cd /d "%~dp0\.."

REM 1. Ambil dependensi
call flutter pub get

REM 2. Build release binary untuk Windows
call flutter build windows --release

if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Gagal membuild Anirama untuk Windows!
    exit /b %ERRORLEVEL%
)

set DIST_DIR=build\windows\x64\runner\Release
set ZIP_NAME=Anirama-Windows-x64.zip

echo ==============================================
echo  Packaging Windows Release ke %ZIP_NAME%...
echo ==============================================

powershell -Command "Compress-Archive -Path '%DIST_DIR%\*' -DestinationPath '%ZIP_NAME%' -Force"

echo ==============================================
echo  SUKSES! Paket Windows tersimpan di:
echo  mobile\%ZIP_NAME%
echo ==============================================
pause
