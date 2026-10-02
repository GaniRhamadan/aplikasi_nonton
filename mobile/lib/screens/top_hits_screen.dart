import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/anime_models.dart';
import '../services/anime_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'anime_detail_screen.dart';
import 'search_screen.dart';

class TopHitsScreen extends StatefulWidget {
  const TopHitsScreen({super.key});

  @override
  State<TopHitsScreen> createState() => _TopHitsScreenState();
}

class _TopHitsScreenState extends State<TopHitsScreen> {
  final AnimeService _animeService = AnimeService();

  // Curated initial seed list matching the reference screenshot exactly
  static final List<AnimeItem> _initialTopHits = [
    const AnimeItem(
      id: '131681',
      slug: 'shingeki-no-kyojin-the-final-season-part-2',
      title: 'Attack on Titan Final Season Part 2',
      posterUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx131681-5ooUqvqNtee1.jpg',
      score: '9.8',
      releaseDate: '2022',
      genreLabel: 'Japan',
      genres: ['Action fiction', 'Dark fantasy', 'Apocalyptic', 'Drama', 'Shônen'],
      views: '1.2M views',
      status: 'Tamat',
      episodeLabel: 'Episode 28',
    ),
    const AnimeItem(
      id: '142329',
      slug: 'kimetsu-no-yaiba-yuukaku-hen',
      title: 'Demon Slayer: Entertainment District Arc',
      posterUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx142329-kET1PIXJv2eW.jpg',
      score: '9.7',
      releaseDate: '2022',
      genreLabel: 'Japan',
      genres: ['Adventure fiction', 'Dark fantasy', 'Martial Arts', 'Shounen'],
      views: '980K views',
      status: 'Tamat',
      episodeLabel: 'Episode 11',
    ),
    const AnimeItem(
      id: '140960',
      slug: 'spy-x-family',
      title: 'Spy x Family',
      posterUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx140960-Kb6R5nYQfjmP.jpg',
      score: '9.6',
      releaseDate: '2022',
      genreLabel: 'Japan',
      genres: ['Action fiction', 'Comedy', 'Spy fiction', 'Slice of Life'],
      views: '870K views',
      status: 'Ongoing',
      episodeLabel: 'Episode 25',
    ),
    const AnimeItem(
      id: '98861',
      slug: 'quan-zhi-gao-shou-2',
      title: 'The King\'s Avatar Season 2',
      posterUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx98861-MMwQxW1S8WkF.jpg',
      score: '9.5',
      releaseDate: '2021',
      genreLabel: 'Chinese',
      genres: ['Action', 'Superhero', 'Science Fiction', 'Romance', 'Thriller'],
      views: '620K views',
      status: 'Tamat',
      episodeLabel: 'Episode 12',
    ),
    const AnimeItem(
      id: '113415',
      slug: 'jujutsu-kaisen',
      title: 'Jujutsu Kaisen',
      posterUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx113415-LHBAeoZDIsnF.jpg',
      score: '9.6',
      releaseDate: '2020',
      genreLabel: 'Japan',
      genres: ['Action', 'Supernatural', 'Dark Fantasy', 'Shounen'],
      views: '850K views',
      status: 'Ongoing',
      episodeLabel: 'Episode 24',
    ),
    const AnimeItem(
      id: '151807',
      slug: 'solo-leveling',
      title: 'Solo Leveling',
      posterUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx151807-it355ZgzquUd.png',
      score: '9.5',
      releaseDate: '2024',
      genreLabel: 'Japan',
      genres: ['Action', 'Adventure', 'Fantasy', 'Supernatural'],
      views: '790K views',
      status: 'Ongoing',
      episodeLabel: 'Episode 12',
    ),
    const AnimeItem(
      id: '116674',
      slug: 'bleach-sennen-kessen-hen',
      title: 'Bleach: Thousand-Year Blood War',
      posterUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx116674-p3zK4PUX2Aag.jpg',
      score: '9.5',
      releaseDate: '2022',
      genreLabel: 'Japan',
      genres: ['Action', 'Adventure', 'Supernatural', 'Shounen'],
      views: '750K views',
      status: 'Ongoing',
      episodeLabel: 'Episode 13',
    ),
    const AnimeItem(
      id: '154587',
      slug: 'sousou-no-frieren',
      title: 'Frieren: Beyond Journey\'s End',
      posterUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx154587-qQTzQnEJJ3oB.jpg',
      score: '9.8',
      releaseDate: '2023',
      genreLabel: 'Japan',
      genres: ['Adventure', 'Drama', 'Fantasy'],
      views: '910K views',
      status: 'Ongoing',
      episodeLabel: 'Episode 28',
    ),
  ];

  List<AnimeItem> _topHitsList = [];

  @override
  void initState() {
    super.initState();
    _topHitsList = List.from(_initialTopHits);
    _loadDynamicData();
  }

  Future<void> _loadDynamicData() async {
    try {
      final fetched = await _animeService.getPalingPopuler();
      if (mounted && fetched.isNotEmpty) {
        // Merge with seed ensuring the top 4 matching screenshot stay first
        final List<AnimeItem> merged = List.from(_initialTopHits);
        for (var item in fetched) {
          if (!merged.any((m) => m.title.toLowerCase() == item.title.toLowerCase() || m.slug == item.slug)) {
            merged.add(item);
          }
        }
        setState(() {
          _topHitsList = merged;
        });
      }
    } catch (_) {}
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

  void _toggleMyList(AnimeItem anime) async {
    final isBookmarked = await StorageService.toggleBookmark(anime);
    if (!mounted) return;
    HapticFeedback.lightImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isBookmarked ? '✓ Ditambahkan ke My List' : 'Dihapus dari My List',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: isBookmarked ? AppColors.accent : const Color(0xFF334155),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
    setState(() {});
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
          'Top Hits Anime',
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
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: _topHitsList.length,
        separatorBuilder: (context, _) => const SizedBox(height: 18),
        itemBuilder: (context, index) {
          final anime = _topHitsList[index];
          final rank = index + 1;
          final rating = (anime.score != null && anime.score!.isNotEmpty && anime.score != '0')
              ? anime.score!
              : (9.8 - (index * 0.1)).toStringAsFixed(1);

          final year = anime.releaseDate != null && anime.releaseDate!.isNotEmpty
              ? anime.releaseDate!
              : '2022';
          final origin = anime.genreLabel != null && anime.genreLabel!.isNotEmpty
              ? anime.genreLabel!
              : 'Japan';
          final isBookmarked = StorageService.isBookmarked(anime.id, anime.slug);

          return GestureDetector(
            onTap: () => _navigateToDetail(anime),
            behavior: HitTestBehavior.opaque,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Poster Card with Top-left Rating & Bottom-left Rank Number
                SizedBox(
                  width: 114,
                  height: 168,
                  child: Stack(
                    children: [
                      Container(
                        width: 114,
                        height: 168,
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
                          child: Image.network(
                            anime.posterUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: AppColors.surfaceHighlight,
                              child: const Center(
                                child: Icon(
                                  Icons.movie_outlined,
                                  color: Colors.white24,
                                  size: 36,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Rating Badge in Top Left
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

                      // Big Stylized Rank Number in Bottom Left
                      Positioned(
                        bottom: 4,
                        left: 8,
                        child: Text(
                          '$rank',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 1.0,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.95),
                                blurRadius: 6,
                                offset: const Offset(1, 2),
                              ),
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.8),
                                blurRadius: 2,
                                offset: const Offset(-1, -1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 14),

                // 2. Info & Action Button Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        anime.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Year & Country
                      Text(
                        '$year | $origin',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Genres
                      Text(
                        anime.genres.isNotEmpty
                            ? 'Genre: ${anime.genres.join(', ')}'
                            : 'Genre: Action, Fantasy, Adventure, Shounen',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // My List Button matching screenshot
                      InkWell(
                        onTap: () => _toggleMyList(anime),
                        borderRadius: BorderRadius.circular(20),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isBookmarked
                                ? Colors.transparent
                                : AppColors.accent,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.accent,
                              width: 1.3,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isBookmarked
                                    ? Icons.check_rounded
                                    : Icons.add_rounded,
                                color: isBookmarked
                                    ? AppColors.accent
                                    : Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'My List',
                                style: TextStyle(
                                  color: isBookmarked
                                      ? AppColors.accent
                                      : Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
