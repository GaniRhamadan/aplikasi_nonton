# Panduan Desktop Anirama (Linux & Windows)

Anirama kini mendukung **Multiplatform**: selain Android, aplikasi kini berjalan secara native di **Linux Desktop** dan **Windows Desktop**.

---

## 🚀 Fitur Khusus Versi Desktop

1. **Responsif Desktop Sidebar**:
   - Jika layar lebar (lebar >= 768px), navigasi otomatis berubah dari *Bottom Navigation Bar* menjadi **Sidebar Navigasi Kiri** yang elegan, modern, dan ergonomis untuk monitor PC / Laptop.
2. **Desktop Video Player Hub (Bebas Iklan & Crash)**:
   - Terintegrasi langsung dengan **MPV Player** (`/usr/bin/mpv` di Linux & `mpv.exe` di Windows) untuk pemutaran video tanpa browser/iklan dengan performa GPU hardware acceleration maksimal.
   - Opsi cadangan untuk membuka di **VLC / Pemutar Video Bawaan Sistem**.
   - Opsi membuka tautan embed di **Browser**.
   - Tombol **Salin Tautan Stream (M3U8)** langsung ke clipboard.
   - Panel pemilihan server cepat (HD-1 CDN, HD-2 CDN, dsb) serta audio (SUB / DUB).
   - Drawer daftar episode lengkap untuk berganti episode dalam 1 klik.
3. **Pemberitahuan Pembaruan Ramah Desktop**:
   - Sistem pembaruan aplikasi otomatis mengalihkan pengguna ke tautan rilis rilis GitHub resmi tanpa mencoba menginstal file APK Android.

---

## 🐧 Menjalankan & Membuild di Linux

### Prasyarat di Linux
Pastikan Flutter dan toolchain Linux terpasang:
```bash
# Untuk Arch Linux
sudo pacman -S clang cmake ninja pkgconf gtk3 mpv

# Untuk Ubuntu / Debian
sudo apt install clang cmake ninja-build pkg-config libgtk-3-dev mpv
```

### 1. Menjalankan Langsung (Mode Debug / Development)
```bash
cd mobile
flutter run -d linux
```

### 2. Membuild Paket Rilis Standalone (.tar.gz)
Cukup jalankan skrip otomatis yang sudah disediakan:
```bash
cd mobile
./scripts/build_desktop_linux.sh
```
Hasil paket rilis yang siap dibagikan ke pengguna Linux:
👉 `mobile/Anirama-Linux-x64.tar.gz`

### 3. Menjalankan Binary Hasil Build
```bash
cd mobile/build/linux/x64/release/bundle
./anirama
```

---

## 🪟 Menjalankan & Membuild di Windows

### Prasyarat di Windows
1. Pasang [Visual Studio Community](https://visualstudio.microsoft.com/) dengan workload:
   - **Desktop development with C++**
2. Pasang [Flutter SDK](https://docs.flutter.dev/get-started/install/windows/desktop)
3. Disarankan memasang [mpv](https://mpv.io/) atau [VLC Media Player](https://www.videolan.org/vlc/).

### 1. Menjalankan Langsung di Windows
Buka Terminal / PowerShell di folder proyek:
```cmd
cd mobile
flutter run -d windows
```

### 2. Membuild Paket Rilis Standalone (.zip)
Jalankan file batch:
```cmd
mobile\scripts\build_desktop_windows.bat
```
Atau via terminal:
```cmd
cd mobile
flutter build windows --release
```
Folder hasil build terletak di:
👉 `mobile\build\windows\x64\runner\Release\`
(Tinggal di-*zip* untuk dibagikan ke pengguna).
