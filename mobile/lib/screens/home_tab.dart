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
import 'history_screen.dart';
import 'new_episode_releases_screen.dart';
import 'notification_screen.dart';
import 'search_screen.dart';
import 'settings_tab.dart';
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



  List<AnimeItem> _featuredList = [];
  List<AnimeItem> _topHits = [];
  List<AnimeItem> _latestEpisodes = [];
  List<AnimeItem> _newOnHiAnime = [];
  List<AnimeItem> _topUpcoming = [];
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
      final homeData = await _animeService.getHomePageSections();

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

        // Featured Hero List (from Latest or Trending)
        List<AnimeItem> featured = [];
        if (homeData.latestEpisodes.isNotEmpty) {
          featured = homeData.latestEpisodes.take(5).toList();
        } else if (_topHitsSeed.isNotEmpty) {
          featured = [_topHitsSeed[1], _topHitsSeed[0], _topHitsSeed[2]];
        }

        setState(() {
          _featuredList = featured;
          _latestEpisodes = homeData.latestEpisodes;
          _newOnHiAnime = homeData.newOnHiAnime;
          _topUpcoming = homeData.topUpcoming;
          _topHits = homeData.top10.isNotEmpty ? homeData.top10 : _topHitsSeed;
          _continueWatching = continueList;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _featuredList = [_topHitsSeed[1], _topHitsSeed[0], _topHitsSeed[2]];
          _topHits = _topHitsSeed;
          _latestEpisodes = [];
          _newOnHiAnime = [];
          _topUpcoming = [];
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

  void _openSettingsScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsTab(),
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

            // 3. "Latest Episode" Section (matching screenshot)
            SliverToBoxAdapter(
              child: _buildSectionRow(
                title: 'Latest Episode',
                items: _latestEpisodes,
                onViewMore: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NewEpisodeReleasesScreen(
                        title: 'Latest Episode',
                        initialItems: _latestEpisodes,
                      ),
                    ),
                  );
                },
              ),
            ),

            // 4. "New On HiAnime" Section (matching screenshot)
            SliverToBoxAdapter(
              child: _buildSectionRow(
                title: 'New On HiAnime',
                items: _newOnHiAnime,
                onViewMore: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NewEpisodeReleasesScreen(
                        title: 'New On HiAnime',
                        initialItems: _newOnHiAnime,
                      ),
                    ),
                  );
                },
              ),
            ),

            // 5. "Top Upcoming" Section (matching screenshot)
            SliverToBoxAdapter(
              child: _buildSectionRow(
                title: 'Top Upcoming',
                items: _topUpcoming,
                onViewMore: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NewEpisodeReleasesScreen(
                        title: 'Top Upcoming',
                        initialItems: _topUpcoming,
                      ),
                    ),
                  );
                },
              ),
            ),

            // 6. "Top 10" Section
            SliverToBoxAdapter(
              child: _buildTopHitsSection(),
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

          // Vignette Overlay for top app bar icons and bottom hero title/actions
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.22, 0.55, 1.0],
                  colors: [
                    Colors.black.withValues(alpha: 0.55),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.20),
                    Colors.black.withValues(alpha: 0.70),
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
                  // Settings Icon
                  IconButton(
                    icon: const Icon(
                      Icons.settings_outlined,
                      color: Colors.white,
                      size: 25,
                    ),
                    onPressed: _openSettingsScreen,
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
        const SizedBox(height: 22),
        _buildSectionHeader(
          title: 'Top 10 Anime',
          onViewMore: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TopHitsScreen(),
              ),
            );
          },
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

  Widget _buildSectionHeader({
    required String title,
    required VoidCallback onViewMore,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFFF8AB2),
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
          InkWell(
            onTap: onViewMore,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'View more',
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 2),
                Icon(
                  Icons.chevron_right,
                  color: Color(0xFF94A3B8),
                  size: 16,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionRow({
    required String title,
    required List<AnimeItem> items,
    required VoidCallback onViewMore,
  }) {
    if (items.isEmpty) {
      if (_isLoading) {
        return const SizedBox(
          height: 240,
          child: Center(
            child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2),
          ),
        );
      }
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 22),
        _buildSectionHeader(
          title: title,
          onViewMore: onViewMore,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 248,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (context, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return _buildHiAnimeCard(items[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHiAnimeCard(AnimeItem anime) {
    final subtitle = (anime.releaseDate != null && anime.releaseDate!.isNotEmpty)
        ? '${anime.type} • ${anime.releaseDate}'
        : anime.type;

    return GestureDetector(
      onTap: () => _navigateToDetail(anime),
      child: SizedBox(
        width: 128,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster with bottom badges
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    anime.posterUrl,
                    width: 128,
                    height: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 128,
                      height: 180,
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
                // Subtle gradient overlay at bottom
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.65, 1.0],
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.70),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Badges row on bottom of poster
                Positioned(
                  bottom: 6,
                  left: 6,
                  right: 6,
                  child: Wrap(
                    spacing: 3,
                    runSpacing: 3,
                    children: [
                      // Sub Badge (CC) - Light Mint Green
                      if (anime.subEpisodes > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFB9F5D8),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.closed_caption,
                                size: 11,
                                color: Color(0xFF0F5132),
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${anime.subEpisodes}',
                                style: const TextStyle(
                                  color: Color(0xFF0F5132),
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Dub Badge (Mic) - Light Sky Blue
                      if (anime.dubEpisodes > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFBAE6FD),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.mic,
                                size: 10,
                                color: Color(0xFF0C4A6E),
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${anime.dubEpisodes}',
                                style: const TextStyle(
                                  color: Color(0xFF0C4A6E),
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Total / Eps Badge - Translucent Dark
                      if (anime.totalEpisodes > 0 &&
                          (anime.totalEpisodes != anime.subEpisodes ||
                              (anime.subEpisodes == 0 && anime.dubEpisodes == 0)))
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${anime.totalEpisodes}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 7),
            // Title (max 2 lines)
            Text(
              anime.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 3),
            // Subtitle (Type & Duration or Date)
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HistoryScreen(),
                    ),
                  ).then((_) {
                    if (mounted) {
                      _loadHomeData();
                    }
                  });
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
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
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
