import 'package:flutter/material.dart';
import '../models/anime_models.dart';
import '../services/anime_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/no_schedule_view.dart';
import 'anime_detail_screen.dart';

class ScheduleTab extends StatefulWidget {
  const ScheduleTab({super.key});

  @override
  State<ScheduleTab> createState() => _ScheduleTabState();
}

class _ScheduleTabState extends State<ScheduleTab> {
  final AnimeService _animeService = AnimeService();
  final ScrollController _dateScrollController = ScrollController();

  late DateTime _selectedDate;
  late List<DateTime> _calendarDates;

  bool _isLoading = false;
  List<AnimeItem> _scheduledAnime = [];
  final Map<String, List<AnimeItem>> _scheduleCache = {};

  static const List<String> _dayNames = [
    'Sen',
    'Sel',
    'Rab',
    'Kam',
    'Jum',
    'Sab',
    'Min',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);

    // Build 14-day calendar strip: 3 days past, today, and 10 days ahead
    _calendarDates = List.generate(14, (index) {
      final base = now.subtract(const Duration(days: 3));
      final d = base.add(Duration(days: index));
      return DateTime(d.year, d.month, d.day);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDate();
    });

    _loadScheduleForDate(_selectedDate);
  }

  bool _isBookmarked(AnimeItem anime) {
    return StorageService.isBookmarked(anime.id, anime.slug);
  }

  Future<void> _toggleBookmark(AnimeItem anime) async {
    await StorageService.toggleBookmark(anime);
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _dateScrollController.dispose();
    super.dispose();
  }

  void _scrollToSelectedDate() {
    final index = _calendarDates.indexWhere(
      (d) =>
          d.year == _selectedDate.year &&
          d.month == _selectedDate.month &&
          d.day == _selectedDate.day,
    );
    if (index != -1 && _dateScrollController.hasClients) {
      const itemWidth = 62.0; // 52 width + 10 spacing
      final offset = (index * itemWidth) -
          (MediaQuery.of(context).size.width / 2) +
          (itemWidth / 2);
      _dateScrollController.animateTo(
        offset.clamp(0.0, _dateScrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  int get _currentTimeDividerIndex {
    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;
    for (int i = 0; i < _scheduledAnime.length; i++) {
      final item = _scheduledAnime[i];
      final timeParts =
          (item.statusBadge?.replaceAll('Pukul ', '') ?? '').split(':');
      if (timeParts.length >= 2) {
        final h = int.tryParse(timeParts[0]) ?? 0;
        final m = int.tryParse(timeParts[1]) ?? 0;
        if (h * 60 + m >= currentMinutes) {
          return i;
        }
      }
    }
    return 0;
  }

  Future<void> _loadScheduleForDate(DateTime date) async {
    final key = _dateKey(date);

    if (_scheduleCache.containsKey(key)) {
      setState(() {
        _scheduledAnime = _scheduleCache[key]!;
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      final items = await _animeService.getAiringSchedule(date);
      _scheduleCache[key] = items;
      if (mounted) {
        setState(() {
          _scheduledAnime = items;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _scheduledAnime = [];
          _isLoading = false;
        });
      }
    }
  }

  void _onDateSelected(DateTime date) {
    if (_selectedDate.year == date.year &&
        _selectedDate.month == date.month &&
        _selectedDate.day == date.day) {
      return;
    }
    setState(() {
      _selectedDate = DateTime(date.year, date.month, date.day);
    });
    _loadScheduleForDate(_selectedDate);
    _scrollToSelectedDate();
  }

  void _openDetail(AnimeItem anime, {bool autoPlay = false}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnimeDetailScreen(
          anime: anime,
          autoPlayFirstEpisode: autoPlay,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Top App Bar (Green Logo Icon + Title + More Button)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
              child: Row(
                children: [
                  // App Brand Logo Icon
                  _buildAppLogo(),
                  const SizedBox(width: 12),
                  // Title
                  Expanded(
                    child: Text(
                      'Jadwal Rilis Mingguan',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  // Refresh Button
                  IconButton(
                    icon: Icon(
                      Icons.refresh_rounded,
                      color: AppColors.textPrimary,
                      size: 22,
                    ),
                    tooltip: 'Segarkan Jadwal',
                    onPressed: () {
                      _scheduleCache.remove(_dateKey(_selectedDate));
                      _loadScheduleForDate(_selectedDate);
                    },
                  ),
                ],
              ),
            ),

            // 2. Horizontal Date Selector Strip (Calendar Days Strip)
            SizedBox(
              height: 72,
              child: ListView.separated(
                controller: _dateScrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _calendarDates.length,
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final date = _calendarDates[index];
                  final isSelected = date.year == _selectedDate.year &&
                      date.month == _selectedDate.month &&
                      date.day == _selectedDate.day;

                  final dayName = _dayNames[date.weekday - 1];
                  final dayNum = date.day.toString();

                  return GestureDetector(
                    key: ValueKey('date_pill_${date.day}'),
                    onTap: () => _onDateSelected(date),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 52,
                      height: 70,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.accent : Colors.transparent,
                        borderRadius: BorderRadius.circular(26),
                        border: isSelected
                            ? null
                            : Border.all(
                                color: AppColors.border,
                                width: 1.2,
                              ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            dayName,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textMuted,
                              fontSize: 11.5,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dayNum,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textMuted,
                              fontSize: 15.5,
                              fontWeight: isSelected
                                  ? FontWeight.w800
                                  : FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // 3. Body: Loading / NoReleaseSchedule / Timeline Schedule List
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.accent,
                        strokeWidth: 2.5,
                      ),
                    )
                  : _scheduledAnime.isEmpty
                      ? NoScheduleView(date: _selectedDate)
                      : _buildTimelineSchedule(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppLogo() {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Text(
          'A',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 17,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentTimeDivider([String? customTime]) {
    final now = DateTime.now();
    final timeStr = customTime ??
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1.5,
              color: AppColors.accent,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              'Current Time - $timeStr',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 1.5,
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineSchedule() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: _scheduledAnime.length,
      itemBuilder: (context, index) {
        final anime = _scheduledAnime[index];
        final timeStr = anime.statusBadge?.replaceAll('Pukul ', '') ?? '12:00';
        final isBookmarked = _isBookmarked(anime);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dynamic Current Time divider on today
            if (_isToday(_selectedDate) && index == _currentTimeDividerIndex)
              _buildCurrentTimeDivider(),

            // 1. Time Header with green dash
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 3.5,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    timeStr,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            // 2. Anime Row Item Card
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 16:9 Landscape Thumbnail with Play Button
                GestureDetector(
                  onTap: () => _openDetail(anime, autoPlay: true),
                  child: Container(
                    width: 136,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.surfaceHighlight,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            anime.bannerUrl ?? anime.posterUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Image.network(
                              anime.posterUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                color: AppColors.surfaceHighlight,
                                child: const Icon(
                                  Icons.movie_outlined,
                                  color: Colors.white24,
                                  size: 28,
                                ),
                              ),
                            ),
                          ),
                          // White circular play button
                          Center(
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.play_arrow_rounded,
                                color: Color(0xFF0F172A),
                                size: 19,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Title + Episode + My List Button
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => _openDetail(anime),
                        child: Text(
                          anime.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        anime.episodeLabel ??
                            'Episodes ${anime.totalEpisodes}',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // My List Button (Solid green for + My List, Outlined for ✓ My List)
                      GestureDetector(
                        onTap: () => _toggleBookmark(anime),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 5.5,
                          ),
                          decoration: BoxDecoration(
                            color: isBookmarked
                                ? Colors.transparent
                                : AppColors.accent,
                            borderRadius: BorderRadius.circular(16),
                            border: isBookmarked
                                ? Border.all(
                                    color: AppColors.accent, width: 1.4)
                                : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isBookmarked
                                    ? Icons.check_rounded
                                    : Icons.add_rounded,
                                size: 15,
                                color: isBookmarked
                                    ? AppColors.accent
                                    : Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'My List',
                                style: TextStyle(
                                  color: isBookmarked
                                      ? AppColors.accent
                                      : Colors.white,
                                  fontSize: 12.5,
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
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }
}
