#!/bin/bash
# Script untuk memasang atau mengirimkan APK Anirama ke HP Android

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
APK_PATH="$DIR/mobile/build/app/outputs/flutter-apk/app-debug.apk"

echo "==> Mengompilasi APK Anirama terbaru (flutter build apk --debug)..."
cd "$DIR/mobile" && flutter build apk --debug
if [ $? -ne 0 ]; then
    echo "Gagal membangun APK. Periksa error di atas."
    exit 1
fi
cd "$DIR"

echo "Mendeteksi perangkat Android yang terhubung..."
adb devices -l

echo ""
echo "Mengirimkan APK ke folder Download di HP..."
adb -d push "$APK_PATH" /sdcard/Download/Anirama.apk

echo ""
echo "Mencoba menginstal langsung via adb..."
if adb -d install -r "$APK_PATH"; then
    echo "Berhasil menginstal Anirama langsung ke ponsel!"
else
    echo "Instalasi via ADB dibatasi oleh sistem MIUI/HyperOS."
    echo "Silakan buka aplikasi 'Pengelola File (File Manager)' di HP Anda,"
    echo "masuk ke folder 'Download', dan klik 'Anirama.apk' untuk menginstalnya."
fi
