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
  List<AnimeItem> _airingList = [];

  final List<String> _days = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  @override
  void initState() {
    super.initState();
    // Default to current day
    final weekday = DateTime.now().weekday; // 1 = Mon, 7 = Sun
    _tabController = TabController(
      length: _days.length,
      vsync: this,
      initialIndex: (weekday - 1).clamp(0, 6),
    );
    _loadSchedule();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSchedule() async {
    setState(() => _isLoading = true);
    final results = await _animeService.getJadwalHariIni();
    if (mounted) {
      setState(() {
        _airingList = results;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text(
          'Jadwal Rilis Anime',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.accent,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.accent,
          indicatorWeight: 3,
          dividerColor: AppColors.border,
          tabAlignment: TabAlignment.start,
          tabs: _days.map((d) => Tab(text: d)).toList(),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.accent,
                strokeWidth: 2.5,
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: _days.map((day) {
                return RefreshIndicator(
                  color: AppColors.accent,
                  backgroundColor: AppColors.surface,
                  onRefresh: _loadSchedule,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.48,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 14,
                    ),
                    itemCount: _airingList.length,
                    itemBuilder: (context, index) {
                      final anime = _airingList[index];
                      return AnimeVerticalCard(
                        anime: anime,
                        topSubtitle: anime.displayGenre,
                        topSubtitleColor: AppColors.accent,
                        showViews: true,
                        showFavorites: true,
                        showNewBadge: true,
                      );
                    },
                  ),
                );
              }).toList(),
            ),
    );
  }
}
