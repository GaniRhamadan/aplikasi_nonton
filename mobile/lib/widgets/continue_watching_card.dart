import 'package:flutter/material.dart';
import '../models/anime_models.dart';
import '../theme/app_theme.dart';
import '../screens/player_screen.dart';

class ContinueWatchingCard extends StatelessWidget {
  final WatchHistoryItem item;
  final VoidCallback? onDismiss;

  const ContinueWatchingCard({
    super.key,
    required this.item,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Create dummy episode and anime to resume
            final anime = AnimeItem(
              id: item.animeId,
              slug: item.animeSlug,
              title: item.animeTitle,
              posterUrl: item.animePoster,
            );
            final episode = EpisodeItem(
              id: '',
              number: item.episodeNumber,
              title: item.episodeTitle,
              slug: item.animeSlug,
            );

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PlayerScreen(
                  anime: anime,
                  initialEpisode: episode,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 56,
                    height: 74,
                    child: item.animePoster.isNotEmpty
                        ? Image.network(
                            item.animePoster,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              color: AppColors.surfaceMuted,
                              child: Icon(Icons.movie,
                                  color: AppColors.textMuted),
                            ),
                          )
                        : Container(
                            color: AppColors.surfaceMuted,
                            child: Icon(Icons.movie,
                                color: AppColors.textMuted),
                          ),
                  ),
                ),
                const SizedBox(width: 14),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.accentMuted,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                  color: AppColors.accentBorder, width: 1),
                            ),
                            child: const Text(
                              'Lanjutkan Tonton',
                              style: TextStyle(
                                color: AppColors.accent,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        item.animeTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Episode ${item.episodeNumber}: ${item.episodeTitle}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Play Button (large 48px touch target)
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.play_arrow_rounded,
                        color: Colors.white, size: 28),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
