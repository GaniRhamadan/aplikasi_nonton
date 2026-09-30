import 'dart:async';
import 'package:flutter/material.dart';
import '../models/anime_models.dart';
import '../services/anime_service.dart';
import '../services/storage_service.dart';
import '../services/update_service.dart';
import '../theme/app_theme.dart';
import '../widgets/anime_home_widgets.dart';

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

  List<AnimeItem> _spotlightBanners = [];
  List<AnimeItem> _continueWatching = [];
  List<AnimeItem> _newEpisodes = [];
  List<AnimeItem> _trendingPopular = [];
  List<AnimeItem> _upcomingAnime = [];
  List<AnimeItem> _todaySchedule = [];

  final PageController _bannerController = PageController();
  int _currentBannerIndex = 0;
  Timer? _bannerTimer;

  @override
  void initState() {
    super.initState();
    _loadHomeData();
    _startBannerTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkUpdate();
    });
  }

  void _startBannerTimer() {
    _bannerTimer?.cancel();
    _bannerTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_spotlightBanners.isNotEmpty && _bannerController.hasClients) {
        final next = (_currentBannerIndex + 1) % _spotlightBanners.length;
        _bannerController.animateToPage(
          next,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
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
        _animeService.getJadwalHariIni().catchError((_) => <AnimeItem>[]),
        _animeService.getAkanDatang().catchError((_) => <AnimeItem>[]),
      ]);

      if (mounted) {
        // 1. History / Continue Watching
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

        // 2. Spotlight Banners (Clean 4-5 curated items)
        final rawSpotlight = results[0];
        final spotlight = rawSpotlight.isNotEmpty
            ? rawSpotlight.take(5).toList()
            : AnimeService.curatedAnime.take(5).toList();

        // 3. New Episodes
        final rawNew = results[1];
        final newEps = rawNew.isNotEmpty
            ? rawNew.take(10).toList()
            : AnimeService.curatedAnime;

        // 4. Trending Popular
        final rawPop = results[2];
        final popular = rawPop.isNotEmpty
            ? rawPop.take(10).toList()
            : AnimeService.curatedAnime;

        // 5. Today's Schedule
        final rawToday = results[3];
        final today = rawToday.isNotEmpty
            ? rawToday.take(8).toList()
            : AnimeService.curatedAnime;

        // 6. Upcoming Anime
        final rawUpcoming = results[4];
        final upcoming = rawUpcoming.isNotEmpty
            ? rawUpcoming.take(8).toList()
            : <AnimeItem>[];

        setState(() {
          _continueWatching = continueList;
          _spotlightBanners = spotlight;
          _newEpisodes = newEps;
          _trendingPopular = popular;
          _todaySchedule = today;
          _upcomingAnime = upcoming;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.canvas,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.accent,
            strokeWidth: 2.5,
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
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 6,
            bottom: 32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top App Bar: Brand Logo & Quick Search Action
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'AniMobile',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        ValueListenableBuilder<ThemeMode>(
                          valueListenable: AppTheme.themeNotifier,
                          builder: (context, mode, _) {
                            final isDark = mode == ThemeMode.dark;
                            return IconButton(
                              icon: Icon(
                                isDark
                                    ? Icons.light_mode_rounded
                                    : Icons.dark_mode_rounded,
                                color: isDark
                                    ? const Color(0xFFFFCC00)
                                    : AppColors.accent,
                                size: 22,
                              ),
                              tooltip: isDark
                                  ? 'Ganti ke Mode Cerah'
                                  : 'Ganti ke Mode Gelap',
                              onPressed: () {
                                StorageService.setThemeMode(isDark
                                    ? ThemeMode.light
                                    : ThemeMode.dark);
                              },
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.search_rounded,
                              color: AppColors.textPrimary, size: 24),
                          tooltip: 'Cari Anime',
                          onPressed: () => widget.onNavigateTab?.call(2),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 1. Spotlight Hero Banner Carousel
              if (_spotlightBanners.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 280,
                        child: PageView.builder(
                          controller: _bannerController,
                          itemCount: _spotlightBanners.length,
                          onPageChanged: (idx) {
                            setState(() => _currentBannerIndex = idx);
                          },
                          itemBuilder: (context, index) {
                            return AnimeBannerCard(
                              anime: _spotlightBanners[index],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Carousel Indicator dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:
                            List.generate(_spotlightBanners.length, (i) {
                          final isCurrent = i == _currentBannerIndex;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: isCurrent ? 20 : 6,
                            height: 4,
                            decoration: BoxDecoration(
                              color: isCurrent
                                  ? AppColors.accent
                                  : AppColors.border,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // 2. Lanjut Nonton (Only shown if user has actual watch history)
              if (_continueWatching.isNotEmpty) ...[
                SectionHeader(
                  title: 'Lanjut Nonton',
                  onMoreTap: () => widget.onNavigateTab?.call(4),
                ),
                SizedBox(
                  height: 300,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: _continueWatching.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final anime = _continueWatching[index];
                      return AnimeVerticalCard(
                        anime: anime,
                        topSubtitle:
                            anime.episodeLabel ?? 'Episode ${index + 1}',
                        topSubtitleColor: AppColors.accent,
                        showViews: false,
                        showFavorites: false,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
              ],

              // 3. Episode Baru (Recent Releases with prominent episode badge)
              if (_newEpisodes.isNotEmpty) ...[
                SectionHeader(
                  title: 'Episode Baru',
                  onMoreTap: () => widget.onNavigateTab?.call(1),
                ),
                SizedBox(
                  height: 305,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: _newEpisodes.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final anime = _newEpisodes[index];
                      return AnimeVerticalCard(
                        anime: anime,
                        topSubtitle:
                            anime.episodeLabel ?? anime.displayEpisode,
                        topSubtitleColor: AppColors.accent,
                        showViews: true,
                        showFavorites: true,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // 4. Sedang Hangat & Populer (Trending Anime)
              if (_trendingPopular.isNotEmpty) ...[
                SectionHeader(
                  title: 'Populer & Tren',
                  onMoreTap: () => widget.onNavigateTab?.call(2),
                ),
                SizedBox(
                  height: 305,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: _trendingPopular.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final anime = _trendingPopular[index];
                      return AnimeVerticalCard(
                        anime: anime,
                        topSubtitle: anime.displayGenre,
                        topSubtitleColor: AppColors.accent,
                        showViews: true,
                        showFavorites: true,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // 5. Akan Datang (Upcoming / Segera Tayang)
              if (_upcomingAnime.isNotEmpty) ...[
                SectionHeader(
                  title: 'Akan Datang',
                  onMoreTap: () => widget.onNavigateTab?.call(1),
                ),
                SizedBox(
                  height: 305,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: _upcomingAnime.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final anime = _upcomingAnime[index];
                      return AnimeVerticalCard(
                        anime: anime,
                        topSubtitle: anime.releaseDate ?? 'Segera Tayang',
                        topSubtitleColor: AppColors.accent,
                        showViews: false,
                        showFavorites: true,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // 6. Jadwal Hari Ini Quick Card (Jumps to Jadwal Tab)
              if (_todaySchedule.isNotEmpty) ...[
                SectionHeader(
                  title: 'Jadwal Hari Ini',
                  onMoreTap: () => widget.onNavigateTab?.call(1),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: InkWell(
                    onTap: () => widget.onNavigateTab?.call(1),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.calendar_today_rounded,
                              color: AppColors.accent,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_todaySchedule.length} Anime Tayang Hari Ini',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Lihat jadwal lengkap & anime yang akan datang',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: AppColors.textMuted,
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
