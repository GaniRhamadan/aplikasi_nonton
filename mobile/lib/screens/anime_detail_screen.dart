import 'package:flutter/material.dart';

import '../models/anime_models.dart';
import '../services/anime_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/download_progress_dialog.dart';
import '../widgets/responsive_layout.dart';
import 'player_screen.dart';

class AnimeDetailScreen extends StatefulWidget {
  final AnimeItem anime;
  final bool autoPlayFirstEpisode;

  const AnimeDetailScreen({
    super.key,
    required this.anime,
    this.autoPlayFirstEpisode = false,
  });

  @override
  State<AnimeDetailScreen> createState() => _AnimeDetailScreenState();
}

class _AnimeDetailScreenState extends State<AnimeDetailScreen> {
  final AnimeService _animeService = AnimeService();
  late AnimeItem _currentAnime;
  List<EpisodeItem> _episodes = [];
  List<AnimeItem> _moreLikeThisAnime = [];
  List<AnimeItem> _recommendedAnime = [];

  bool _isLoadingEpisodes = true;
  bool _isLoadingDetails = false;
  bool _isLoadingRecommendations = true;
  bool _isLoadingSeasons = true;
  bool _isBookmarked = false;
  bool _isSynopsisExpanded = false;
  int _selectedBottomTab = 0; // 0: Seasons / More Like This, 1: Recommendations
  int? _lastWatchedEpisode;
  Set<int> _watchedEpisodes = {};
  List<SeasonItem> _seasons = [];

  bool get _hasMultipleSeasons => _seasons.length > 1;

  String get _currentSeasonName {
    final cur = _seasons.firstWhere(
      (s) => s.isCurrent || s.slug == _currentAnime.slug || s.id == _currentAnime.id,
      orElse: () => _seasons.isNotEmpty
          ? _seasons.first
          : SeasonItem(
              id: _currentAnime.id,
              slug: _currentAnime.slug,
              title: _currentAnime.title,
              seasonName: 'Season 1',
              posterUrl: _currentAnime.posterUrl,
              isCurrent: true,
            ),
    );
    return cur.seasonName;
  }

  @override
  void initState() {
    super.initState();
    _currentAnime = widget.anime;
    _isBookmarked = StorageService.isBookmarked(
      _currentAnime.id,
      _currentAnime.slug,
      title: _currentAnime.title,
    );
    StorageService.bookmarksNotifier.addListener(_syncBookmarkState);

    _checkHistory();
    _fetchEpisodes();
    _loadDetailsAndRecommendations();
  }

  @override
  void dispose() {
    StorageService.bookmarksNotifier.removeListener(_syncBookmarkState);
    super.dispose();
  }

  void _syncBookmarkState() {
    if (mounted) {
      final now = StorageService.isBookmarked(
        _currentAnime.id,
        _currentAnime.slug,
        title: _currentAnime.title,
      );
      if (now != _isBookmarked) {
        setState(() => _isBookmarked = now);
      }
    }
  }

  void _checkHistory() {
    final item = StorageService.getHistoryForAnime(
      _currentAnime.id,
      _currentAnime.slug,
    );
    if (mounted) {
      setState(() {
        _lastWatchedEpisode = item?.episodeNumber;
        _watchedEpisodes = item != null ? item.watchedEpisodes.toSet() : {};
      });
    }
  }

  Future<void> _fetchEpisodes() async {
    setState(() => _isLoadingEpisodes = true);
    try {
      var list = await _animeService.getEpisodes(
        _currentAnime.id,
        _currentAnime.slug,
      );

      // Auto-resolve: if 0 episodes returned, check if ID/slug was an invalid/dummy placeholder
      if (list.isEmpty && _currentAnime.title.isNotEmpty) {
        try {
          final searchList = await _animeService.searchAnime(_currentAnime.title);
          if (searchList.isNotEmpty) {
            final cleanTitle = _currentAnime.title.toLowerCase().trim();
            final matched = searchList.firstWhere(
              (item) => item.title.toLowerCase().trim() == cleanTitle,
              orElse: () => searchList.first,
            );
            if (matched.id != _currentAnime.id || matched.slug != _currentAnime.slug) {
              final resolvedList = await _animeService.getEpisodes(matched.id, matched.slug);
              if (resolvedList.isNotEmpty) {
                list = resolvedList;
                if (mounted) {
                  setState(() {
                    _currentAnime = _currentAnime.copyWith(
                      id: matched.id,
                      slug: matched.slug,
                      posterUrl: matched.posterUrl.isNotEmpty ? matched.posterUrl : _currentAnime.posterUrl,
                      totalEpisodes: matched.totalEpisodes > 0 ? matched.totalEpisodes : resolvedList.length,
                      subEpisodes: matched.subEpisodes > 0 ? matched.subEpisodes : resolvedList.length,
                      status: matched.status ?? 'Completed',
                      statusBadge: matched.statusBadge,
                    );
                  });
                  _syncBookmarkState();
                  // Trigger details refresh with real slug/id
                  _animeService.getAnimeDetails(_currentAnime.id, _currentAnime.slug).then((updated) {
                    if (mounted) {
                      setState(() => _currentAnime = updated);
                      _syncBookmarkState();
                    }
                  });
                }
              }
            }
          }
        } catch (_) {}
      }

      if (mounted) {
        setState(() {
          if (list.isNotEmpty) {
            _episodes = list;
          } else if (!_currentAnime.isUpcoming &&
              (_currentAnime.totalEpisodes > 0 ||
                  _currentAnime.subEpisodes > 0)) {
            final count = _currentAnime.totalEpisodes > 0
                ? _currentAnime.totalEpisodes
                : _currentAnime.subEpisodes;
            _episodes = List.generate(
              count,
              (i) => EpisodeItem(
                id: '${i + 1}',
                number: i + 1,
                title: 'Episode ${i + 1}',
                slug: _currentAnime.slug,
              ),
            );
          } else {
            _episodes = [];
          }
          _isLoadingEpisodes = false;
        });

        // If server returns 0 episodes and anime has no episodes count, ensure anime is tagged as upcoming
        if (_episodes.isEmpty &&
            !_currentAnime.isUpcoming &&
            _currentAnime.totalEpisodes == 0 &&
            _currentAnime.subEpisodes == 0) {
          setState(() {
            _currentAnime = _currentAnime.copyWith(
              status: _currentAnime.status ?? 'Not yet aired',
              statusBadge: 'Akan Datang',
            );
          });
        }

        // Only autoplay if there are real episodes and anime is not upcoming
        if (widget.autoPlayFirstEpisode &&
            _episodes.isNotEmpty &&
            !_currentAnime.isUpcoming) {
          final epToPlay = _lastWatchedEpisode != null
              ? _episodes.firstWhere(
                  (e) => e.number == _lastWatchedEpisode,
                  orElse: () => _episodes.first,
                )
              : _episodes.first;
          _playEpisode(epToPlay);
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          if (!_currentAnime.isUpcoming &&
              (_currentAnime.totalEpisodes > 0 ||
                  _currentAnime.subEpisodes > 0)) {
            final count = _currentAnime.totalEpisodes > 0
                ? _currentAnime.totalEpisodes
                : _currentAnime.subEpisodes;
            _episodes = List.generate(
              count,
              (i) => EpisodeItem(
                id: '${i + 1}',
                number: i + 1,
                title: 'Episode ${i + 1}',
                slug: _currentAnime.slug,
              ),
            );
          } else {
            _episodes = [];
          }
          _isLoadingEpisodes = false;
        });
      }
    }
  }

  Future<void> _loadDetailsAndRecommendations() async {
    // 1. Fetch real anime details (status, genres, synopsis, score, release date)
    setState(() => _isLoadingDetails = true);
    try {
      final detailed = await _animeService.getAnimeDetails(
        _currentAnime.id,
        _currentAnime.slug,
        existing: _currentAnime,
      );
      if (mounted) {
        setState(() {
          _currentAnime = detailed;
          _isLoadingDetails = false;
        });
        _syncBookmarkState();
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingDetails = false);
      }
    }

    // 2. Fetch intelligent dynamic recommendations matching genre and synopsis
    if (!mounted) return;
    setState(() => _isLoadingRecommendations = true);
    try {
      final recResult = await _animeService.getRecommendationsForAnime(
        _currentAnime,
      );
      if (mounted) {
        setState(() {
          _moreLikeThisAnime = recResult.moreLikeThis;
          _recommendedAnime = recResult.recommendations;
          _isLoadingRecommendations = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingRecommendations = false);
      }
    }

    // 3. Fetch seasons for this anime franchise
    if (!mounted) return;
    setState(() => _isLoadingSeasons = true);
    try {
      final sList = await _animeService.getSeasonsForAnime(_currentAnime);
      if (mounted) {
        setState(() {
          _seasons = sList;
          _isLoadingSeasons = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingSeasons = false);
      }
    }
  }

  Future<void> _toggleBookmark() async {
    final nowBookmarked = await StorageService.toggleBookmark(_currentAnime);
    if (mounted) {
      setState(() => _isBookmarked = nowBookmarked);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            nowBookmarked ? 'Ditambahkan ke My List' : 'Dihapus dari My List',
          ),
          backgroundColor: AppColors.surface,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _playEpisode(EpisodeItem episode) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            PlayerScreen(anime: _currentAnime, initialEpisode: episode),
      ),
    ).then((_) => _checkHistory());
  }

  void _showSeasonPicker() {
    final list = _seasons.isNotEmpty
        ? _seasons
        : [
            SeasonItem(
              id: _currentAnime.id,
              slug: _currentAnime.slug,
              title: _currentAnime.title,
              seasonName: 'Season 1',
              posterUrl: _currentAnime.posterUrl,
              isCurrent: true,
            ),
          ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Text(
                      'Pilih Season',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              Divider(color: AppColors.border),
              ...list.map((season) {
                final isSelected = season.isCurrent ||
                    season.slug == _currentAnime.slug ||
                    season.id == _currentAnime.id;
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: season.posterUrl.isNotEmpty
                        ? Image.network(
                            season.posterUrl,
                            width: 38,
                            height: 52,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              width: 38,
                              height: 52,
                              color: AppColors.surfaceHighlight,
                              child: Icon(
                                Icons.movie_filter_rounded,
                                color: AppColors.textMuted,
                              ),
                            ),
                          )
                        : Container(
                            width: 38,
                            height: 52,
                            color: AppColors.surfaceHighlight,
                            child: Icon(
                              Icons.movie_filter_rounded,
                              color: AppColors.textMuted,
                            ),
                          ),
                  ),
                  title: Text(
                    season.seasonName,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.accent
                          : AppColors.textPrimary,
                      fontWeight: isSelected
                          ? FontWeight.w800
                          : FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    season.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle_rounded, color: AppColors.accent)
                      : null,
                  onTap: () {
                    Navigator.pop(ctx);
                    if (!isSelected) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AnimeDetailScreen(
                            anime: season.toAnimeItem(),
                          ),
                        ),
                      );
                    }
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _showDownloadSheet() {
    if (_episodes.isEmpty || _currentAnime.isUpcoming) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_currentAnime.title} berstatus Akan Datang (belum ada episode untuk diunduh).',
          ),
          backgroundColor: AppColors.surface,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final banner =
        (_currentAnime.bannerUrl != null && _currentAnime.bannerUrl!.isNotEmpty)
        ? _currentAnime.bannerUrl!
        : _currentAnime.posterUrl;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _DownloadBottomSheet(
        anime: _currentAnime,
        episodes: _episodes,
        bannerUrl: banner,
        onDownload: (selectedEpisodes, resolution) {
          if (selectedEpisodes.isNotEmpty && mounted) {
            for (final ep in selectedEpisodes) {
              StorageService.saveDownload(
                DownloadItem(
                  animeId: _currentAnime.id,
                  animeSlug: _currentAnime.slug,
                  animeTitle: _currentAnime.title,
                  animePoster:
                      (_currentAnime.bannerUrl != null &&
                          _currentAnime.bannerUrl!.isNotEmpty)
                      ? _currentAnime.bannerUrl!
                      : _currentAnime.posterUrl,
                  episodeNumber: ep,
                  episodeTitle: 'Episode ${ep.toString().padLeft(2, '0')}',
                  resolution: resolution,
                  sizeMb: resolution == '1080p'
                      ? 380.0
                      : (resolution == '720p' ? 246.5 : 145.0),
                  timestamp: DateTime.now().millisecondsSinceEpoch,
                ),
              );
            }
            DownloadProgressDialog.show(
              context,
              episodeNumber: selectedEpisodes.first,
              totalEpisodes: selectedEpisodes.length,
              resolution: resolution,
            );
          }
        },
      ),
    );
  }

  Widget _buildPillBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.accent, width: 1.2),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.accent,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final banner =
        (_currentAnime.bannerUrl != null && _currentAnime.bannerUrl!.isNotEmpty)
        ? _currentAnime.bannerUrl!
        : _currentAnime.posterUrl;

    final targetEpisode = _episodes.isNotEmpty
        ? (_lastWatchedEpisode != null
              ? _episodes.firstWhere(
                  (e) => e.number == _lastWatchedEpisode,
                  orElse: () => _episodes.first,
                )
              : _episodes.first)
        : EpisodeItem(
            id: '1',
            number: 1,
            title: 'Episode 1',
            slug: _currentAnime.slug,
          );

    final scoreStr = _currentAnime.score ?? '9.4';
    final yearStr = _currentAnime.releaseDate ?? '2024';
    final genreStr = _currentAnime.genres.isNotEmpty
        ? _currentAnime.genres.join(', ')
        : (_isLoadingDetails ? 'Memuat genre...' : 'General Anime');
    final synopsisText = _currentAnime.synopsis.isNotEmpty
        ? _currentAnime.synopsis
        : (_isLoadingDetails
              ? 'Memuat sinopsis anime...'
              : 'Sinopsis untuk anime ini belum tersedia.');

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Top Banner Image with Floating Back & Cast Buttons
            Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 290,
                  child: Image.network(
                    banner,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        _currentAnime.posterUrl.isNotEmpty
                        ? Image.network(
                            _currentAnime.posterUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) =>
                                Container(color: AppColors.surfaceHighlight),
                          )
                        : Container(color: AppColors.surfaceHighlight),
                  ),
                ),
                // Gradient overlay at bottom of banner
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 80,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppColors.canvas.withValues(alpha: 0.8),
                          AppColors.canvas,
                        ],
                      ),
                    ),
                  ),
                ),
                // Top Action Buttons (Back & Cast)
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        // Back Button
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.45),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        // Cast Button
                        GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Mencari perangkat Chromecast / TV...',
                                ),
                                backgroundColor: AppColors.surface,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.45),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.cast_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // 2. Main Content Body
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + Bookmark + Share Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          _currentAnime.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Bookmark Icon
                      GestureDetector(
                        onTap: _toggleBookmark,
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Icon(
                            _isBookmarked
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_border_rounded,
                            color: _isBookmarked
                                ? AppColors.accent
                                : AppColors.textPrimary,
                            size: 24,
                          ),
                        ),
                      ),
                      // Share / Send Icon (Paper Airplane)
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Tautan ${_currentAnime.title} disalin!',
                              ),
                              backgroundColor: AppColors.surface,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Icon(
                            Icons.near_me_outlined,
                            color: AppColors.textPrimary,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Metadata Row: ★ 9.8 > 2022 [13+] [Japan] [Subtitle]
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        if (_currentAnime.isUpcoming) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: Colors.amber.shade700,
                                width: 1.2,
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.schedule_rounded,
                                  color: Colors.amber,
                                  size: 13,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Akan Datang',
                                  style: TextStyle(
                                    color: Colors.amber,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        const Icon(
                          Icons.star_rounded,
                          color: AppColors.accent,
                          size: 18,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          scoreStr,
                          style: const TextStyle(
                            color: AppColors.accent,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.accent,
                          size: 17,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          yearStr,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildPillBadge('13+'),
                        const SizedBox(width: 5),
                        _buildPillBadge('Japan'),
                        const SizedBox(width: 5),
                        _buildPillBadge('Subtitle'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Action Buttons: If upcoming -> [ Simpan ke My List ] [ Jadwal Rilis ]
                  // Otherwise -> [ ▶ Play ] [ ⤓ Download ]
                  if (_currentAnime.isUpcoming)
                    Row(
                      children: [
                        // Save / Bookmark Button
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber.shade700,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            onPressed: _toggleBookmark,
                            icon: Icon(
                              _isBookmarked
                                  ? Icons.bookmark_added_rounded
                                  : Icons.bookmark_add_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            label: Text(
                              _isBookmarked
                                  ? 'Tersimpan di My List'
                                  : 'Simpan ke My List',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Status Info Button (Outlined Amber)
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: Colors.amber.shade700,
                                width: 1.5,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  backgroundColor: AppColors.surface,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  title: const Row(
                                    children: [
                                      Icon(Icons.schedule_rounded,
                                          color: Colors.amber),
                                      SizedBox(width: 8),
                                      Text(
                                        'Jadwal Rilis',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  content: Text(
                                    'Anime "${_currentAnime.title}" berstatus Akan Datang (Belum Rilis).\n\n'
                                    'Status: ${_currentAnime.status ?? "Not yet aired"}\n'
                                    'Jadwal Rilis: ${_currentAnime.releaseDate ?? "Segera Diumumkan"}\n\n'
                                    'Episode akan otomatis tersedia di aplikasi saat penayangan resmi sudah dimulai di server.',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text(
                                        'Tutup',
                                        style: TextStyle(
                                          color: AppColors.accent,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.schedule_rounded,
                              color: Colors.amber,
                              size: 20,
                            ),
                            label: const Text(
                              'Akan Datang',
                              style: TextStyle(
                                color: Colors.amber,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        // Play Button (Solid green)
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            onPressed: () => _playEpisode(targetEpisode),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.play_circle_fill_rounded,
                                  color: Colors.white,
                                  size: 21,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Play',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Download Button (Outlined green)
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: AppColors.accent,
                                width: 1.5,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            onPressed: _showDownloadSheet,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.file_download_outlined,
                                  color: AppColors.accent,
                                  size: 21,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Download',
                                  style: TextStyle(
                                    color: AppColors.accent,
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 16),

                  // Genre & Expandable Synopsis
                  Text(
                    'Genre: $genreStr',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    synopsisText,
                    maxLines: _isSynopsisExpanded ? null : 3,
                    overflow: _isSynopsisExpanded
                        ? TextOverflow.visible
                        : TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12.5,
                      height: 1.45,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isSynopsisExpanded = !_isSynopsisExpanded;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(
                        _isSynopsisExpanded ? 'View Less' : 'View More',
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Episodes Header Row: [ Episodes ] ... [ Season 2 ∨ ]
                  Row(
                    children: [
                      Text(
                        _currentAnime.isUpcoming
                            ? 'Episodes (Akan Datang)'
                            : 'Episodes',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: _showSeasonPicker,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _currentSeasonName,
                              style: const TextStyle(
                                color: AppColors.accent,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 3),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppColors.accent,
                              size: 19,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Horizontal Episode Cards List or Upcoming State
                  if (_isLoadingEpisodes)
                    const SizedBox(
                      height: 94,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.accent,
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  else if (_episodes.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade900.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.amber.withValues(alpha: 0.35),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.schedule_rounded,
                              color: Colors.amber,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Akan Datang (Belum Rilis)',
                                  style: TextStyle(
                                    color: Colors.amber,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _currentAnime.releaseDate != null &&
                                          _currentAnime.releaseDate!.isNotEmpty
                                      ? 'Anime ini belum tayang di server streaming. Jadwal rilis: ${_currentAnime.releaseDate}. Episode akan langsung tersedia begitu penayangan resmi dimulai.'
                                      : 'Episode untuk anime ini belum tersedia di server streaming. Simpan ke My List agar Anda mendapatkan episode terbaru begitu resmi dirilis.',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    SizedBox(
                      height: 94,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _episodes.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final ep = _episodes[index];
                          return GestureDetector(
                                onTap: () => _playEpisode(ep),
                                child: Container(
                                  width: 144,
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceHighlight,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Image.network(
                                          banner,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, _, _) => Container(
                                            color: AppColors.surfaceHighlight,
                                          ),
                                        ),
                                        // Dark gradient overlay
                                        Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.black.withValues(
                                                  alpha: 0.1,
                                                ),
                                                Colors.black.withValues(
                                                  alpha: 0.65,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        // Center circular white play button
                                        Center(
                                          child: Container(
                                            width: 28,
                                            height: 28,
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(
                                                alpha: 0.85,
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Center(
                                              child: Icon(
                                                Icons.play_arrow_rounded,
                                                color: Color(0xFF0F172A),
                                                size: 19,
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Bottom left episode title
                                        Positioned(
                                          left: 8,
                                          bottom: 8,
                                          right: 8,
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  'Episode ${ep.number}',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 11.5,
                                                    fontWeight: FontWeight.w700,
                                                    shadows: [
                                                      Shadow(
                                                        color: Colors.black,
                                                        blurRadius: 4,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              if (_watchedEpisodes.contains(
                                                ep.number,
                                              ))
                                                const Icon(
                                                  Icons.check_circle_rounded,
                                                  color: AppColors.accent,
                                                  size: 14,
                                                ),
                                            ],
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

                  const SizedBox(height: 22),

                  // Bottom Tabs: [ Seasons / More Like This ] | [ Recommendations ]
                  Row(
                    children: [
                      // Tab 0: Seasons (if multi-season) or More Like This
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _selectedBottomTab = 0);
                          },
                          child: Column(
                            children: [
                              Text(
                                _hasMultipleSeasons ? 'Seasons' : 'More Like This',
                                style: TextStyle(
                                  color: _selectedBottomTab == 0
                                      ? AppColors.accent
                                      : AppColors.textMuted,
                                  fontSize: 14.5,
                                  fontWeight: _selectedBottomTab == 0
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                height: 3,
                                decoration: BoxDecoration(
                                  color: _selectedBottomTab == 0
                                      ? AppColors.accent
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Tab 1: Recommendations (Replaced Comments per user request)
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _selectedBottomTab = 1);
                          },
                          child: Column(
                            children: [
                              Text(
                                'Recommendations',
                                style: TextStyle(
                                  color: _selectedBottomTab == 1
                                      ? AppColors.accent
                                      : AppColors.textMuted,
                                  fontSize: 14.5,
                                  fontWeight: _selectedBottomTab == 1
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                height: 3,
                                decoration: BoxDecoration(
                                  color: _selectedBottomTab == 1
                                      ? AppColors.accent
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 2-Column Grid of Anime Cards for the Selected Tab
                  if (_selectedBottomTab == 0 && _hasMultipleSeasons)
                    _buildSeasonsGrid()
                  else
                    _buildRecommendationsGrid(
                      _selectedBottomTab == 0
                          ? _moreLikeThisAnime
                          : _recommendedAnime,
                    ),

                  const SizedBox(height: 36),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeasonsGrid() {
    if (_isLoadingSeasons && _seasons.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                  color: AppColors.accent,
                  strokeWidth: 2.2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Memuat daftar season...',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12.5),
              ),
            ],
          ),
        ),
      );
    }

    if (_seasons.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Text(
            'Tidak ada season tambahan',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: _seasons.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveLayout.gridColumns(context),
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.68,
      ),
      itemBuilder: (context, index) {
        final season = _seasons[index];
        final isCurrent = season.isCurrent ||
            season.slug == _currentAnime.slug ||
            season.id == _currentAnime.id;

        return GestureDetector(
          onTap: () {
            if (!isCurrent) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AnimeDetailScreen(anime: season.toAnimeItem()),
                ),
              );
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: isCurrent
                        ? Border.all(color: AppColors.accent, width: 2.2)
                        : null,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(isCurrent ? 10 : 12),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          season.posterUrl.isNotEmpty
                              ? season.posterUrl
                              : _currentAnime.posterUrl,
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
                        // Badge if currently watching
                        if (isCurrent)
                          Positioned(
                            left: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3.5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.play_circle_fill, size: 12, color: Colors.white),
                                  SizedBox(width: 4),
                                  Text(
                                    'Sedang Ditonton',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        // Season title bar at bottom
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.85),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            child: Text(
                              season.seasonName,
                              style: TextStyle(
                                color: isCurrent ? AppColors.accent : Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                season.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isCurrent ? AppColors.accent : AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecommendationsGrid(List<AnimeItem> items) {
    if (_isLoadingRecommendations && items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                  color: AppColors.accent,
                  strokeWidth: 2.2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Mencari rekomendasi anime serupa...',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12.5),
              ),
            ],
          ),
        ),
      );
    }

    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Text(
            'Tidak ada anime rekomendasi',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveLayout.gridColumns(context),
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.68,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        final score = item.score ?? '9.4';

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AnimeDetailScreen(anime: item)),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        item.posterUrl,
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
                      // Top Left Green Score Badge (e.g. 9.4, 9.2)
                      Positioned(
                        left: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2.5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            score,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DownloadBottomSheet extends StatefulWidget {
  final AnimeItem anime;
  final List<EpisodeItem> episodes;
  final String bannerUrl;
  final void Function(List<int> episodes, String resolution)? onDownload;

  const _DownloadBottomSheet({
    required this.anime,
    required this.episodes,
    required this.bannerUrl,
    this.onDownload,
  });

  @override
  State<_DownloadBottomSheet> createState() => _DownloadBottomSheetState();
}

class _DownloadBottomSheetState extends State<_DownloadBottomSheet> {
  String _selectedResolution = '720p';
  final Set<int> _selectedEpisodes = {
    1,
  }; // Episode 1 selected by default matching screenshot

  late List<EpisodeItem> _displayEpisodes;

  @override
  void initState() {
    super.initState();
    _displayEpisodes = widget.episodes;
    if (_displayEpisodes.isEmpty) {
      _selectedEpisodes.clear();
    }
  }

  void _showResolutionPicker() {
    const resolutions = ['1080p', '720p', '480p', '360p'];
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 6,
                ),
                child: Row(
                  children: [
                    Text(
                      'Pilih Kualitas Unduhan',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              Divider(color: AppColors.border),
              ...resolutions.map((res) {
                final isSelected = res == _selectedResolution;
                return ListTile(
                  leading: Icon(
                    Icons.hd_outlined,
                    color: isSelected ? AppColors.accent : AppColors.textMuted,
                  ),
                  title: Text(
                    res == '1080p'
                        ? '1080p Full HD'
                        : (res == '720p'
                              ? '720p HD (Rekomendasi)'
                              : (res == '480p'
                                    ? '480p Standar'
                                    : '360p Hemat Kuota')),
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.accent
                          : AppColors.textPrimary,
                      fontWeight: isSelected
                          ? FontWeight.w800
                          : FontWeight.w600,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_rounded, color: AppColors.accent)
                      : null,
                  onTap: () {
                    setState(() => _selectedResolution = res);
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Top Drag Handle Pill
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 12),
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // 2. Centered Title: Download
            Center(
              child: Text(
                'Download',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
            ),

            const SizedBox(height: 12),
            Divider(color: AppColors.border, height: 1, thickness: 1),
            const SizedBox(height: 14),

            // 3. Episodes Header Row: [ Episodes ] ... [ 720p ∨ ]
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                children: [
                  Text(
                    'Episodes',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _showResolutionPicker,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _selectedResolution,
                          style: const TextStyle(
                            color: AppColors.accent,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.accent,
                          size: 19,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 4. Horizontal Episode Cards with Selection Checkmarks
            SizedBox(
              height: 94,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                scrollDirection: Axis.horizontal,
                itemCount: _displayEpisodes.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final ep = _displayEpisodes[index];
                  final isSelected = _selectedEpisodes.contains(ep.number);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedEpisodes.remove(ep.number);
                        } else {
                          _selectedEpisodes.add(ep.number);
                        }
                      });
                    },
                    child: Container(
                      width: 144,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceHighlight,
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected
                            ? Border.all(color: AppColors.accent, width: 2)
                            : null,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              widget.bannerUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) =>
                                  Container(color: AppColors.surfaceHighlight),
                            ),
                            // Selected Dim Overlay or Normal Bottom Gradient
                            if (isSelected)
                              Container(
                                color: Colors.black.withValues(alpha: 0.52),
                              )
                            else
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withValues(alpha: 0.65),
                                    ],
                                  ),
                                ),
                              ),
                            // Center checkmark when selected
                            if (isSelected)
                              const Center(
                                child: Icon(
                                  Icons.check_rounded,
                                  color: AppColors.accent,
                                  size: 28,
                                ),
                              ),
                            // Bottom-left episode label
                            Positioned(
                              left: 8,
                              bottom: 8,
                              child: Text(
                                'Episode ${ep.number}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  shadows: [
                                    Shadow(color: Colors.black, blurRadius: 4),
                                  ],
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

            const SizedBox(height: 24),

            // 5. Bottom Buttons: [ Cancel ]  [ Download ]
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
              child: Row(
                children: [
                  // Cancel Button (Soft pastel green background, green text)
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Center(
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: AppColors.accent,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Download Button (Solid green background, white text)
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        final count = _selectedEpisodes.length;
                        final sortedList = _selectedEpisodes.toList()..sort();
                        final res = _selectedResolution;
                        Navigator.pop(context);
                        if (count > 0) {
                          widget.onDownload?.call(sortedList, res);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                'Pilih minimal 1 episode untuk diunduh',
                              ),
                              backgroundColor: AppColors.surface,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accent.withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'Download',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
