import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/anime_models.dart';
import '../services/anime_service.dart';
import '../services/storage_service.dart';
import '../services/update_service.dart';
import '../theme/app_theme.dart';
import '../widgets/brand_logo.dart';
import 'anime_detail_screen.dart';
import 'new_episode_releases_screen.dart';
import 'notification_screen.dart';
import 'search_screen.dart';
import 'top_hits_screen.dart';

class HomeTab extends StatefulWidget {
  final Function(int tabIndex)? onNavigateTab;

  const HomeTab({
    super.key,
    this.onNavigateTab,
  });

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final AnimeService _animeService = AnimeService();
  bool _isLoading = true;

  // Curated fallback / seed data matching the reference screenshot
  static final List<AnimeItem> _topHitsSeed = [
    const AnimeItem(
      id: '131681',
      slug: 'shingeki-no-kyojin-the-final-season-part-2',
      title: 'Attack on Titan: Final Season',
      posterUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx131681-odsg4msU11d8.jpg',
      score: '9.8',
      views: '1.2M views',
      status: 'Tamat',
      episodeLabel: 'Episode 28',
    ),
    const AnimeItem(
      id: '101922',
      slug: 'kimetsu-no-yaiba',
      title: 'Demon Slayer: Kimetsu no Yaiba',
      posterUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx101922-WBsBl0ClmgYL.jpg',
      bannerUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/banner/101922-YfZhKfdv9iyi.jpg',
      score: '9.7',
      views: '980K views',
      status: 'Ongoing',
      episodeLabel: 'Episode 11',
    ),
    const AnimeItem(
      id: '140960',
      slug: 'spy-x-family',
      title: 'SPY x FAMILY',
      posterUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx140960-vN3RJZXxDdKy.jpg',
      score: '9.6',
      views: '870K views',
      status: 'Ongoing',
      episodeLabel: 'Episode 25',
    ),
    const AnimeItem(
      id: '113415',
      slug: 'jujutsu-kaisen',
      title: 'Jujutsu Kaisen',
      posterUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx113415-LHBAeoZDIsnF.jpg',
      score: '9.6',
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
      views: '790K views',
      status: 'Ongoing',
      episodeLabel: 'Episode 12',
    ),
    const AnimeItem(
      id: '269',
      slug: 'bleach-sennen-kessen-hen',
      title: 'Bleach: Sennen Kessen-hen',
      posterUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx269-d2GmRkJbMopq.png',
      score: '9.5',
      views: '750K views',
      status: 'Ongoing',
      episodeLabel: 'Episode 13',
    ),
  ];

  static final List<AnimeItem> _newReleasesSeed = [
    const AnimeItem(
      id: '132405',
      slug: 'sono-bisque-doll-wa-koi-wo-suru',
      title: 'My Dress-Up Darling',
      posterUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx132405-z3qjKx9hL7W6.jpg',
      bannerUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/banner/132405-g8tF6s2iH0xP.jpg',
      score: '9.5',
      episodeLabel: 'Episode 12',
      status: 'Ongoing',
    ),
    const AnimeItem(
      id: '125367',
      slug: 'kaguya-sama-wa-kokurasetai-ultra-romantic',
      title: 'Kaguya-sama: Ultra Romantic',
      posterUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx125367-q2mN8z1fB9kH.jpg',
      score: '9.8',
      episodeLabel: 'Episode 13',
      status: 'Ongoing',
    ),
    const AnimeItem(
      id: '137281',
      slug: 'kingdom-4th-season',
      title: 'Kingdom 4th Season',
      posterUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx137281-i4UHcGkUi7j6.jpg',
      score: '9.7',
      episodeLabel: 'Episode 26',
      status: 'Ongoing',
    ),
    const AnimeItem(
      id: '154587',
      slug: 'sousou-no-frieren',
      title: 'Sousou no Frieren',
      posterUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx154587-qQTzQnEJJ3oB.jpg',
      score: '9.8',
      episodeLabel: 'Episode 28',
      status: 'Ongoing',
    ),
  ];

  List<AnimeItem> _featuredList = [];
  List<AnimeItem> _topHits = [];
  List<AnimeItem> _newReleases = [];
  List<AnimeItem> _continueWatching = [];

  final PageController _heroController = PageController();
  int _currentHeroIndex = 0;
  Timer? _heroTimer;

  @override
  void initState() {
    super.initState();
    _loadHomeData();
    _startHeroTimer();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkUpdate();
    });
  }

  void _startHeroTimer() {
    _heroTimer?.cancel();
    _heroTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (_featuredList.isNotEmpty && _heroController.hasClients) {
        final next = (_currentHeroIndex + 1) % _featuredList.length;
        _heroController.animateToPage(
          next,
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _heroTimer?.cancel();
    _heroController.dispose();
    super.dispose();
  }

  Future<void> _checkUpdate() async {
    final update = await UpdateService.checkForUpdate();
    if (mounted && update != null) {
      UpdateService.showUpdateModal(context, update);
    }
  }

  Future<void> _loadHomeData() async {
    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        _animeService.getSedangHangat().catchError((_) => <AnimeItem>[]),
        _animeService.getEpisodeBaru().catchError((_) => <AnimeItem>[]),
        _animeService.getPalingPopuler().catchError((_) => <AnimeItem>[]),
      ]);

      if (mounted) {
        // Continue watching history
        final history = StorageService.getHistory();
        List<AnimeItem> continueList = [];
        if (history.isNotEmpty) {
          continueList = history
              .map((h) => AnimeItem(
                    id: h.animeId,
                    slug: h.animeSlug,
                    title: h.animeTitle,
                    posterUrl: h.animePoster,
                    totalEpisodes: h.totalEpisodes,
                    episodeLabel: 'Sampai Ep. ${h.episodeNumber}',
                  ))
              .toList();
        }

        // Featured Hero List (Demon Slayer first as per screenshot)
        List<AnimeItem> featured = [_topHitsSeed[1]]; // Demon Slayer
        final popular = results[2].isNotEmpty ? results[2] : _topHitsSeed;
        for (var item in popular) {
          if (item.title != _topHitsSeed[1].title && featured.length < 5) {
            featured.add(item);
          }
        }

        // Top Hits
        final topHits = results[0].isNotEmpty ? results[0] : _topHitsSeed;

        // New releases
        final newReleases =
            results[1].isNotEmpty ? results[1] : _newReleasesSeed;

        setState(() {
          _featuredList = featured;
          _topHits = topHits;
          _newReleases = newReleases;
          _continueWatching = continueList;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _featuredList = [_topHitsSeed[1], _topHitsSeed[0], _topHitsSeed[2]];
          _topHits = _topHitsSeed;
          _newReleases = _newReleasesSeed;
          _isLoading = false;
        });
      }
    }
  }

  void _openSearchScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SearchScreen(),
      ),
    );
  }

  void _openNotificationScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NotificationScreen(),
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

  void _playDirectly(AnimeItem anime) {
    // Direct stream without login
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnimeDetailScreen(
          anime: anime,
          autoPlayFirstEpisode: true,
        ),
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
          isBookmarked
              ? '✓ Ditambahkan ke My List'
              : 'Dihapus dari My List',
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
    if (_isLoading && _featuredList.isEmpty && _topHits.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.canvas,
        body: const Center(
          child: BrandDotsSpinner(
            size: 32,
            color: AppColors.accent,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: RefreshIndicator(
        color: AppColors.accent,
        backgroundColor: AppColors.surface,
        onRefresh: _loadHomeData,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // 1. Hero Featured Banner with Floating Header
            SliverToBoxAdapter(
              child: _buildHeroBannerSection(),
            ),

            // 2. Continue Watching (if watch history exists)
            if (_continueWatching.isNotEmpty)
              SliverToBoxAdapter(
                child: _buildContinueWatchingSection(),
              ),

            // 3. "Top Hits Anime" Section (matching screenshot)
            SliverToBoxAdapter(
              child: _buildTopHitsSection(),
            ),

            // 4. "New Episode Releases" Section (matching screenshot)
            SliverToBoxAdapter(
              child: _buildNewReleasesSection(),
            ),

            // Bottom Spacing for Navigation Bar
            const SliverToBoxAdapter(
              child: SizedBox(height: 32),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroBannerSection() {
    final featured = _featuredList.isNotEmpty ? _featuredList : _topHitsSeed;
    final currentAnime =
        featured.length > _currentHeroIndex ? featured[_currentHeroIndex] : _topHitsSeed[1];
    final isBookmarked =
        StorageService.isBookmarked(currentAnime.id, currentAnime.slug);

    return SizedBox(
      height: 380,
      child: Stack(
        children: [
          // Background Carousel Image
          PageView.builder(
            controller: _heroController,
            itemCount: featured.length,
            onPageChanged: (index) {
              setState(() {
                _currentHeroIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final anime = featured[index];
              final imageUrl = (anime.bannerUrl != null && anime.bannerUrl!.isNotEmpty)
                  ? anime.bannerUrl!
                  : anime.posterUrl;

              return Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 380,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFF1E212B),
                  child: const Center(
                    child: Icon(Icons.movie_outlined, color: Colors.white24, size: 64),
                  ),
                ),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(color: const Color(0xFF151821));
                },
              );
            },
          ),

          // Deep Dark Gradient Vignette Overlay
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.20, 0.55, 0.85, 1.0],
                  colors: [
                    Colors.black.withValues(alpha: 0.65),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.35),
                    Colors.black.withValues(alpha: 0.85),
                    AppColors.canvas,
                  ],
                ),
              ),
            ),
          ),

          // Floating Top App Bar (Brand Logo + Search + Notification)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  // Iconic Emerald Green Brand Logo
                  const BrandLogo(
                    size: 28,
                    color: AppColors.accent,
                  ),
                  const Spacer(),
                  // Search Icon
                  IconButton(
                    icon: const Icon(
                      Icons.search_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                    onPressed: _openSearchScreen,
                  ),
                  // Notification Icon
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                    onPressed: _openNotificationScreen,
                  ),
                ],
              ),
            ),
          ),

          // Bottom Content over Banner (Title, Genres, Action Buttons)
          Positioned(
            left: 16,
            right: 16,
            bottom: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Anime Title
                GestureDetector(
                  onTap: () => _navigateToDetail(currentAnime),
                  child: Text(
                    currentAnime.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      shadows: [
                        Shadow(
                          color: Colors.black87,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // Genres / Categories
                Text(
                  currentAnime.genres.isNotEmpty
                      ? currentAnime.genres.join(', ')
                      : 'Action, Shounen, Martial Arts, Adventure, Fantasy',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    shadows: const [
                      Shadow(
                        color: Colors.black87,
                        blurRadius: 4,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Action Buttons: Play + My List (No login needed!)
                Row(
                  children: [
                    // Play Button
                    ElevatedButton.icon(
                      onPressed: () => _playDirectly(currentAnime),
                      icon: const Icon(
                        Icons.play_circle_fill_rounded,
                        size: 19,
                        color: Colors.white,
                      ),
                      label: const Text('Play'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // My List Button
                    OutlinedButton.icon(
                      onPressed: () => _toggleMyList(currentAnime),
                      icon: Icon(
                        isBookmarked ? Icons.check_rounded : Icons.add_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                      label: Text(
                        isBookmarked ? 'In List' : 'My List',
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white, width: 1.3),
                        backgroundColor: Colors.black.withValues(alpha: 0.3),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopHitsSection() {
    final list = _topHits.isNotEmpty ? _topHits : _topHitsSeed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TopHitsScreen(),
                    ),
                  );
                },
                child: Text(
                  'Top Hits Anime',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TopHitsScreen(),
                    ),
                  );
                },
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                child: const Text(
                  'See all',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Horizontal scrolling Top Hits with Big Rank Numbers
        SizedBox(
          height: 182,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: list.length,
            separatorBuilder: (context, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final anime = list[index];
              final rank = index + 1;
              final rating = (anime.score != null && anime.score!.isNotEmpty && anime.score != '0')
                  ? anime.score!
                  : (9.9 - (index * 0.1)).toStringAsFixed(1);

              return GestureDetector(
                onTap: () => _navigateToDetail(anime),
                child: SizedBox(
                  width: 120,
                  child: Stack(
                    children: [
                      // Poster Image with rounded corners
                      Container(
                        height: 182,
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
                            width: 120,
                            height: 182,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              color: AppColors.surfaceHighlight,
                              child: const Center(
                                child: Icon(Icons.movie_outlined,
                                    color: Colors.white24, size: 36),
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

                      // Big Rank Number in Bottom Left
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
                                color: Colors.black.withValues(alpha: 0.9),
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
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNewReleasesSection() {
    final list = _newReleases.isNotEmpty ? _newReleases : _newReleasesSeed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NewEpisodeReleasesScreen(),
                    ),
                  );
                },
                child: Text(
                  'New Episode Releases',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NewEpisodeReleasesScreen(),
                    ),
                  );
                },
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                child: const Text(
                  'See all',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Horizontal Landscape Cards
        SizedBox(
          height: 110,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: list.length,
            separatorBuilder: (context, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final anime = list[index];
              final rating = (anime.score != null && anime.score!.isNotEmpty && anime.score != '0')
                  ? anime.score!
                  : (9.7 - (index * 0.1)).toStringAsFixed(1);
              final displayImage = (anime.bannerUrl != null && anime.bannerUrl!.isNotEmpty)
                  ? anime.bannerUrl!
                  : anime.posterUrl;

              return GestureDetector(
                onTap: () => _navigateToDetail(anime),
                child: Container(
                  width: 160,
                  height: 104,
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
                        Positioned.fill(
                          child: Image.network(
                            displayImage,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              color: AppColors.surfaceHighlight,
                              child: const Center(
                                child: Icon(Icons.movie_outlined,
                                    color: Colors.white24, size: 28),
                              ),
                            ),
                          ),
                        ),
                        // Dark gradient overlay at bottom
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                stops: const [0.4, 1.0],
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.75),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Top Left Rating Badge
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
                        // Bottom Title / Episode Label
                        Positioned(
                          bottom: 6,
                          left: 8,
                          right: 8,
                          child: Text(
                            (anime.episodeLabel != null && anime.episodeLabel!.isNotEmpty)
                                ? '${anime.title} • ${anime.episodeLabel}'
                                : anime.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
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
        ),
      ],
    );
  }

  Widget _buildContinueWatchingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Lanjutkan Nonton',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              InkWell(
                onTap: () {
                  widget.onNavigateTab?.call(3);
                },
                child: const Text(
                  'Riwayat',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 130,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: _continueWatching.length,
            separatorBuilder: (context, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = _continueWatching[index];
              return GestureDetector(
                onTap: () => _playDirectly(item),
                child: Container(
                  width: 220,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border, width: 1),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          item.posterUrl,
                          width: 70,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: AppColors.surfaceHighlight,
                            width: 70,
                            height: 100,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item.episodeLabel ?? '',
                              style: const TextStyle(
                                color: AppColors.accent,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.play_arrow_rounded,
                                      size: 14, color: Colors.white),
                                  SizedBox(width: 3),
                                  Text(
                                    'Lanjut',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
