import 'package:flutter/material.dart';
import '../models/anime_models.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/anime_card.dart';
import 'player_screen.dart';

class LibraryTab extends StatefulWidget {
  final VoidCallback? onNavigateToExplore;

  const LibraryTab({super.key, this.onNavigateToExplore});

  @override
  State<LibraryTab> createState() => _LibraryTabState();
}

class _LibraryTabState extends State<LibraryTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<WatchHistoryItem> _history = [];
  List<AnimeItem> _bookmarks = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadData() {
    setState(() {
      _history = StorageService.getHistory();
      _bookmarks = StorageService.getBookmarks();
    });
  }

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Hapus Riwayat?'),
        content: const Text(
          'Semua daftar tontonan yang tersimpan akan dihapus dari perangkat ini.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              minimumSize: const Size(80, 40),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await StorageService.clearHistory();
      _loadData();
    }
  }

  String _formatTimestamp(int millis) {
    final dt = DateTime.fromMillisecondsSinceEpoch(millis);
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 60) {
      return diff.inMinutes <= 1 ? 'Baru saja' : '${diff.inMinutes} mnt lalu';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} jam lalu';
    } else if (diff.inDays == 1) {
      return 'Kemarin';
    } else {
      return '${dt.day}/${dt.month}/${dt.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text(
          'Koleksi Saya',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  color: AppColors.textSecondary),
              tooltip: 'Hapus Riwayat',
              onPressed: _clearHistory,
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accent,
          indicatorWeight: 2.5,
          labelColor: AppColors.accent,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          tabs: [
            Tab(text: 'Riwayat (${_history.length})'),
            Tab(text: 'Disimpan (${_bookmarks.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. History Tab
          _buildHistoryList(),

          // 2. Bookmarks Tab
          _buildBookmarksGrid(),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    if (_history.isEmpty) {
      return _buildEmptyState(
        icon: Icons.history_rounded,
        title: 'Belum Ada Riwayat Tontonan',
        description:
            'Anime yang Anda putar akan tercatat di sini sehingga Anda bisa langsung melanjutkan episode berikutnya dengan mudah.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      itemCount: _history.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = _history[index];
        return InkWell(
          onTap: () {
            final anime = AnimeItem(
              id: item.animeId,
              slug: item.animeSlug,
              title: item.animeTitle,
              posterUrl: item.animePoster,
            );
            final episode = EpisodeItem(
              id: '',
              number: item.episodeNumber,
              title: item.episodeTitle,
              slug: item.animeSlug,
            );

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PlayerScreen(
                  anime: anime,
                  initialEpisode: episode,
                ),
              ),
            ).then((_) => _loadData());
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SizedBox(
                    width: 50,
                    height: 68,
                    child: item.animePoster.isNotEmpty
                        ? Image.network(
                            item.animePoster,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              color: AppColors.surfaceMuted,
                              child: const Icon(Icons.movie,
                                  color: AppColors.textMuted),
                            ),
                          )
                        : Container(
                            color: AppColors.surfaceMuted,
                            child: const Icon(Icons.movie,
                                color: AppColors.textMuted),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.animeTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Episode ${item.episodeNumber}: ${item.episodeTitle}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTimestamp(item.timestamp),
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.accentMuted,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.play_arrow_rounded,
                        color: AppColors.accent, size: 22),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBookmarksGrid() {
    if (_bookmarks.isEmpty) {
      return _buildEmptyState(
        icon: Icons.bookmark_border_rounded,
        title: 'Belum Ada Anime Tersimpan',
        description:
            'Tandai anime favorit Anda dengan menekan ikon simpan (bookmark) di halaman detail anime agar mudah ditemukan kembali.',
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 12,
        mainAxisSpacing: 14,
      ),
      itemCount: _bookmarks.length,
      itemBuilder: (context, index) {
        final anime = _bookmarks[index];
        return AnimeCard(anime: anime);
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 54, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: widget.onNavigateToExplore,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(180, 48),
              ),
              child: const Text('Jelajahi Anime'),
            ),
          ],
        ),
      ),
    );
  }
}
