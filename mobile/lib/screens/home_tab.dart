import 'package:flutter/material.dart';
import '../models/anime_models.dart';
import '../services/anime_service.dart';
import '../services/update_service.dart';
import '../theme/app_theme.dart';
import '../widgets/anime_home_widgets.dart';
import 'anime_detail_screen.dart';

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

  List<AnimeItem> _sedangHangat = [];
  List<AnimeItem> _lanjutNonton = [];
  List<CuplixItem> _cuplixItems = [];
  List<AnimeItem> _episodeBaru = [];
  List<AnimeItem> _jadwalHariIni = [];
  AnimeItem? _jasPorYu;
  List<AnimeItem> _judulBaru = [];
  List<AnimeItem> _palingDinanti = [];
  List<AnimeItem> _palingPopuler = [];

  final PageController _bannerController = PageController();
  int _currentBannerIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadHomeData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkUpdate();
    });
  }

  @override
  void dispose() {
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
        _animeService.getSedangHangat(),
        _animeService.getLanjutNonton(),
        _animeService.getEpisodeBaru(),
        _animeService.getJadwalHariIni(),
        _animeService.getJasPorYu(),
        _animeService.getJudulBaru(),
        _animeService.getPalingDinanti(),
        _animeService.getPalingPopuler(),
      ]);

      if (mounted) {
        setState(() {
          _sedangHangat = results[0] as List<AnimeItem>;
          _lanjutNonton = results[1] as List<AnimeItem>;
          _cuplixItems = _animeService.getCuplixItems();
          _episodeBaru = results[2] as List<AnimeItem>;
          _jadwalHariIni = results[3] as List<AnimeItem>;
          _jasPorYu = results[4] as AnimeItem;
          _judulBaru = results[5] as List<AnimeItem>;
          _palingDinanti = results[6] as List<AnimeItem>;
          _palingPopuler = results[7] as List<AnimeItem>;
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
      return const Scaffold(
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
            top: MediaQuery.of(context).padding.top + 8,
            bottom: 32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Sedang Hangat (Large Banner Carousel matching Screenshot 4)
              if (_sedangHangat.isNotEmpty) ...[
                SectionHeader(
                  title: 'Sedang Hangat',
                  onMoreTap: () => widget.onNavigateTab?.call(2), // CARI tab
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 280,
                        child: PageView.builder(
                          controller: _bannerController,
                          itemCount: _sedangHangat.length,
                          onPageChanged: (idx) {
                            setState(() => _currentBannerIndex = idx);
                          },
                          itemBuilder: (context, index) {
                            return AnimeBannerCard(
                              anime: _sedangHangat[index],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Carousel Indicator dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_sedangHangat.length, (i) {
                          final isCurrent = i == _currentBannerIndex;
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: isCurrent ? 18 : 6,
                            height: 4,
                            decoration: BoxDecoration(
                              color: isCurrent
                                  ? AppColors.accent
                                  : const Color(0xFF2E3242),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // 2. Lanjut Nonton (matching Screenshot 1)
              if (_lanjutNonton.isNotEmpty) ...[
                SectionHeader(
                  title: 'Lanjut Nonton',
                  onMoreTap: () => widget.onNavigateTab?.call(4), // Profile/History
                ),
                SizedBox(
                  height: 285,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: _lanjutNonton.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 14),
                    itemBuilder: (context, index) {
                      final anime = _lanjutNonton[index];
                      return AnimeVerticalCard(
                        anime: anime,
                        topSubtitle: anime.episodeLabel ?? 'Episode ${index + 1}',
                        topSubtitleColor: AppColors.accent,
                        showViews: true,
                        showFavorites: true,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // 3. Cuplix (Stories Avatar Highlights matching Screenshot 1)
              if (_cuplixItems.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Cuplix',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
                  ),
                ),
                SizedBox(
                  height: 72,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: _cuplixItems.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final item = _cuplixItems[index];
                      return CuplixAvatar(
                        item: item,
                        onTap: () => _showCuplixPreview(item),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // 4. Episode Baru (matching Screenshot 1 & 2)
              if (_episodeBaru.isNotEmpty) ...[
                SectionHeader(
                  title: 'Episode Baru',
                  onMoreTap: () => widget.onNavigateTab?.call(2), // CARI tab
                ),
                SizedBox(
                  height: 285,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: _episodeBaru.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 14),
                    itemBuilder: (context, index) {
                      final anime = _episodeBaru[index];
                      return AnimeVerticalCard(
                        anime: anime,
                        topSubtitle: anime.episodeLabel ?? anime.displayEpisode,
                        topSubtitleColor: AppColors.accent,
                        showViews: true,
                        showFavorites: true,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // 5. Jadwal Hari ini (matching Screenshot 2 with new !! badge)
              if (_jadwalHariIni.isNotEmpty) ...[
                SectionHeader(
                  title: 'Jadwal Hari ini',
                  onMoreTap: () => widget.onNavigateTab?.call(1), // JADWAL tab
                ),
                SizedBox(
                  height: 295,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: _jadwalHariIni.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 14),
                    itemBuilder: (context, index) {
                      final anime = _jadwalHariIni[index];
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
                ),
                const SizedBox(height: 16),
              ],

              // 6. Jas Por Yu (Recommendation Banner matching Screenshot 2)
              if (_jasPorYu != null) ...[
                SectionHeader(
                  title: 'Jas Por Yu',
                  onMoreTap: () => widget.onNavigateTab?.call(2),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: AnimeBannerCard(anime: _jasPorYu!),
                ),
                const SizedBox(height: 16),
              ],

              // 7. Judul Baru (New Releases matching Screenshot 4 with Release Date)
              if (_judulBaru.isNotEmpty) ...[
                SectionHeader(
                  title: 'Judul Baru',
                  onMoreTap: () => widget.onNavigateTab?.call(1),
                ),
                SizedBox(
                  height: 285,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: _judulBaru.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 14),
                    itemBuilder: (context, index) {
                      final anime = _judulBaru[index];
                      return AnimeVerticalCard(
                        anime: anime,
                        topSubtitle: anime.displayGenre,
                        topSubtitleColor: AppColors.accent,
                        showViews: false,
                        showReleaseDate: true,
                        showFavorites: true,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // 8. Paling Dinanti (Most Anticipated matching Screenshot 3)
              if (_palingDinanti.isNotEmpty) ...[
                SectionHeader(
                  title: 'Paling Dinanti',
                  onMoreTap: () => widget.onNavigateTab?.call(1),
                ),
                SizedBox(
                  height: 285,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: _palingDinanti.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 14),
                    itemBuilder: (context, index) {
                      final anime = _palingDinanti[index];
                      return AnimeVerticalCard(
                        anime: anime,
                        topSubtitle: anime.displayGenre,
                        topSubtitleColor: AppColors.accent,
                        showViews: false,
                        showReleaseDate: true,
                        showFavorites: true,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // 9. Paling Populer (All-time popular matching Screenshot 3)
              if (_palingPopuler.isNotEmpty) ...[
                SectionHeader(
                  title: 'Paling Populer',
                  onMoreTap: () => widget.onNavigateTab?.call(2),
                ),
                SizedBox(
                  height: 285,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: _palingPopuler.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 14),
                    itemBuilder: (context, index) {
                      final anime = _palingPopuler[index];
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
                const SizedBox(height: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showCuplixPreview(CuplixItem cuplix) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    cuplix.imageUrl,
                    width: double.infinity,
                    height: 260,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Cuplix Highlight: ${cuplix.title}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Adegan seru dan cuplikan anime favorit siap ditonton.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      if (cuplix.animeSlug != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AnimeDetailScreen(
                              anime: AnimeItem(
                                id: cuplix.id,
                                slug: cuplix.animeSlug!,
                                title: cuplix.title,
                                posterUrl: cuplix.imageUrl,
                              ),
                            ),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Tonton Sekarang'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
