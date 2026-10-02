import 'package:flutter/material.dart';
import '../models/anime_models.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/brand_logo.dart';
import '../widgets/delete_download_bottom_sheet.dart';
import '../widgets/empty_download_view.dart';
import 'player_screen.dart';
import 'search_screen.dart';

/// Download Tab (Tab 3 in HomeScreen navigation)
/// Matches Figma reference:
/// - When empty: EmptyDownloadView (person under tree with floating play button)
/// - When populated: neat horizontal rows with video thumbnail, play icon, title, episode, size pill, and green delete icon
class DownloadTab extends StatefulWidget {
  final bool isTab;

  const DownloadTab({
    super.key,
    this.isTab = true,
  });

  @override
  State<DownloadTab> createState() => _DownloadTabState();
}

class _DownloadTabState extends State<DownloadTab> {
  List<DownloadItem> _downloads = [];

  @override
  void initState() {
    super.initState();
    _loadDownloads();
  }

  void _loadDownloads() {
    final list = StorageService.getDownloads();
    setState(() {
      _downloads = list;
    });
  }

  Future<void> _confirmAndDeleteItem(DownloadItem item) async {
    final confirmed = await DeleteDownloadBottomSheet.show(context, item);
    if (confirmed == true) {
      await _deleteItem(item);
    }
  }

  Future<void> _deleteItem(DownloadItem item) async {
    await StorageService.deleteDownload(item.animeId, item.episodeNumber);
    _loadDownloads();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${item.episodeTitle.isNotEmpty ? item.episodeTitle : 'Episode ${item.episodeNumber}'} dihapus dari download',
          ),
          backgroundColor: AppColors.surface,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _playDownload(DownloadItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlayerScreen(
          anime: AnimeItem(
            id: item.animeId,
            slug: item.animeSlug,
            title: item.animeTitle,
            posterUrl: item.animePoster,
          ),
          initialEpisode: EpisodeItem(
            id: '${item.episodeNumber}',
            number: item.episodeNumber,
            title: item.episodeTitle.isNotEmpty
                ? item.episodeTitle
                : 'Episode ${item.episodeNumber}',
            slug: item.animeSlug,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Keep synchronized with storage
    final latest = StorageService.getDownloads();
    if (latest.length != _downloads.length) {
      _downloads = latest;
    }

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: widget.isTab
            ? null
            : IconButton(
                icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
                onPressed: () => Navigator.pop(context),
              ),
        titleSpacing: widget.isTab ? 16 : 0,
        title: Row(
          children: [
            const BrandLogo(size: 26),
            const SizedBox(width: 12),
            Text(
              'Download',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.search_rounded,
              color: AppColors.textPrimary,
              size: 24,
            ),
            tooltip: 'Cari Anime',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _downloads.isEmpty
          ? const EmptyDownloadView()
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: _downloads.length,
              separatorBuilder: (context, index) => const SizedBox(height: 18),
              itemBuilder: (context, index) {
                final item = _downloads[index];
                final episodeText = item.episodeTitle.isNotEmpty
                    ? item.episodeTitle
                    : (item.episodeNumber >= 100
                        ? 'Episode ${item.episodeNumber}'
                        : 'Episode ${item.episodeNumber.toString().padLeft(2, '0')}');

                return GestureDetector(
                  onTap: () => _playDownload(item),
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 1. Video Thumbnail with centered White Play Button
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: SizedBox(
                          width: 126,
                          height: 78,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              item.animePoster.isNotEmpty
                                  ? Image.network(
                                      item.animePoster,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error,
                                              stackTrace) =>
                                          Container(
                                        color: AppColors.surfaceHighlight,
                                        child: const Icon(
                                          Icons.movie_rounded,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      color: AppColors.surfaceHighlight,
                                      child: const Icon(
                                        Icons.movie_rounded,
                                        color: Colors.grey,
                                      ),
                                    ),

                              // Dark subtle gradient overlay
                              Container(
                                color: Colors.black.withValues(alpha: 0.18),
                              ),

                              // Center Circular Play Button
                              Center(
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color:
                                        Colors.white.withValues(alpha: 0.92),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.28),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.play_arrow_rounded,
                                      color: Color(0xFF1E232A),
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // 2. Metadata Column (Title, Episode, [Size Pill, Delete Icon])
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Anime Title
                            Text(
                              item.animeTitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 5),

                            // Episode Number
                            Text(
                              episodeText,
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Bottom Row: Size Pill & Emerald Green Trash Can Icon
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                // Size Pill (Soft pastel mint background, emerald green text)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3.5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.accent
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${item.sizeMb.toStringAsFixed(1)} MB',
                                    style: const TextStyle(
                                      color: AppColors.accent,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),

                                // Emerald Green Delete Icon (shows delete confirmation bottom sheet)
                                GestureDetector(
                                  onTap: () => _confirmAndDeleteItem(item),
                                  behavior: HitTestBehavior.opaque,
                                  child: const Padding(
                                    padding: EdgeInsets.all(4.0),
                                    child: Icon(
                                      Icons.delete_outline_rounded,
                                      color: AppColors.accent,
                                      size: 20,
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
                );
              },
            ),
    );
  }
}

typedef DownloadScreen = DownloadTab;
