import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/update_service.dart';
import '../theme/app_theme.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  late bool _isDub;
  late String _player;
  late String _quality;
  late String _subLang;

  @override
  void initState() {
    super.initState();
    _isDub = StorageService.isDub;
    _player = StorageService.preferredPlayer;
    _quality = StorageService.quality;
    _subLang = StorageService.subLanguage;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text(
          'Pengaturan',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Section 1: Playback Preferences
          _buildSectionHeader('Preferensi Pemutaran'),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                // Subtitle Language preference
                ListTile(
                  title: const Text(
                    'Bahasa Subtitle Default',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    _subLang == 'id'
                        ? 'Bahasa Indonesia (Terjemahan Otomatis)'
                        : 'English (Teks Asli)',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  trailing: DropdownButton<String>(
                    value: _subLang,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(
                        value: 'id',
                        child: Text('Indonesia (ID)'),
                      ),
                      DropdownMenuItem(
                        value: 'en',
                        child: Text('English (EN)'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _subLang = val);
                        StorageService.setSubLanguage(val);
                      }
                    },
                  ),
                ),
                const Divider(height: 1, color: AppColors.border),

                // Audio preference
                SwitchListTile(
                  title: const Text(
                    'Audio Dubbing (Inggris)',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    _isDub
                        ? 'Memilih audio Dubbing jika tersedia'
                        : 'Memilih audio Subtitle Jepang (Bawaan)',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  value: _isDub,
                  activeThumbColor: AppColors.accent,
                  onChanged: (val) {
                    setState(() => _isDub = val);
                    StorageService.setDub(val);
                  },
                ),
                const Divider(height: 1, color: AppColors.border),

                // Player preference
                ListTile(
                  title: const Text(
                    'Pemutar Video Utama',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    _player == 'internal'
                        ? 'Pemutar Internal Aplikasi (WebView)'
                        : 'Pemutar Eksternal (MPV / VLC)',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  trailing: DropdownButton<String>(
                    value: _player,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(
                        value: 'internal',
                        child: Text('Internal'),
                      ),
                      DropdownMenuItem(
                        value: 'external',
                        child: Text('Eksternal'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _player = val);
                        StorageService.setPreferredPlayer(val);
                      }
                    },
                  ),
                ),
                const Divider(height: 1, color: AppColors.border),

                // Video quality
                ListTile(
                  title: const Text(
                    'Kualitas Video Default',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    'Kualitas: $_quality',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  trailing: DropdownButton<String>(
                    value: _quality,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: '1080p', child: Text('1080p')),
                      DropdownMenuItem(value: '720p', child: Text('720p')),
                      DropdownMenuItem(value: '480p', child: Text('480p')),
                      DropdownMenuItem(value: 'best', child: Text('Terbaik')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _quality = val);
                        StorageService.setQuality(val);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Section 2: ani-cli Core & Scraper
          _buildSectionHeader('Integrasi ani-cli'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.terminal_rounded,
                        color: AppColors.textPrimary, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'ani-cli v5.1.4 Companion',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Aplikasi ini dibuat sebagai antarmuka mobile native yang nyaman untuk ekosistem ani-cli. Menggunakan arsitektur scraping langsung ke HiAnime tanpa iklan yang mengganggu.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Tips Pemutar MPV di Android:',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Jika menggunakan aplikasi MPV Android eksternal, Anda dapat mengatur kontrol gestur geser kecerahan dan volume untuk pengalaman menonton terbaik.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Section 3: App info & Updates
          _buildSectionHeader('Pembaruan & Tentang'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Versi Aplikasi',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'v${UpdateService.currentVersion} (Clean Minimalist)',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(height: 1, color: AppColors.border),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Memeriksa pembaruan aplikasi...'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                      final update = await UpdateService.checkForUpdate();
                      if (context.mounted) {
                        if (update != null) {
                          UpdateService.showUpdateModal(context, update);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Aplikasi Anda sudah versi terbaru (v${UpdateService.currentVersion})!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Periksa Pembaruan Sekarang'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'ani-cli Mobile',
                        applicationVersion: 'v${UpdateService.currentVersion}',
                        applicationIcon: const Icon(Icons.movie_filter_rounded,
                            size: 40, color: AppColors.accent),
                        applicationLegalese:
                            'Lisensi: GNU General Public License v3.0 (GPLv3)\n\n'
                            'Karya turunan dari proyek open-source pystardust/ani-cli.\n'
                            'Hak Cipta (C) 2021-2024 pystardust dan kontributor.\n'
                            'Hak Cipta (C) 2024-2026 Pengembang Mobile.\n\n'
                            'Seluruh kode sumber bebas digunakan, dimodifikasi, dan didistribusikan ulang sesuai dengan ketentuan GNU General Public License v3.0.',
                      );
                    },
                    icon: const Icon(Icons.info_outline_rounded,
                        size: 16, color: AppColors.textSecondary),
                    label: const Text(
                      'Lisensi & Kredit Open Source (GPLv3)',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}
