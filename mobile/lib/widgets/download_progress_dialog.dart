import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Modal dialog displaying active episode download progress.
/// Matches the design from Figma reference screenshot.
class DownloadProgressDialog extends StatefulWidget {
  final int episodeNumber;
  final int totalEpisodes;
  final String resolution;
  final double totalMb;
  final double initialMb;
  final int? initialPercent;
  final bool autoSimulate;
  final VoidCallback? onHide;
  final VoidCallback? onCancel;
  final VoidCallback? onComplete;

  const DownloadProgressDialog({
    super.key,
    this.episodeNumber = 1,
    this.totalEpisodes = 1,
    this.resolution = '720p',
    this.totalMb = 239.5,
    this.initialMb = 122.8,
    this.initialPercent = 47,
    this.autoSimulate = true,
    this.onHide,
    this.onCancel,
    this.onComplete,
  });

  /// Static helper to display the download progress modal dialog.
  static Future<T?> show<T>(
    BuildContext context, {
    int episodeNumber = 1,
    int totalEpisodes = 1,
    String resolution = '720p',
    double totalMb = 239.5,
    double initialMb = 122.8,
    int? initialPercent = 47,
    bool autoSimulate = true,
    VoidCallback? onHide,
    VoidCallback? onCancel,
    VoidCallback? onComplete,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (ctx) => DownloadProgressDialog(
        episodeNumber: episodeNumber,
        totalEpisodes: totalEpisodes,
        resolution: resolution,
        totalMb: totalMb,
        initialMb: initialMb,
        initialPercent: initialPercent,
        autoSimulate: autoSimulate,
        onHide: onHide,
        onCancel: onCancel,
        onComplete: onComplete,
      ),
    );
  }

  @override
  State<DownloadProgressDialog> createState() => _DownloadProgressDialogState();
}

class _DownloadProgressDialogState extends State<DownloadProgressDialog> {
  late double _currentMb;
  bool _hasTicked = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _currentMb = widget.initialMb;

    if (widget.autoSimulate) {
      _startSimulation();
    }
  }

  void _startSimulation() {
    _timer = Timer.periodic(const Duration(milliseconds: 350), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _hasTicked = true;
        if (_currentMb < widget.totalMb) {
          _currentMb = (_currentMb + 1.6).clamp(0.0, widget.totalMb);
        } else {
          timer.cancel();
          _handleCompletion();
        }
      });
    });
  }

  void _handleCompletion() {
    widget.onComplete?.call();
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Episode ${widget.episodeNumber} berhasil diunduh (${widget.resolution})',
          ),
          backgroundColor: AppColors.accent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _handleCancel() {
    _timer?.cancel();
    widget.onCancel?.call();
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Download dibatalkan'),
        backgroundColor: Color(0xFF334155),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleHide() {
    _timer?.cancel();
    widget.onHide?.call();
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Episode ${widget.episodeNumber} sedang diunduh di latar belakang...',
        ),
        backgroundColor: AppColors.surface,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_currentMb / widget.totalMb).clamp(0.0, 1.0);
    final barProgress = (!_hasTicked && widget.initialPercent != null)
        ? (widget.initialPercent! / 100.0).clamp(0.0, 1.0)
        : progress;
    final percent = (!_hasTicked && widget.initialPercent != null)
        ? widget.initialPercent!
        : (progress * 100).toInt();

    return Dialog(
      elevation: 12,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(26, 28, 26, 26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Title "Download" in Emerald Green
            const Text(
              'Download',
              style: TextStyle(
                color: AppColors.accent,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // 2. Subtitle / Status Text
            Text(
              'Episode ${widget.episodeNumber} is still downloading...\nPlease wait or hide the process',
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                height: 1.45,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),

            // 3. Progress Stats Row: "122.8 / 239.5 MB"  and  "47%"
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_currentMb.toStringAsFixed(1)} / ${widget.totalMb.toStringAsFixed(1)} MB',
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '$percent%',
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // 4. Progress Bar + Cancel Cross (✕)
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: barProgress,
                      minHeight: 6.5,
                      backgroundColor: const Color(0xFFE2E8F0),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.accent,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Cancel Icon
                InkWell(
                  onTap: _handleCancel,
                  borderRadius: BorderRadius.circular(16),
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: Color(0xFF334155),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // 5. Hide Button (Soft mint pill background, green text)
            GestureDetector(
              onTap: _handleHide,
              child: Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Center(
                  child: Text(
                    'Hide',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
