import 'package:flutter/material.dart';
import '../models/anime_models.dart';
import '../services/anime_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'player_screen.dart';

class AnimeDetailScreen extends StatefulWidget {
  final AnimeItem anime;

  const AnimeDetailScreen({super.key, required this.anime});

  @override
  State<AnimeDetailScreen> createState() => _AnimeDetailScreenState();
}

class _AnimeDetailScreenState extends State<AnimeDetailScreen> {
  final AnimeService _animeService = AnimeService();
  List<EpisodeItem> _episodes = [];
  List<EpisodeItem> _filteredEpisodes = [];
  bool _isLoading = true;
  bool _isBookmarked = false;
  bool _isDub = false;
  int? _lastWatchedEpisode;
  Set<int> _watchedEpisodes = {};
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isDub = StorageService.isDub;
    _isBookmarked =
        StorageService.isBookmarked(widget.anime.id, widget.anime.slug);
    _checkHistory();
    _fetchEpisodes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _checkHistory() {
    final item = StorageService.getHistoryForAnime(
        widget.anime.id, widget.anime.slug);
    if (mounted) {
      setState(() {
        _lastWatchedEpisode = item?.episodeNumber;
        _watchedEpisodes = item != null ? item.watchedEpisodes.toSet() : {};
      });
    }
  }

  Future<void> _fetchEpisodes() async {
    setState(() => _isLoading = true);
    final list =
        await _animeService.getEpisodes(widget.anime.id, widget.anime.slug);
    if (mounted) {
      setState(() {
        _episodes = list;
        _filteredEpisodes = list;
        _isLoading = false;
      });
    }
  }

  void _filterEpisodes(String query) {
    final clean = query.trim().toLowerCase();
    if (clean.isEmpty) {
      setState(() => _filteredEpisodes = _episodes);
      return;
    }

    setState(() {
      _filteredEpisodes = _episodes.where((e) {
        final matchesNumber = e.number.toString().contains(clean);
        final matchesTitle = e.title.toLowerCase().contains(clean);
        return matchesNumber || matchesTitle;
      }).toList();
    });
  }

  Future<void> _toggleBookmark() async {
    final nowBookmarked = await StorageService.toggleBookmark(widget.anime);
    if (mounted) {
      setState(() => _isBookmarked = nowBookmarked);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            nowBookmarked
                ? 'Ditambahkan ke Koleksi Tersimpan'
                : 'Dihapus dari Koleksi Tersimpan',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _playEpisode(EpisodeItem episode) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlayerScreen(
          anime: widget.anime,
          initialEpisode: episode,
        ),
      ),
    ).then((_) => _checkHistory());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: Text(
          widget.anime.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
              color: _isBookmarked ? AppColors.accent : AppColors.textSecondary,
            ),
            tooltip: _isBookmarked ? 'Hapus Simpan' : 'Simpan Anime',
            onPressed: _toggleBookmark,
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // Anime Header Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Poster (Clean 3:4 aspect ratio)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 100,
                      height: 140,
                      child: widget.anime.posterUrl.isNotEmpty
                          ? Image.network(
                              widget.anime.posterUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                color: AppColors.surfaceMuted,
                                child: Icon(Icons.movie,
                                    color: AppColors.textMuted),
                              ),
                            )
                          : Container(
                              color: AppColors.surfaceMuted,
                              child: Icon(Icons.movie,
                                  color: AppColors.textMuted),
                            ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Metadata Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.anime.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceMuted,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                widget.anime.type,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            if (widget.anime.totalEpisodes > 0)
                              Text(
                                '${widget.anime.totalEpisodes} Episode',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Sub / Dub Badges
                        Row(
                          children: [
                            if (widget.anime.subEpisodes > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                margin: const EdgeInsets.only(right: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black87,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'SUB ${widget.anime.subEpisodes}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            if (widget.anime.dubEpisodes > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.accent,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'DUB ${widget.anime.dubEpisodes}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
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
            ),

            const SizedBox(height: 16),

            // Smart Continue / Play logic
            Builder(
              builder: (context) {
                final hasHistory = _lastWatchedEpisode != null && _lastWatchedEpisode! > 0;
                final lastEp = _lastWatchedEpisode ?? 1;

                int targetEp = 1;
                String buttonText;

                if (hasHistory) {
                  final maxEp = _episodes.isNotEmpty
                      ? _episodes.map((e) => e.number).reduce((a, b) => a > b ? a : b)
                      : (widget.anime.totalEpisodes > 0
                          ? widget.anime.totalEpisodes
                          : lastEp);

                  if (lastEp < maxEp) {
                    targetEp = lastEp + 1;
                    buttonText = 'Lanjut Episode $targetEp';
                  } else {
                    targetEp = lastEp;
                    buttonText = 'Tonton Ulang Episode $targetEp';
                  }
                } else {
                  targetEp = 1;
                  buttonText = 'Mulai Menonton (Ep 1)';
                }

                return Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        if (_episodes.isNotEmpty) {
                          final target = _episodes.firstWhere(
                            (e) => e.number == targetEp,
                            orElse: () => _episodes.first,
                          );
                          _playEpisode(target);
                        } else {
                          _playEpisode(
                            EpisodeItem(
                              id: '',
                              number: targetEp,
                              title: 'Episode $targetEp',
                              slug: widget.anime.slug,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.play_arrow_rounded, size: 24),
                      label: Text(buttonText),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                    ),
                    if (hasHistory) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.accentMuted,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.accentBorder),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.history_rounded,
                                size: 16, color: AppColors.accent),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Terakhir ditonton: Episode $lastEp • ${_watchedEpisodes.length} episode selesai',
                                style: const TextStyle(
                                  color: AppColors.accent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),

            const SizedBox(height: 20),

            // Synopsis if available
            if (widget.anime.synopsis.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sinopsis',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.anime.synopsis,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Episode Section Title & Audio Switch
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Daftar Episode (${_episodes.length})',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      _buildAudioTab('SUB', !_isDub, () {
                        setState(() => _isDub = false);
                        StorageService.setDub(false);
                      }),
                      _buildAudioTab('DUB', _isDub, () {
                        setState(() => _isDub = true);
                        StorageService.setDub(true);
                      }),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Episode Search / Filter Input
            TextField(
              controller: _searchController,
              onChanged: _filterEpisodes,
              decoration: InputDecoration(
                hintText: 'Cari nomor atau judul episode...',
                prefixIcon: Icon(Icons.search,
                    color: AppColors.textSecondary, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _filterEpisodes('');
                        },
                      )
                    : null,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),

            const SizedBox(height: 14),

            // Episode List
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.accent,
                  ),
                ),
              )
            else if (_filteredEpisodes.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Center(
                  child: Text(
                    'Tidak ada episode yang sesuai pencarian.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _filteredEpisodes.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final episode = _filteredEpisodes[index];
                  final isLastWatched = episode.number == _lastWatchedEpisode;
                  final isWatched = _watchedEpisodes.contains(episode.number);

                  return InkWell(
                    onTap: () => _playEpisode(episode),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isLastWatched
                            ? AppColors.accentMuted
                            : (isWatched
                                ? const Color(0xFF141A18)
                                : AppColors.surface),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isLastWatched
                              ? AppColors.accent
                              : (isWatched
                                  ? const Color(0xFF1C3A2C)
                                  : AppColors.border),
                          width: isLastWatched ? 1.4 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: isLastWatched
                                  ? AppColors.accent
                                  : (isWatched
                                      ? const Color(0xFF1C3A2C)
                                      : AppColors.surfaceMuted),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Center(
                              child: isWatched && !isLastWatched
                                  ? const Icon(
                                      Icons.check_rounded,
                                      color: Color(0xFF34D399),
                                      size: 18,
                                    )
                                  : Text(
                                      '${episode.number}',
                                      style: TextStyle(
                                        color: isLastWatched
                                            ? Colors.white
                                            : AppColors.textPrimary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  episode.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: isLastWatched
                                        ? AppColors.accent
                                        : (isWatched
                                            ? const Color(0xFFD1D5DB)
                                            : AppColors.textPrimary),
                                    fontWeight: isLastWatched
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                                if (isLastWatched)
                                  const Text(
                                    '★ Terakhir ditonton',
                                    style: TextStyle(
                                      color: AppColors.accent,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  )
                                else if (isWatched)
                                  const Text(
                                    '✓ Sudah ditonton',
                                    style: TextStyle(
                                      color: Color(0xFF34D399),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Icon(
                            isLastWatched
                                ? Icons.play_circle_filled
                                : (isWatched
                                    ? Icons.check_circle_outline_rounded
                                    : Icons.play_arrow_outlined),
                            color: isLastWatched
                                ? AppColors.accent
                                : (isWatched
                                    ? const Color(0xFF34D399)
                                    : AppColors.textSecondary),
                            size: 22,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioTab(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
