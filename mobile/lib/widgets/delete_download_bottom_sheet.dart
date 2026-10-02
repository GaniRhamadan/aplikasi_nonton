import 'package:flutter/material.dart';
import '../models/anime_models.dart';
import '../theme/app_theme.dart';

/// Modal bottom sheet confirmation dialog when deleting an episode from downloads.
/// Pixel-perfect implementation matching Figma screenshot:
/// - Rounded top sheet with top drag handle
/// - Red "Delete" header title
/// - Subtle horizontal divider
/// - Confirmation question: "Are you sure you want to delete this download?"
/// - Episode preview card with thumbnail, play button, title, episode, and size pill
/// - Dual action pill buttons: [Cancel] (soft mint/green text) and [Yes, Delete] (emerald green/white text)
class DeleteDownloadBottomSheet extends StatelessWidget {
  final DownloadItem item;

  const DeleteDownloadBottomSheet({
    super.key,
    required this.item,
  });

  /// Displays the confirmation bottom sheet and returns true if deletion was confirmed.
  static Future<bool?> show(BuildContext context, DownloadItem item) {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => DeleteDownloadBottomSheet(item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    final episodeText = item.episodeTitle.isNotEmpty
        ? item.episodeTitle
        : (item.episodeNumber >= 100
            ? 'Episode ${item.episodeNumber}'
            : 'Episode ${item.episodeNumber.toString().padLeft(2, '0')}');

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Top Drag Handle
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.isDarkMode
                        ? Colors.white24
                        : const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // 2. Title "Delete" in Red/Coral
              const Text(
                'Delete',
                style: TextStyle(
                  color: Color(0xFFF75555),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 16),

              // 3. Subtle horizontal hairline divider
              Divider(
                color: AppColors.border,
                thickness: 1,
                height: 1,
              ),
              const SizedBox(height: 20),

              // 4. Confirmation Question
              Text(
                'Are you sure you want to delete this\ndownload?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16.5,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 22),

              // 5. Episode Summary Preview Card
              Container(
                padding: EdgeInsets.zero,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Video Thumbnail with White Play Button Overlay
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: SizedBox(
                        width: 120,
                        height: 74,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            item.animePoster.isNotEmpty
                                ? Image.network(
                                    item.animePoster,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Container(
                                      color: AppColors.surfaceHighlight,
                                      child: const Icon(
                                        Icons.movie_rounded,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  )
                                : Container(
                                    color: AppColors.surfaceHighlight,
                                    child: const Icon(
                                      Icons.movie_rounded,
                                      color: Colors.grey,
                                    ),
                                  ),

                            // Subtle dark gradient
                            Container(
                              color: Colors.black.withValues(alpha: 0.18),
                            ),

                            // Centered Circular White Play Button
                            Center(
                              child: Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.92),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.28),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.play_arrow_rounded,
                                    color: Color(0xFF1E232A),
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Episode Title, Number, and Size Pill
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.animeTitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            episodeText,
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3.5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${item.sizeMb.toStringAsFixed(1)} MB',
                              style: const TextStyle(
                                color: AppColors.accent,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),

              // 6. Dual Action Buttons: [Cancel] & [Yes, Delete]
              Row(
                children: [
                  // Cancel Button (Soft Mint background, Emerald green text)
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.isDarkMode
                              ? const Color(0xFF1B2E23)
                              : const Color(0xFFE8F9EE),
                          foregroundColor: AppColors.accent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Yes, Delete Button (Solid Emerald Green background, White text)
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text(
                          'Yes, Delete',
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
