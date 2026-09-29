import 'package:flutter/material.dart';
import '../models/anime_models.dart';
import '../screens/anime_detail_screen.dart';
import '../theme/app_theme.dart';

/// Section Header with White Title and Circular Dark Arrow Button (matching screenshots)
class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onMoreTap;

  const SectionHeader({
    super.key,
    required this.title,
    this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
          ),
          InkWell(
            onTap: onMoreTap ?? () {},
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFF1C1E26),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white70,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Vertical Card for Horizontal Lists (matching screenshots 1, 2, 3, 4)
class AnimeVerticalCard extends StatelessWidget {
  final AnimeItem anime;
  final String? topSubtitle;
  final Color? topSubtitleColor;
  final bool showViews;
  final bool showFavorites;
  final bool showReleaseDate;
  final bool showNewBadge;
  final VoidCallback? onTap;

  const AnimeVerticalCard({
    super.key,
    required this.anime,
    this.topSubtitle,
    this.topSubtitleColor,
    this.showViews = true,
    this.showFavorites = true,
    this.showReleaseDate = false,
    this.showNewBadge = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final subText = topSubtitle ?? anime.displayGenre;

    return SizedBox(
      width: 130,
      child: InkWell(
        onTap: onTap ??
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AnimeDetailScreen(anime: anime),
                ),
              );
            },
        borderRadius: BorderRadius.circular(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Poster with rounded corners
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 130,
                height: 182,
                color: AppColors.surfaceMuted,
                child: anime.posterUrl.isNotEmpty
                    ? Image.network(
                        anime.posterUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                        loadingBuilder: (_, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            color: AppColors.surfaceMuted,
                            child: const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.accent,
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    : _buildPlaceholder(),
              ),
            ),
            const SizedBox(height: 6),

            // Top subtitle (Orange, e.g. "Episode 4" or "Action")
            Text(
              subText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: topSubtitleColor ?? AppColors.accent,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),

            // Anime Title
            Text(
              anime.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 4),

            // First stats row: Release date OR Views
            if (showReleaseDate)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_month_rounded,
                      size: 13,
                      color: AppColors.dateCyan,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        anime.releaseDate ?? '2026-10-03',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.dateCyan,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else if (showViews)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(
                  children: [
                    const Icon(
                      Icons.play_circle_fill_rounded,
                      size: 13,
                      color: AppColors.viewsRed,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        anime.formattedViews,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.viewsRed,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Second stats row: Favorites count
            if (showFavorites)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: AppColors.favYellow,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        anime.formattedFavorites,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.favYellow,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Third stats row: "new !!" badge
            if (showNewBadge || anime.isNew)
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Row(
                  children: const [
                    Icon(
                      Icons.access_time_filled_rounded,
                      size: 12,
                      color: AppColors.badgePurple,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'new !!',
                      style: TextStyle(
                        color: AppColors.badgePurple,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.surfaceMuted,
      child: const Center(
        child: Icon(
          Icons.movie_filter_rounded,
          color: AppColors.textMuted,
          size: 32,
        ),
      ),
    );
  }
}

/// Wide Banner Card with Mini Thumbnail & Stats (matching Screenshot 2 & 4)
class AnimeBannerCard extends StatelessWidget {
  final AnimeItem anime;
  final VoidCallback? onTap;

  const AnimeBannerCard({
    super.key,
    required this.anime,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final banner = anime.bannerUrl != null && anime.bannerUrl!.isNotEmpty
        ? anime.bannerUrl!
        : anime.posterUrl;

    return InkWell(
      onTap: onTap ??
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AnimeDetailScreen(anime: anime),
              ),
            );
          },
      borderRadius: BorderRadius.circular(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Large Wide Banner (aspect 16:9)
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: double.infinity,
              height: 185,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    banner,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.surfaceMuted,
                      child: const Center(
                        child: Icon(Icons.broken_image, color: AppColors.textMuted),
                      ),
                    ),
                  ),
                  // Subtle gradient overlay for cinematic contrast
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.35),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Mini Card & Information row below banner
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Mini poster thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 58,
                  height: 76,
                  child: Image.network(
                    anime.posterUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.surfaceMuted,
                      child: const Icon(Icons.movie, color: AppColors.textMuted),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Title and Meta
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      anime.displayGenre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      anime.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.play_circle_fill_rounded,
                          size: 13,
                          color: AppColors.viewsRed,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          anime.formattedViews,
                          style: const TextStyle(
                            color: AppColors.viewsRed,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: AppColors.favYellow,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          anime.formattedFavorites,
                          style: const TextStyle(
                            color: AppColors.favYellow,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Cuplix Story / Avatar Thumbnail (matching Screenshot 1)
class CuplixAvatar extends StatelessWidget {
  final CuplixItem item;
  final VoidCallback? onTap;

  const CuplixAvatar({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 66,
        height: 66,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF2E3242), width: 1.5),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            item.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: AppColors.surfaceMuted,
              child: const Icon(Icons.person, color: AppColors.textMuted),
            ),
          ),
        ),
      ),
    );
  }
}
