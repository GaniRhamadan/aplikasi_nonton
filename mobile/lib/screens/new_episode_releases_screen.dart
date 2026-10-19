import 'package:flutter/material.dart';
import '../models/anime_models.dart';
import '../services/anime_service.dart';
import '../theme/app_theme.dart';
import '../widgets/responsive_layout.dart';
import 'anime_detail_screen.dart';
import 'search_screen.dart';

class NewEpisodeReleasesScreen extends StatefulWidget {
  final String title;
  final List<AnimeItem>? initialItems;

  const NewEpisodeReleasesScreen({
    super.key,
    this.title = 'New Episode Releases',
    this.initialItems,
  });

  @override
  State<NewEpisodeReleasesScreen> createState() =>
      _NewEpisodeReleasesScreenState();
}

class _NewEpisodeReleasesScreenState extends State<NewEpisodeReleasesScreen> {
  final AnimeService _animeService = AnimeService();
  List<AnimeItem> _releasesList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialItems != null && widget.initialItems!.isNotEmpty) {
      _releasesList = widget.initialItems!;
      _isLoading = false;
    } else {
      _loadDynamicData();
    }
  }

  Future<void> _loadDynamicData() async {
    setState(() => _isLoading = true);
    try {
      final fetched = await _animeService.getEpisodeBaru();
      if (mounted) {
        setState(() {
          _releasesList = fetched;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _openSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SearchScreen(),
      ),
    );
  }

  void _navigateToDetail(AnimeItem anime) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnimeDetailScreen(anime: anime),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(
              Icons.search_rounded,
              color: AppColors.textPrimary,
              size: 26,
            ),
            onPressed: _openSearch,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            )
          : _releasesList.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.movie_outlined, size: 48, color: AppColors.textMuted),
                      const SizedBox(height: 12),
                      Text(
                        'Belum ada rilis episode baru',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: _loadDynamicData,
                        icon: const Icon(Icons.refresh, color: AppColors.accent),
                        label: const Text('Muat Ulang', style: TextStyle(color: AppColors.accent)),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: ResponsiveLayout.gridColumns(context),
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.70,
                  ),
                  itemCount: _releasesList.length,
                  itemBuilder: (context, index) {
          final anime = _releasesList[index];
          final rating =
              (anime.score != null && anime.score!.isNotEmpty && anime.score != '0')
                  ? anime.score!
                  : (9.7 - (index * 0.1)).toStringAsFixed(1);
          final episodeText = anime.episodeLabel != null && anime.episodeLabel!.isNotEmpty
              ? anime.episodeLabel!
              : 'Episode 01';

          return GestureDetector(
            onTap: () => _navigateToDetail(anime),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: AppColors.surfaceHighlight,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  children: [
                    // Poster image filling the card
                    Positioned.fill(
                      child: Image.network(
                        anime.posterUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AppColors.surfaceHighlight,
                          child: const Center(
                            child: Icon(
                              Icons.movie_outlined,
                              color: Colors.white24,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Dark gradient overlay at the bottom for text contrast
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: const [0.50, 1.0],
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.85),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Green Rating Badge in Top Left
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          rating,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),

                    // Episode Label at Bottom Left
                    Positioned(
                      bottom: 8,
                      left: 8,
                      right: 8,
                      child: Text(
                        episodeText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          shadows: [
                            Shadow(
                              color: Colors.black87,
                              blurRadius: 4,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
