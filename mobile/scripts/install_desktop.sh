#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(dirname "$0")"
PROJECT_DIR="$SCRIPT_DIR/.."
cd "$PROJECT_DIR"

echo "=== 1. Membuild Release Anirama Terbaru ==="
if [ "$1" != "--no-build" ]; then
    echo "Membuild release bundle terbaru..."
    flutter build linux --release
fi

echo "=== 2. Memasang ke direktori pengguna (~/.local) ==="
APP_DIR="$HOME/.local/share/anirama"
BIN_DIR="$HOME/.local/bin"
DESKTOP_DIR="$HOME/.local/share/applications"
PIXMAPS_DIR="$HOME/.local/share/pixmaps"

mkdir -p "$APP_DIR"
mkdir -p "$BIN_DIR"
mkdir -p "$DESKTOP_DIR"
mkdir -p "$PIXMAPS_DIR"

for sz in 512x512 256x256 128x128 64x64 32x32; do
    mkdir -p "$HOME/.local/share/icons/hicolor/$sz/apps"
done

# Tutup proses lama jika sedang berjalan agar biner dapat ditimpa
pkill -x anirama 2>/dev/null || true
sleep 0.5

# Salin bundle aplikasi
cp -r --remove-destination build/linux/x64/release/bundle/* "$APP_DIR/"

# Buat symlink di ~/.local/bin
ln -sf "$APP_DIR/anirama" "$BIN_DIR/anirama"

# Pasang Icon di semua resolusi
cp assets/images/app_icon.png "$HOME/.local/share/icons/hicolor/512x512/apps/anirama.png"
cp assets/images/app_icon_256.png "$HOME/.local/share/icons/hicolor/256x256/apps/anirama.png"
cp assets/images/app_icon_128.png "$HOME/.local/share/icons/hicolor/128x128/apps/anirama.png"
cp assets/images/app_icon_64.png "$HOME/.local/share/icons/hicolor/64x64/apps/anirama.png"
cp assets/images/app_icon_32.png "$HOME/.local/share/icons/hicolor/32x32/apps/anirama.png"
cp assets/images/app_icon.png "$PIXMAPS_DIR/anirama.png"

if command -v gtk-update-icon-cache > /dev/null 2>&1; then
    gtk-update-icon-cache -f -t "$HOME/.local/share/icons/hicolor" > /dev/null 2>&1 || true
fi

# Pasang Desktop Shortcut
cat <<EOF > "$DESKTOP_DIR/anirama.desktop"
[Desktop Entry]
Name=Anirama
Comment=Aplikasi Nonton Anime & Streaming HD
Exec=$APP_DIR/anirama %u
Icon=anirama
Terminal=false
Type=Application
Categories=AudioVideo;Video;Player;
Keywords=anime;streaming;video;mpv;anirama;
StartupWMClass=com.anirama.app
EOF

chmod +x "$DESKTOP_DIR/anirama.desktop"

# Update desktop database jika ada
if command -v update-desktop-database > /dev/null 2>&1; then
    update-desktop-database "$DESKTOP_DIR" || true
fi

echo "=== SUKSES DIPASANG! ==="
echo "1. Anirama sekarang sudah terdaftar di menu aplikasi sistem (Super Key / Application Menu)."
echo "2. Atau dapat dijalankan kapan saja lewat terminal tanpa flutter run:"
echo "   anirama &"
