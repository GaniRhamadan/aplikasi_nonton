import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ota_update/ota_update.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';

class UpdateInfo {
  final String latestVersion;
  final int latestVersionCode;
  final String downloadUrl;
  final String changelog;

  const UpdateInfo({
    required this.latestVersion,
    required this.latestVersionCode,
    required this.downloadUrl,
    required this.changelog,
  });

  factory UpdateInfo.fromJson(Map<String, dynamic> json) {
    return UpdateInfo(
      latestVersion: json['latest_version'] ?? '1.0.0',
      latestVersionCode: json['version_code'] ?? 1,
      downloadUrl: json['download_url'] ?? '',
      changelog: json['changelog'] ?? 'Pembaruan stabilitas dan performa aplikasi.',
    );
  }
}

class UpdateService {
  /// Current installed version of AniMobile
  static const String currentVersion = '1.0.2';
  static const int currentVersionCode = 3;

  /// Default update manifest endpoint (hosted on user's GitHub repo)
  static const String defaultUpdateUrl =
      'https://raw.githubusercontent.com/GaniRhamadan/aplikasi_nonton/master/mobile/version.json';

  /// Check whether an update is available
  static Future<UpdateInfo?> checkForUpdate({String? customManifestUrl}) async {
    final url = customManifestUrl ?? defaultUpdateUrl;

    try {
      final response = await http
          .get(Uri.parse(url), headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final info = UpdateInfo.fromJson(data);

        // Check if remote version is newer than current version
        if (info.latestVersionCode > currentVersionCode &&
            info.downloadUrl.isNotEmpty) {
          return info;
        }
      }
    } catch (_) {
      // Silently ignore if offline or server unreachable
    }
    return null;
  }

  /// Show the in-app update dialog with live download progress
  static void showUpdateModal(BuildContext context, UpdateInfo updateInfo) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _UpdateDialog(updateInfo: updateInfo),
    );
  }
}

class _UpdateDialog extends StatefulWidget {
  final UpdateInfo updateInfo;

  const _UpdateDialog({required this.updateInfo});

  @override
  State<_UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<_UpdateDialog> {
  bool _isDownloading = false;
  int _downloadProgress = 0;
  String _statusMessage = '';
  StreamSubscription<OtaEvent>? _otaSubscription;

  @override
  void dispose() {
    _otaSubscription?.cancel();
    super.dispose();
  }

  void _startDownload() {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0;
      _statusMessage = 'Menghubungkan ke server pembaruan...';
    });

    try {
      _otaSubscription = OtaUpdate()
          .execute(
        widget.updateInfo.downloadUrl,
        destinationFilename: 'AniMobile.apk',
      )
          .listen(
        (OtaEvent event) {
          if (!mounted) return;
          switch (event.status) {
            case OtaStatus.DOWNLOADING:
              setState(() {
                _downloadProgress = int.tryParse(event.value ?? '0') ?? 0;
                _statusMessage = 'Mengunduh pembaruan: $_downloadProgress%';
              });
              break;
            case OtaStatus.INSTALLING:
              setState(() {
                _statusMessage = 'Membuka pemasang aplikasi sistem...';
              });
              break;
            case OtaStatus.INSTALLATION_DONE:
              if (mounted) {
                Navigator.pop(context);
              }
              break;
            case OtaStatus.ALREADY_RUNNING_ERROR:
            case OtaStatus.PERMISSION_NOT_GRANTED_ERROR:
            case OtaStatus.INTERNAL_ERROR:
            case OtaStatus.DOWNLOAD_ERROR:
            case OtaStatus.CHECKSUM_ERROR:
            default:
              _fallbackBrowserDownload();
              break;
          }
        },
        onError: (_) {
          _fallbackBrowserDownload();
        },
      );
    } catch (_) {
      _fallbackBrowserDownload();
    }
  }

  Future<void> _fallbackBrowserDownload() async {
    if (!mounted) return;
    setState(() {
      _statusMessage = 'Mengalihkan unduhan ke browser / unduhan sistem...';
    });
    try {
      final uri = Uri.parse(widget.updateInfo.downloadUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.accentMuted,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.system_update_rounded,
                color: AppColors.accent, size: 24),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Pembaruan Tersedia',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Version badge comparison
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'v${UpdateService.currentVersion}',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Icon(Icons.arrow_forward_rounded,
                    size: 14, color: AppColors.textMuted),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentMuted,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'v${widget.updateInfo.latestVersion}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          const Text(
            'Catatan Pembaruan:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.canvas,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              widget.updateInfo.changelog,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),

          if (_isDownloading) ...[
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: _downloadProgress > 0 ? _downloadProgress / 100 : null,
              backgroundColor: AppColors.surfaceMuted,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
              borderRadius: BorderRadius.circular(4),
              minHeight: 6,
            ),
            const SizedBox(height: 8),
            Text(
              _statusMessage,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
      actions: [
        if (!_isDownloading) ...[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Nanti Saja',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: _startDownload,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Perbarui Sekarang'),
          ),
        ] else ...[
          TextButton(
            onPressed: () {
              _otaSubscription?.cancel();
              _fallbackBrowserDownload();
            },
            child: const Text(
              'Unduh via Browser',
              style: TextStyle(fontSize: 12, color: AppColors.accent),
            ),
          ),
        ],
      ],
    );
  }
}
