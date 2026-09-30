import 'package:flutter/material.dart';
import '../models/anime_models.dart';
import '../services/anime_service.dart';
import '../theme/app_theme.dart';
import 'anime_detail_screen.dart';

class ScheduleTab extends StatefulWidget {
  const ScheduleTab({super.key});

  @override
  State<ScheduleTab> createState() => _ScheduleTabState();
}

class _ScheduleTabState extends State<ScheduleTab>
    with TickerProviderStateMixin {
  final AnimeService _animeService = AnimeService();
  bool _isLoading = true;

  // Mode: 0 = Hari Ini, 1 = Mingguan, 2 = Akan Datang
  int _selectedMode = 0;

  // Day Tab Controller for "Mingguan"
  late TabController _dayTabController;
  final List<String> _dayCodes = [
    'SEN',
    'SEL',
    'RAB',
    'KAM',
    'JUM',
    'SAB',
    'MIN',
  ];

  final Map<String, String> _dayNames = {
    'SEN': 'Senin',
    'SEL': 'Selasa',
    'RAB': 'Rabu',
    'KAM': 'Kamis',
    'JUM': 'Jumat',
    'SAB': 'Sabtu',
    'MIN': 'Minggu',
  };

  // Data buckets
  List<AnimeItem> _todaySchedule = [];
  final Map<String, List<AnimeItem>> _daySchedules = {};
  List<AnimeItem> _upcomingAnime = [];
  List<CuplixItem> _highlightStories = [];

  // Filter for Akan Datang
  String _upcomingFilter = 'Semua';
  final List<String> _upcomingFilterChips = ['Semua', '2026', '2027 / TBA', 'Movie'];

  @override
  void initState() {
    super.initState();
    final weekday = DateTime.now().weekday; // 1 = Mon, 7 = Sun
    _dayTabController = TabController(
      length: _dayCodes.length,
      vsync: this,
      initialIndex: (weekday - 1).clamp(0, 6),
    );
    _dayTabController.addListener(() {
      if (!_dayTabController.indexIsChanging) {
        setState(() {});
      }
    });

    _loadData();
  }

  @override
  void dispose() {
    _dayTabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    // Reliable AniList CDN Highlights for quick preview
    _highlightStories = [
      const CuplixItem(
        id: 'h1',
        title: 'Solo Leveling',
        imageUrl:
            'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx151807-it355ZgzquUd.png',
        animeSlug: 'solo-leveling-season-2-arise-from-the-shadow-84',
      ),
      const CuplixItem(
        id: 'h2',
        title: 'One Piece',
        imageUrl:
            'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx21-ELSYx3yMPcKM.jpg',
        animeSlug: 'one-piece-100',
      ),
      const CuplixItem(
        id: 'h3',
        title: 'DanDaDan',
        imageUrl:
            'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx171018-60q1B6GK2Ghb.jpg',
        animeSlug: 'dandadan-710',
      ),
      const CuplixItem(
        id: 'h4',
        title: 'Demon Slayer',
        imageUrl:
            'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx101922-WBsBl0ClmgYL.jpg',
        animeSlug: 'demon-slayer-kimetsu-no-yaiba-hashira-training-arc-320',
      ),
      const CuplixItem(
        id: 'h5',
        title: 'Jujutsu Kaisen',
        imageUrl:
            'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx113415-LHBAeoZDIsnF.jpg',
        animeSlug: 'jujutsu-kaisen-2nd-season-502',
      ),
      const CuplixItem(
        id: 'h6',
        title: 'Bleach TYBW',
        imageUrl:
            'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx269-d2GmRkJbMopq.png',
        animeSlug: 'bleach-thousand-year-blood-war-the-calamity-5',
      ),
      const CuplixItem(
        id: 'h7',
        title: 'Frieren',
        imageUrl:
            'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx154587-qQTzQnEJJ3oB.jpg',
        animeSlug: 'sousou-no-frieren-154587',
      ),
    ];

    // Seed weekly schedules
    final Map<String, List<AnimeItem>> seeds = {
      'SEN': [
        const AnimeItem(
          id: '84',
          slug: 'solo-leveling-season-2-arise-from-the-shadow-84',
          title: 'Solo Leveling: Arise from the Shadow',
          genreLabel: 'Action, Fantasy',
          posterUrl:
              'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx151807-it355ZgzquUd.png',
          views: '12.894.210 views',
          favorites: '34.120 favorites',
          isNew: true,
          statusBadge: 'NEW EP',
          episodeLabel: 'Episode 12 Baru',
        ),
        const AnimeItem(
          id: '710',
          slug: 'dandadan-710',
          title: 'DanDaDan Season 1',
          genreLabel: 'Action, Supernatural',
          posterUrl:
              'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx171018-60q1B6GK2Ghb.jpg',
          views: '8.450.210 views',
          favorites: '24.952 favorites',
          isNew: true,
          statusBadge: 'NEW EP',
          episodeLabel: 'Episode 8 Baru',
        ),
        const AnimeItem(
          id: '154587',
          slug: 'sousou-no-frieren-154587',
          title: 'Sousou no Frieren',
          genreLabel: 'Adventure, Fantasy',
          posterUrl:
              'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx154587-qQTzQnEJJ3oB.jpg',
          views: '18.420.500 views',
          favorites: '54.210 favorites',
          statusBadge: 'tamat',
          episodeLabel: 'Total 28 Ep',
        ),
        const AnimeItem(
          id: '20381',
          slug: 'lian-qi-shi-wan-nian-20381',
          title: 'Lian Qi Shi Wan Nian',
          genreLabel: 'Action, Martial Arts',
          posterUrl:
              'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx151807-it355ZgzquUd.png',
          views: '142.113 views',
          favorites: '1.729 favorites',
          statusBadge: 'tamat',
        ),
        const AnimeItem(
          id: '18487',
          slug: 'wan-jie-du-zun-18487',
          title: 'Wan Jie Du Zun',
          genreLabel: 'Action, Fantasy',
          posterUrl:
              'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx113415-LHBAeoZDIsnF.jpg',
          views: '51.763 views',
          favorites: '1.040 favorites',
          statusBadge: 'tamat',
        ),
        const AnimeItem(
          id: '16695',
          slug: 'wushen-zhuzai-16695',
          title: 'Wushen Zhuzai (God of War)',
          genreLabel: 'Action',
          posterUrl:
              'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx269-d2GmRkJbMopq.png',
          views: '76.489 views',
          favorites: '1.392 favorites',
          statusBadge: 'tamat',
        ),
      ],
      'SEL': [
        const AnimeItem(
          id: '320',
          slug: 'demon-slayer-kimetsu-no-yaiba-hashira-training-arc-320',
          title: 'Demon Slayer: Hashira Training',
          genreLabel: 'Action, Fantasy',
          posterUrl:
              'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx101922-WBsBl0ClmgYL.jpg',
          views: '19.894.210 views',
          favorites: '44.120 favorites',
          isNew: true,
          statusBadge: 'NEW EP',
          episodeLabel: 'Episode 8 Baru',
        ),
        const AnimeItem(
          id: '502',
          slug: 'jujutsu-kaisen-2nd-season-502',
          title: 'Jujutsu Kaisen Season 2',
          genreLabel: 'Action, Supernatural',
          posterUrl:
              'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx113415-LHBAeoZDIsnF.jpg',
          views: '14.215.890 views',
          favorites: '36.520 favorites',
          statusBadge: 'tamat',
          episodeLabel: 'Total 23 Ep',
        ),
        const AnimeItem(
          id: '5',
          slug: 'bleach-thousand-year-blood-war-the-calamity-5',
          title: 'Bleach: Thousand-Year Blood War',
          genreLabel: 'Action, Supernatural',
          posterUrl:
              'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx269-d2GmRkJbMopq.png',
          views: '9.450.219 views',
          favorites: '29.810 favorites',
          isNew: true,
          statusBadge: 'NEW EP',
          episodeLabel: 'Episode 5 Baru',
        ),
        const AnimeItem(
          id: '21827',
          slug: 'violet-evergarden-21827',
          title: 'Violet Evergarden',
          genreLabel: 'Drama, Slice of Life',
          posterUrl:
              'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx21827-ubzq619ZA2E9.png',
          views: '11.450.812 views',
          favorites: '48.120 favorites',
          statusBadge: 'tamat',
        ),
        const AnimeItem(
          id: '147103',
          slug: 'boku-no-kokoro-no-yabai-yatsu-147103',
          title: 'The Dangers in My Heart',
          genreLabel: 'Comedy, Romance',
          posterUrl:
              'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx147103-Om2LOXlhHNAe.png',
          views: '6.782.900 views',
          favorites: '21.500 favorites',
          statusBadge: 'tamat',
        ),
        const AnimeItem(
          id: '124080',
          slug: 'chainsaw-man-124080',
          title: 'Chainsaw Man',
          genreLabel: 'Action, Supernatural',
          posterUrl:
              'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx124080-3i22mRVPBS0T.jpg',
          views: '17.340.100 views',
          favorites: '51.900 favorites',
          statusBadge: 'tamat',
        ),
      ],
      'RAB': [
        const AnimeItem(
          id: '100',
          slug: 'one-piece-100',
          title: 'One Piece: Egghead Island',
          genreLabel: 'Action, Adventure',
          posterUrl:
              'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx21-ELSYx3yMPcKM.jpg',
          views: '15.747.141 views',
          favorites: '38.427 favorites',
          isNew: true,
          statusBadge: 'NEW EP',
          episodeLabel: 'Ep. 1122 Baru',
        ),
        const AnimeItem(
          id: '84',
          slug: 'solo-leveling-season-2-arise-from-the-shadow-84',
          title: 'Solo Leveling: Arise from Shadow',
          genreLabel: 'Action, Fantasy',
          posterUrl:
              'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx151807-it355ZgzquUd.png',
          views: '12.894.210 views',
          favorites: '34.120 favorites',
          statusBadge: 'tamat',
        ),
        const AnimeItem(
          id: '710',
          slug: 'dandadan-710',
          title: 'DanDaDan',
          genreLabel: 'Action, Supernatural',
          posterUrl:
              'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx171018-60q1B6GK2Ghb.jpg',
          views: '8.450.210 views',
          favorites: '24.952 favorites',
          statusBadge: 'tamat',
        ),
        const AnimeItem(
          id: '154587',
          slug: 'sousou-no-frieren-154587',
          title: 'Sousou no Frieren',
          genreLabel: 'Adventure, Fantasy',
          posterUrl:
              'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx154587-qQTzQnEJJ3oB.jpg',
          views: '18.420.500 views',
          favorites: '54.210 favorites',
          statusBadge: 'tamat',
        ),
      ],
      'KAM': [
        const AnimeItem(
          id: '5',
          slug: 'bleach-thousand-year-blood-war-the-calamity-5',
          title: 'Bleach: Thousand-Year Blood War',
          genreLabel: 'Action, Supernatural',
          posterUrl:
              'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx269-d2GmRkJbMopq.png',
          views: '9.450.219 views',
          favorites: '29.810 favorites',
          isNew: true,
          statusBadge: 'NEW EP',
          episodeLabel: 'Episode 6 Baru',
        ),
        const AnimeItem(
          id: '320',
          slug: 'demon-slayer-kimetsu-no-yaiba-hashira-training-arc-320',
          title: 'Demon Slayer: Hashira Training',
          genreLabel: 'Action, Fantasy',
          posterUrl:
              'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx101922-WBsBl0ClmgYL.jpg',
          views: '19.894.210 views',
          favorites: '44.120 favorites',
          statusBadge: 'tamat',
        ),
        const AnimeItem(
          id: '502',
          slug: 'jujutsu-kaisen-2nd-season-502',
          title: 'Jujutsu Kaisen Season 2',
          genreLabel: 'Action, Supernatural',
          posterUrl:
              'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx113415-LHBAeoZDIsnF.jpg',
          views: '14.215.890 views',
          favorites: '36.520 favorites',
          statusBadge: 'tamat',
        ),
      ],
      'JUM': [
        const AnimeItem(
          id: '710',
          slug: 'dandadan-710',
          title: 'DanDaDan Season 1',
          genreLabel: 'Action, Supernatural',
          posterUrl:
              'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx171018-60q1B6GK2Ghb.jpg',
          views: '8.450.210 views',
          favorites: '24.952 favorites',
          isNew: true,
          statusBadge: 'NEW EP',
          episodeLabel: 'Episode 9 Baru',
        ),
        const AnimeItem(
          id: '84',
          slug: 'solo-leveling-season-2-arise-from-the-shadow-84',
          title: 'Solo Leveling: Arise from Shadow',
          genreLabel: 'Action, Fantasy',
          posterUrl:
              'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx151807-it355ZgzquUd.png',
          views: '12.894.210 views',
          favorites: '34.120 favorites',
          isNew: true,
          statusBadge: 'NEW EP',
          episodeLabel: 'Episode 13 Baru',
        ),
        const AnimeItem(
          id: '154587',
          slug: 'sousou-no-frieren-154587',
          title: 'Sousou no Frieren',
          genreLabel: 'Adventure, Fantasy',
          posterUrl:
              'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx154587-qQTzQnEJJ3oB.jpg',
          views: '18.420.500 views',
          favorites: '54.210 favorites',
          statusBadge: 'tamat',
        ),
      ],
      'SAB': [
        const AnimeItem(
          id: '502',
          slug: 'jujutsu-kaisen-2nd-season-502',
          title: 'Jujutsu Kaisen Season 2',
          genreLabel: 'Action, Supernatural',
          posterUrl:
              'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx113415-LHBAeoZDIsnF.jpg',
          views: '14.215.890 views',
          favorites: '36.520 favorites',
          isNew: true,
          statusBadge: 'NEW EP',
          episodeLabel: 'Episode 24 Baru',
        ),
        const AnimeItem(
          id: '320',
          slug: 'demon-slayer-kimetsu-no-yaiba-hashira-training-arc-320',
          title: 'Demon Slayer: Hashira Training',
          genreLabel: 'Action, Fantasy',
          posterUrl:
              'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx101922-WBsBl0ClmgYL.jpg',
          views: '19.894.210 views',
          favorites: '44.120 favorites',
          statusBadge: 'tamat',
        ),
      ],
      'MIN': [
        const AnimeItem(
          id: '100',
          slug: 'one-piece-100',
          title: 'One Piece',
          genreLabel: 'Action, Adventure',
          posterUrl:
              'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx21-ELSYx3yMPcKM.jpg',
          views: '15.747.141 views',
          favorites: '38.427 favorites',
          isNew: true,
          statusBadge: 'NEW EP',
          episodeLabel: 'Ep. 1123 Baru',
        ),
        const AnimeItem(
          id: '84',
          slug: 'solo-leveling-season-2-arise-from-the-shadow-84',
          title: 'Solo Leveling: Arise from Shadow',
          genreLabel: 'Action, Fantasy',
          posterUrl:
              'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx151807-it355ZgzquUd.png',
          views: '12.894.210 views',
          favorites: '34.120 favorites',
          statusBadge: 'tamat',
        ),
        const AnimeItem(
          id: '710',
          slug: 'dandadan-710',
          title: 'DanDaDan',
          genreLabel: 'Action, Supernatural',
          posterUrl:
              'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx171018-60q1B6GK2Ghb.jpg',
          views: '8.450.210 views',
          favorites: '24.952 favorites',
          statusBadge: 'tamat',
        ),
      ],
    };

    for (final d in _dayCodes) {
      _daySchedules[d] = seeds[d] ?? seeds['SEN']!;
    }

    // Determine current day code
    final weekday = DateTime.now().weekday; // 1 = Mon, 7 = Sun
    final currentDayCode = _dayCodes[(weekday - 1).clamp(0, 6)];
    _todaySchedule = List<AnimeItem>.from(_daySchedules[currentDayCode] ?? []);

    // Try fetching live airing and upcoming
    try {
      final results = await Future.wait([
        _animeService.getJadwalHariIni().catchError((_) => <AnimeItem>[]),
        _animeService.getAkanDatang().catchError((_) => <AnimeItem>[]),
      ]);

      final liveToday = results[0];
      final upcoming = results[1];

      if (liveToday.isNotEmpty) {
        // Augment today's schedule with live items
        final combined = List<AnimeItem>.from(_todaySchedule);
        for (final item in liveToday.take(4)) {
          if (!combined.any((c) => c.id == item.id)) {
            combined.add(item.copyWith(
              statusBadge: 'HARI INI',
              isNew: true,
              episodeLabel: 'Tayang Hari Ini',
            ));
          }
        }
        _todaySchedule = combined;
      }

      _upcomingAnime = upcoming.isNotEmpty
          ? upcoming
          : await _animeService.getAkanDatang();
    } catch (_) {
      _upcomingAnime = await _animeService.getAkanDatang();
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  List<AnimeItem> get _filteredUpcoming {
    if (_upcomingFilter == 'Semua') return _upcomingAnime;
    if (_upcomingFilter == 'Movie') {
      return _upcomingAnime
          .where((a) =>
              (a.statusBadge ?? '').toLowerCase().contains('movie') ||
              (a.releaseDate ?? '').toLowerCase().contains('film'))
          .toList();
    }
    if (_upcomingFilter == '2026') {
      return _upcomingAnime
          .where((a) =>
              (a.releaseDate ?? '').contains('2026') ||
              (a.statusBadge ?? '').contains('2026'))
          .toList();
    }
    if (_upcomingFilter == '2027 / TBA') {
      return _upcomingAnime
          .where((a) =>
              (a.releaseDate ?? '').contains('2027') ||
              (a.statusBadge ?? '').contains('2027') ||
              (a.statusBadge ?? '').contains('TBA'))
          .toList();
    }
    return _upcomingAnime;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 1. Top Section Title & Mode Segmented Controller
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.calendar_month_rounded,
                          color: AppColors.accent,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Jadwal & Rilis Anime',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 3-Mode Segmented Pill Bar
                  Container(
                    height: 42,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border, width: 1),
                    ),
                    child: Row(
                      children: [
                        _buildModeButton(0, 'Hari Ini', Icons.today_rounded),
                        _buildModeButton(1, 'Mingguan', Icons.view_week_rounded),
                        _buildModeButton(2, 'Akan Datang', Icons.upcoming_rounded),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 2. Main Content based on selected mode
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.accent,
                        strokeWidth: 2.5,
                      ),
                    )
                  : RefreshIndicator(
                      color: AppColors.accent,
                      backgroundColor: AppColors.surface,
                      onRefresh: _loadData,
                      child: _buildCurrentModeContent(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeButton(int modeIndex, String label, IconData icon) {
    final isSelected = _selectedMode == modeIndex;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedMode = modeIndex),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.35),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected ? Colors.white : AppColors.textMuted,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentModeContent() {
    switch (_selectedMode) {
      case 0:
        return _buildTodayContent();
      case 1:
        return _buildWeeklyContent();
      case 2:
        return _buildUpcomingContent();
      default:
        return _buildTodayContent();
    }
  }

  // --- MODE 0: HARI INI (Today's Airing Anime & New Episodes) ---
  Widget _buildTodayContent() {
    final weekday = DateTime.now().weekday;
    final todayName = _dayNames[_dayCodes[(weekday - 1).clamp(0, 6)]] ?? 'Hari Ini';

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        // Story Highlights Bar
        if (_highlightStories.isNotEmpty)
          SliverToBoxAdapter(
            child: _buildStoryHighlights(),
          ),

        // Subtitle Info Bar
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    todayName.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${_todaySchedule.length} Anime Mengudara',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Text(
                  'Auto-update',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),

        // 3-Column Responsive Anime Grid
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.41,
              crossAxisSpacing: 10,
              mainAxisSpacing: 14,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final anime = _todaySchedule[index];
                return _ScheduleAnimeCard(
                  anime: anime,
                  customSubtitle: anime.episodeLabel ?? 'Tayang Hari Ini',
                );
              },
              childCount: _todaySchedule.length,
            ),
          ),
        ),
      ],
    );
  }

  // --- MODE 1: MINGGUAN (Weekly SEN - MIN Day Tabs) ---
  Widget _buildWeeklyContent() {
    return Column(
      children: [
        // Day Tabs (SEN, SEL, RAB, KAM, JUM, SAB, MIN) with unclipped labels
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.border, width: 1),
            ),
          ),
          child: TabBar(
            controller: _dayTabController,
            isScrollable: false,
            labelPadding: const EdgeInsets.symmetric(horizontal: 2),
            labelColor: AppColors.accent,
            unselectedLabelColor: const Color(0xFF94A3B8),
            indicatorColor: AppColors.accent,
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            labelStyle: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.3,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
            tabs: _dayCodes.map((d) => Tab(text: d)).toList(),
          ),
        ),

        // Day Tab Content
        Expanded(
          child: TabBarView(
            controller: _dayTabController,
            children: _dayCodes.map((day) {
              final items = _daySchedules[day] ?? [];
              final dayName = _dayNames[day] ?? day;

              return CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // Highlights
                  if (_highlightStories.isNotEmpty)
                    SliverToBoxAdapter(
                      child: _buildStoryHighlights(),
                    ),

                  // Day header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
                      child: Row(
                        children: [
                          Text(
                            'Jadwal Hari $dayName',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '(${items.length} Judul)',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 3-Column Grid
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.41,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 14,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final anime = items[index];
                          return _ScheduleAnimeCard(anime: anime);
                        },
                        childCount: items.length,
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // --- MODE 2: AKAN DATANG (Upcoming Seasons & Anticipated Releases) ---
  Widget _buildUpcomingContent() {
    final items = _filteredUpcoming;

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        // Filter Chips for Upcoming (Semua, 2026, 2027 / TBA, Movie)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
            child: SizedBox(
              height: 34,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _upcomingFilterChips.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final chip = _upcomingFilterChips[index];
                  final isSelected = _upcomingFilter == chip;
                  return InkWell(
                    onTap: () => setState(() => _upcomingFilter = chip),
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.accent.withValues(alpha: 0.2)
                            : AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.accent
                              : AppColors.border,
                          width: isSelected ? 1.4 : 1,
                        ),
                      ),
                      child: Text(
                        chip,
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.accent
                              : AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.w800 : FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),

        // Upcoming Info Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Row(
              children: [
                const Icon(Icons.rocket_launch_rounded,
                    size: 16, color: AppColors.accent),
                const SizedBox(width: 6),
                Text(
                  'Segera Tayang & Musim Depan',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Text(
                  '${items.length} Judul',
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),

        // 3-Column Grid for Upcoming
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.41,
              crossAxisSpacing: 10,
              mainAxisSpacing: 14,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final anime = items[index];
                return _ScheduleAnimeCard(
                  anime: anime,
                  customSubtitle: anime.releaseDate ?? 'Segera Tayang',
                );
              },
              childCount: items.length,
            ),
          ),
        ),
      ],
    );
  }

  // Highlights Row
  Widget _buildStoryHighlights() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: SizedBox(
        height: 60,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _highlightStories.length,
          separatorBuilder: (context, index) => const SizedBox(width: 12),
          itemBuilder: (context, idx) {
            final h = _highlightStories[idx];
            return InkWell(
              onTap: () {
                if (h.animeSlug != null && h.animeSlug!.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AnimeDetailScreen(
                        anime: AnimeItem(
                          id: h.id,
                          slug: h.animeSlug!,
                          title: h.title,
                          posterUrl: h.imageUrl,
                        ),
                      ),
                    ),
                  );
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF2A2D3C),
                    width: 1.5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    h.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.surfaceHighlight,
                      child: Icon(
                        Icons.movie_creation_outlined,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Custom responsive anime card for the 3-column Schedule Grid that prevents pixel overflow
class _ScheduleAnimeCard extends StatelessWidget {
  final AnimeItem anime;
  final String? customSubtitle;

  const _ScheduleAnimeCard({
    required this.anime,
    this.customSubtitle,
  });

  void _navigateToDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AnimeDetailScreen(anime: anime),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final badgeText = anime.statusBadge ?? (anime.isNew ? 'NEW EP' : 'TAMAT');
    final isNewOrUpcoming = badgeText.toLowerCase().contains('new') ||
        badgeText.toLowerCase().contains('segera') ||
        badgeText.toLowerCase().contains('hari ini') ||
        badgeText.toLowerCase().contains('movie');

    return InkWell(
      onTap: () => _navigateToDetail(context),
      borderRadius: BorderRadius.circular(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Poster Image (Responsive AspectRatio 0.70)
          AspectRatio(
            aspectRatio: 0.70,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  anime.posterUrl.isNotEmpty
                      ? Image.network(
                          anime.posterUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildPlaceholder(),
                          loadingBuilder: (_, child, progress) {
                            if (progress == null) return child;
                            return Container(
                              color: AppColors.surfaceMuted,
                              child: const Center(
                                child: SizedBox(
                                  width: 18,
                                  height: 18,
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

                  // Status Badge in Top Corner
                  if (badgeText.isNotEmpty)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: isNewOrUpcoming
                              ? const Color(0xFFFA5A32)
                              : const Color(0xFF1E293B).withValues(alpha: 0.88),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.45),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                        child: Text(
                          badgeText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 5),

          // 2. Subtitle / Genre / Episode label in Orange
          Text(
            customSubtitle ?? anime.displayGenre,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.accent,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),

          // 3. Anime Title (Max 2 lines, clean ellipsis)
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

          // 4. Views / Favorites info
          Row(
            children: [
              const Icon(
                Icons.play_circle_fill_rounded,
                size: 12,
                color: AppColors.viewsRed,
              ),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  anime.formattedViews,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.viewsRed,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.surfaceMuted,
      child: Center(
        child: Icon(
          Icons.movie_creation_outlined,
          color: AppColors.textMuted,
          size: 26,
        ),
      ),
    );
  }
}
