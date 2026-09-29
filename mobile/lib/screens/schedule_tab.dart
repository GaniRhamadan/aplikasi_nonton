import 'package:flutter/material.dart';
import '../models/anime_models.dart';
import '../services/anime_service.dart';
import '../theme/app_theme.dart';
import '../widgets/anime_home_widgets.dart';

class ScheduleTab extends StatefulWidget {
  const ScheduleTab({super.key});

  @override
  State<ScheduleTab> createState() => _ScheduleTabState();
}

class _ScheduleTabState extends State<ScheduleTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AnimeService _animeService = AnimeService();
  bool _isLoading = true;

  final List<String> _dayCodes = [
    'SEN',
    'SEL',
    'RAB',
    'KAM',
    'JUM',
    'SAB',
    'MIN',
  ];

  final Map<String, List<AnimeItem>> _daySchedules = {};
  final Map<String, List<CuplixItem>> _dayHighlights = {};

  @override
  void initState() {
    super.initState();
    final weekday = DateTime.now().weekday; // 1 = Mon, 7 = Sun
    _tabController = TabController(
      length: _dayCodes.length,
      vsync: this,
      initialIndex: (weekday - 1).clamp(0, 6),
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
    _loadScheduleData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadScheduleData() async {
    setState(() => _isLoading = true);

    // Initial items directly matching Screenshot 3
    final senItems = [
      const AnimeItem(
        id: '22',
        slug: 'liar-game-22',
        title: 'Liar Game',
        genreLabel: 'Drama',
        posterUrl: 'https://cdn.myanimelist.net/images/anime/10/73989.jpg',
        views: '47.403 views',
        favorites: '4.952 favorites',
        isNew: true,
        statusBadge: 'new !!',
      ),
      const AnimeItem(
        id: '43891',
        slug: 'world-is-dancing-43891',
        title: 'World Is Dancing',
        genreLabel: 'Drama',
        posterUrl: 'https://cdn.myanimelist.net/images/anime/1908/142991.jpg',
        views: '7.922 views',
        favorites: '2.426 favorites',
        statusBadge: 'tamat',
      ),
      const AnimeItem(
        id: '48760',
        slug: 'gaikotsu-kishi-sama-48760',
        title: 'Gaikotsu Kishi-sama, Tadaima Isekai e Odekakechuu',
        genreLabel: 'Action',
        posterUrl: 'https://cdn.myanimelist.net/images/anime/1361/120706.jpg',
        views: '395.238 views',
        favorites: '13.318 favorites',
        statusBadge: 'tamat',
      ),
      const AnimeItem(
        id: '50291',
        slug: 'toumei-na-yoru-ni-kakeru-50291',
        title: 'Toumei na Yoru ni Kakeru (Love Under Clear Sky)',
        genreLabel: 'Drama',
        posterUrl: 'https://cdn.myanimelist.net/images/anime/1120/124310.jpg',
        views: '145.486 views',
        favorites: '14.356 favorites',
        statusBadge: 'tamat',
      ),
      const AnimeItem(
        id: '3200',
        slug: 'hokuto-no-ken-ke-3200',
        title: 'Hokuto no Ken: Kenou Retsuden',
        genreLabel: 'Comedy',
        posterUrl: 'https://cdn.myanimelist.net/images/anime/9/46087.jpg',
        views: '666 views',
        favorites: '293 favorites',
        statusBadge: 'tamat',
      ),
      const AnimeItem(
        id: '51980',
        slug: 'saikyou-degarashi-ouji-51980',
        title: 'Saikyou Degarashi Ouji no Anyaku Teii Arasoi',
        genreLabel: 'Action',
        posterUrl: 'https://cdn.myanimelist.net/images/anime/1310/141380.jpg',
        views: '194.782 views',
        favorites: '14.222 favorites',
        statusBadge: 'tamat',
      ),
    ];

    final generalHighlights = [
      const CuplixItem(
        id: 'h1',
        title: 'Cute Anime Girl',
        imageUrl: 'https://cdn.myanimelist.net/images/characters/11/382092.jpg',
      ),
      const CuplixItem(
        id: 'h2',
        title: 'Boy Hero',
        imageUrl: 'https://cdn.myanimelist.net/images/characters/14/434691.jpg',
      ),
      const CuplixItem(
        id: 'h3',
        title: 'Surprised Girl',
        imageUrl: 'https://cdn.myanimelist.net/images/characters/2/411899.jpg',
      ),
      const CuplixItem(
        id: 'h4',
        title: 'White Dress',
        imageUrl: 'https://cdn.myanimelist.net/images/characters/7/492576.jpg',
      ),
      const CuplixItem(
        id: 'h5',
        title: 'Long Blue Hair',
        imageUrl: 'https://cdn.myanimelist.net/images/characters/16/329598.jpg',
      ),
    ];

    // Try fetching live airing items from HiAnime
    try {
      final live = await _animeService.getJadwalHariIni();
      if (live.isNotEmpty) {
        senItems.addAll(live.take(6).map((item) {
          return item.copyWith(
            statusBadge: item.isNew ? 'new !!' : 'tamat',
          );
        }));
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        for (final day in _dayCodes) {
          _daySchedules[day] = senItems;
          _dayHighlights[day] = generalHighlights;
        }
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 1. Day Tabs (SEN, SEL, RAB, KAM, JUM, SAB, MIN - matching Screenshot 3)
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFF1E2028), width: 1),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: false,
                labelColor: AppColors.accent,
                unselectedLabelColor: const Color(0xFF94A3B8),
                indicatorColor: AppColors.accent,
                indicatorWeight: 3,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
                tabs: _dayCodes.map((d) => Tab(text: d)).toList(),
              ),
            ),

            // 2. Schedule Content
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.accent,
                        strokeWidth: 2.5,
                      ),
                    )
                  : TabBarView(
                      controller: _tabController,
                      children: _dayCodes.map((day) {
                        final items = _daySchedules[day] ?? [];
                        final highlights = _dayHighlights[day] ?? [];

                        return RefreshIndicator(
                          color: AppColors.accent,
                          backgroundColor: AppColors.surface,
                          onRefresh: _loadScheduleData,
                          child: CustomScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            slivers: [
                              // Story Highlights Avatars Row (matching Screenshot 3)
                              if (highlights.isNotEmpty)
                                SliverToBoxAdapter(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        16, 14, 16, 10),
                                    child: SizedBox(
                                      height: 56,
                                      child: ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: highlights.length,
                                        separatorBuilder: (context, index) =>
                                            const SizedBox(width: 12),
                                        itemBuilder: (context, idx) {
                                          final h = highlights[idx];
                                          return ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            child: Container(
                                              width: 56,
                                              height: 56,
                                              color: AppColors.surfaceMuted,
                                              child: Image.network(
                                                h.imageUrl,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (context, error, stackTrace) =>
                                                        Container(
                                                  color:
                                                      AppColors.surfaceHighlight,
                                                  child: const Icon(
                                                    Icons.person,
                                                    color: AppColors.textMuted,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),

                              // 3-Column Anime Grid (matching Screenshot 3)
                              SliverPadding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 6, 16, 24),
                                sliver: SliverGrid(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    childAspectRatio: 0.44,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 16,
                                  ),
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      final anime = items[index];
                                      return AnimeVerticalCard(
                                        anime: anime,
                                        topSubtitle: anime.displayGenre,
                                        topSubtitleColor: AppColors.accent,
                                        showViews: true,
                                        showFavorites: true,
                                        customStatusBadge: anime.statusBadge ??
                                            (anime.isNew ? 'new !!' : 'tamat'),
                                      );
                                    },
                                    childCount: items.length,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
