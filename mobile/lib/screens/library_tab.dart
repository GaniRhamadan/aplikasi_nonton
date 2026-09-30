import 'package:flutter/material.dart';
import '../models/anime_models.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/anime_card.dart';
import '../widgets/anime_history_card.dart';

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
              icon: Icon(Icons.delete_outline,
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
        return AnimeHistoryCard(
          item: item,
          onRefresh: _loadData,
          onDelete: () async {
            await StorageService.deleteHistoryItem(item.animeId, item.animeSlug);
            _loadData();
          },
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
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
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
