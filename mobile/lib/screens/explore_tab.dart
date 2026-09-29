import 'dart:async';
import 'package:flutter/material.dart';
import '../models/anime_models.dart';
import '../services/anime_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'anime_detail_screen.dart';

class ExploreTab extends StatefulWidget {
  const ExploreTab({super.key});

  @override
  State<ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends State<ExploreTab> {
  final AnimeService _animeService = AnimeService();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  bool _isLoading = false;
  List<AnimeItem> _searchResults = [];
  List<AnimeItem> _popularRecommendations = [];
  String _selectedGenre = 'Semua';

  final List<String> _genres = [
    'Semua',
    'Action',
    'Adventure',
    'Comedy',
    'Demons',
    'Drama',
    'Fantasy',
    'Isekai',
    'Romance',
    'Sci-Fi',
    'Slice of Life',
    'Supernatural',
    'Sports',
    'Mystery',
    'Horror',
  ];

  final List<String> _trendingTags = [
    'Solo Leveling',
    'One Piece',
    'Jujutsu Kaisen',
    'Bleach',
    'Frieren',
    'Demon Slayer',
    'Chainsaw Man',
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialRecommendations();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialRecommendations() async {
    setState(() => _isLoading = true);
    final results = await _animeService.getPalingPopuler();
    if (mounted) {
      setState(() {
        _popularRecommendations = results;
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String text) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      if (text.trim().isNotEmpty) {
        _searchAnime(text.trim());
      } else {
        setState(() {
          _searchResults = [];
        });
      }
    });
  }

  Future<void> _searchAnime(String query) async {
    final clean = query.trim();
    if (clean.isEmpty) return;

    setState(() => _isLoading = true);
    final results = await _animeService.searchAnime(clean);
    if (mounted) {
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    }
  }

  Future<void> _onGenreSelected(String genre) async {
    setState(() {
      _selectedGenre = genre;
    });

    if (genre == 'Semua') {
      _searchController.clear();
      setState(() {
        _searchResults = [];
      });
      return;
    }

    _searchController.text = genre;
    setState(() => _isLoading = true);

    final slug = genre.toLowerCase().replaceAll(' ', '-');
    final results = await _animeService.getAnimeByGenre(slug);
    if (mounted) {
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayList = _searchController.text.trim().isNotEmpty
        ? _searchResults
        : _popularRecommendations;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 32),
          children: [
            // 1. Search Bar (Modern pill search bar)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF141724),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF242838), width: 1.2),
                ),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14),
                      child: Icon(
                        Icons.search_rounded,
                        color: AppColors.accent,
                        size: 22,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Cari anime, genre, judul...',
                          hintStyle: TextStyle(
                            color: Color(0xFF5B6074),
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.close_rounded,
                            size: 18, color: AppColors.textSecondary),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchResults = [];
                            _selectedGenre = 'Semua';
                          });
                        },
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // 2. Horizontal Genre Filter Pills (matching Screenshot 1 style)
            SizedBox(
              height: 36,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _genres.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final genre = _genres[index];
                  final isSelected = _selectedGenre == genre;
                  return InkWell(
                    onTap: () => _onGenreSelected(genre),
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.accent.withValues(alpha: 0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.accent
                              : const Color(0xFF381E18),
                          width: 1.2,
                        ),
                      ),
                      child: Text(
                        genre,
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.accent
                              : const Color(0xFFE56A48),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // 3. Trending Search Chips
            if (_searchController.text.isEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  height: 30,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _trendingTags.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final tag = _trendingTags[index];
                      return GestureDetector(
                        onTap: () {
                          _searchController.text = tag;
                          _searchAnime(tag);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF141724),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: const Color(0xFF222638), width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🔥', style: TextStyle(fontSize: 10)),
                              const SizedBox(width: 4),
                              Text(
                                tag,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Section Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                _searchController.text.trim().isNotEmpty
                    ? 'Hasil Pencarian (${_searchResults.length})'
                    : 'Rekomendasi Anime Populer',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // 4. 3-Column Anime Grid (matching exact Screenshot 1 style)
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.accent,
                    strokeWidth: 2.5,
                  ),
                ),
              )
            else if (displayList.isEmpty)
              Padding(
                padding: const EdgeInsets.all(40),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(Icons.search_off_rounded,
                          size: 48, color: AppColors.textMuted),
                      const SizedBox(height: 12),
                      Text(
                        'Tidak ditemukan anime untuk "${_searchController.text}"',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.46,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: displayList.length,
                  itemBuilder: (context, index) {
                    final anime = displayList[index];
                    final history =
                        StorageService.getHistoryForAnime(anime.id, anime.slug);

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AnimeDetailScreen(anime: anime),
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Poster with smooth rounded corners (matching screenshot 1)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: AspectRatio(
                              aspectRatio: 0.72,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  anime.posterUrl.isNotEmpty
                                      ? Image.network(
                                          anime.posterUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Container(
                                            color: AppColors.surfaceMuted,
                                            child: const Icon(
                                                Icons.movie_filter_rounded,
                                                color: AppColors.textMuted),
                                          ),
                                        )
                                      : Container(
                                          color: AppColors.surfaceMuted,
                                          child: const Icon(
                                              Icons.movie_filter_rounded,
                                              color: AppColors.textMuted),
                                        ),

                                  // Watched badge overlay (Sampai Ep. X)
                                  if (history != null)
                                    Positioned(
                                      top: 4,
                                      left: 4,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.accent,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          'Ep. ${history.episodeNumber}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ),

                                  // Mini bottom progress bar
                                  if (history != null)
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        height: 2.5,
                                        color: Colors.black54,
                                        child: FractionallySizedBox(
                                          alignment: Alignment.centerLeft,
                                          widthFactor: (anime.totalEpisodes >
                                                      0 ||
                                                  history.totalEpisodes > 0)
                                              ? (history.episodeNumber /
                                                      (anime.totalEpisodes > 0
                                                          ? anime.totalEpisodes
                                                          : history
                                                              .totalEpisodes))
                                                  .clamp(0.08, 1.0)
                                              : 0.5,
                                          child: Container(
                                              color: AppColors.accent),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),

                          // Genre in Orange (matching screenshot 1)
                          Text(
                            history != null
                                ? 'Sampai Ep. ${history.episodeNumber}'
                                : anime.displayGenre,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.accent,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),

                          // Title
                          Text(
                            anime.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),

                          // Red Views
                          Row(
                            children: [
                              const Icon(Icons.play_circle_fill_rounded,
                                  size: 12, color: AppColors.viewsRed),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  anime.formattedViews,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.viewsRed,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),

                          // Yellow Favorites
                          Row(
                            children: [
                              const Icon(Icons.star_rounded,
                                  size: 13, color: AppColors.favYellow),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  anime.formattedFavorites,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.favYellow,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
