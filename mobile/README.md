# ani-cli Mobile (Android) 📱

A modern, fast, and minimalist Android client for **[ani-cli](https://github.com/pystardust/ani-cli)**, built with Flutter.

---

## 🌟 Fitur Utama
- **⚡ Super Fast Stream Resolving**: Scraping langsung ke sumber video dengan server otomatis (Megaplay HD-1, HD-2, StreamSB, Streamtape) tanpa iklan mengganggu.
- **🏷️ Multi-Genre Filtering**: Filter anime berdasarkan kombinasi lebih dari satu genre (misal: *Romance + Harem*) dengan logika *AND* yang akurat.
- **🇮🇩 Pilihan Subtitle**: Mendukung subtitle Bahasa Indonesia dan English.
- **🎬 Pemutar Fleksibel**: Pemutar video bawaan (in-app) atau menggunakan pemutar eksternal favorit Anda seperti **MPV** atau **VLC**.
- **🔄 In-App OTA Update**: Notifikasi pembaruan langsung dari dalam aplikasi dan unduhan APK otomatis tanpa perlu instal manual via kabel.

---

## 📜 Lisensi & Atribusi (GPLv3)

Aplikasi ini merupakan karya turunan (*derivative work*) dari proyek open-source:
- **Proyek Asli**: [pystardust/ani-cli](https://github.com/pystardust/ani-cli)
- **Pembuat Asli**: `pystardust` dan para kontributor `ani-cli`.
- **Lisensi**: **GNU General Public License v3.0 (GPLv3)**.

Sesuai dengan ketentuan GPLv3:
1. Seluruh kode sumber aplikasi ini bersifat **Free & Open Source**.
2. Modifikasi dan penambahan fitur dirilis di bawah lisensi yang sama (**GPLv3**).
3. Hak cipta asli tetap diakui dan dicantumkan pada file [LICENSE](../LICENSE).

---

## 🛠️ Cara Build dari Source

### Kebutuhan:
- Flutter SDK (v3.29.0 atau yang lebih baru)
- Android SDK (API 34 / Java 17)

### Langkah Build APK:
```bash
# Masuk ke direktori mobile
cd mobile

# Unduh dependensi
flutter pub get

# Build APK Debug / Release
flutter build apk --debug
# atau
flutter build apk --release
```
File APK akan berada di `build/app/outputs/flutter-apk/`.
