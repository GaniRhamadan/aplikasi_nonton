import 'package:flutter/material.dart';
import '../models/anime_models.dart';
import '../screens/anime_detail_screen.dart';
import '../screens/player_screen.dart';
import '../theme/app_theme.dart';

class AnimeHistoryCard extends StatelessWidget {
  final WatchHistoryItem item;
  final VoidCallback? onRefresh;
  final VoidCallback? onDelete;

  const AnimeHistoryCard({
    super.key,
    required this.item,
    this.onRefresh,
    this.onDelete,
  });

  String _formatTimestamp(int millis) {
    final dt = DateTime.fromMillisecondsSinceEpoch(millis);
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 60) {
      return diff.inMinutes <= 1 ? 'Baru saja' : '${diff.inMinutes} mnt lalu';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} jam lalu';
    } else if (diff.inDays == 1) {
      return 'Kemarin';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} hari lalu';
    } else {
      return '${dt.day}/${dt.month}/${dt.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final anime = AnimeItem(
      id: item.animeId,
      slug: item.animeSlug,
      title: item.animeTitle,
      posterUrl: item.animePoster,
      totalEpisodes: item.totalEpisodes,
    );

    final nextEpNumber = (item.totalEpisodes > 0 && item.episodeNumber >= item.totalEpisodes)
        ? item.episodeNumber
        : item.episodeNumber + 1;

    final isFinished = item.totalEpisodes > 0 && item.episodeNumber >= item.totalEpisodes;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AnimeDetailScreen(anime: anime),
              ),
            ).then((_) => onRefresh?.call());
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Anime Poster (Clean 3:4 aspect)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 70,
                    height: 98,
                    color: AppColors.surfaceMuted,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        item.animePoster.isNotEmpty
                            ? Image.network(
                                item.animePoster,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Center(
                                  child: Icon(Icons.movie,
                                      color: AppColors.textMuted, size: 28),
                                ),
                              )
                            : Center(
                                child: Icon(Icons.movie,
                                    color: AppColors.textMuted, size: 28),
                              ),

                        // Bottom progress line
                        if (item.totalEpisodes > 0)
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 3,
                              color: Colors.black54,
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: (item.episodeNumber / item.totalEpisodes)
                                    .clamp(0.05, 1.0),
                                child: Container(color: AppColors.accent),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Info & Actions
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        item.animeTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Keterangan Episode Berapa (Pill badge)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: AppColors.accentMuted,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                              color: AppColors.accentBorder, width: 0.8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.play_circle_fill,
                                size: 12, color: AppColors.accent),
                            const SizedBox(width: 4),
                            Text(
                              'Terakhir: Episode ${item.episodeNumber}',
                              style: const TextStyle(
                                color: AppColors.accent,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (item.totalEpisodes > 0)
                              Text(
                                ' / ${item.totalEpisodes}',
                                style: TextStyle(
                                  color: AppColors.accent.withValues(alpha: 0.7),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                      ),

                      if (item.episodeTitle.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.episodeTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11.5,
                          ),
                        ),
                      ],

                      const SizedBox(height: 4),
                      // Timestamp & Watched status
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded,
                              size: 12, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Text(
                            _formatTimestamp(item.timestamp),
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                            ),
                          ),
                          if (item.watchedEpisodes.length > 1) ...[
                            const SizedBox(width: 8),
                            Text(
                              '• ${item.watchedEpisodes.length} ep selesai',
                              style: const TextStyle(
                                color: Color(0xFF34D399),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Quick Action Buttons
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              final targetEp = EpisodeItem(
                                id: '',
                                number: nextEpNumber,
                                title: 'Episode $nextEpNumber',
                                slug: item.animeSlug,
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PlayerScreen(
                                    anime: anime,
                                    initialEpisode: targetEp,
                                  ),
                                ),
                              ).then((_) => onRefresh?.call());
                            },
                            icon: Icon(
                              isFinished ? Icons.replay_rounded : Icons.play_arrow_rounded,
                              size: 16,
                            ),
                            label: Text(
                              isFinished
                                  ? 'Tonton Ulang Ep. ${item.episodeNumber}'
                                  : 'Lanjut Ep. $nextEpNumber',
                              style: const TextStyle(fontSize: 11.5),
                            ),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(0, 32),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                            ),
                          ),
                          const Spacer(),
                          if (onDelete != null)
                            IconButton(
                              icon: Icon(Icons.delete_outline_rounded,
                                  size: 18, color: AppColors.textMuted),
                              tooltip: 'Hapus dari Riwayat',
                              onPressed: onDelete,
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                              padding: EdgeInsets.zero,
                            ),
                        ],
                      ),
                    ],
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
