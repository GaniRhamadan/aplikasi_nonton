import 'package:flutter/material.dart';
import '../models/anime_models.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'anime_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<WatchHistoryItem> _history = [];
  bool _usingSeed = false;

  static final List<WatchHistoryItem> _seedHistory = [
    WatchHistoryItem(
      animeId: '151252',
      animeSlug: 'koori-zokusei-danshi-to-cool-na-douryou-151252',
      animeTitle: 'Koori Zokusei Danshi to Cool na Douryou',
      animePoster:
          'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx151252-ywrMmJG1Loc3.jpg',
      episodeNumber: 4,
      episodeTitle: 'Episode 4',
      totalEpisodes: 12,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    ),
    WatchHistoryItem(
      animeId: '151252-3',
      animeSlug: 'koori-zokusei-danshi-to-cool-na-douryou-151252',
      animeTitle: 'Koori Zokusei Danshi to Cool na Douryou',
      animePoster:
          'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx151252-ywrMmJG1Loc3.jpg',
      episodeNumber: 3,
      episodeTitle: 'Episode 3',
      totalEpisodes: 12,
      timestamp: DateTime.now().millisecondsSinceEpoch - 3600000,
    ),
    WatchHistoryItem(
      animeId: '6098-12',
      animeSlug: 'sora-no-manimani-6098',
      animeTitle: 'Sora no Manimani (At The Mercy of the Sky)',
      animePoster:
          'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx6098-GfPxtwnEsDAx.jpg',
      episodeNumber: 12,
      episodeTitle: 'Episode 12',
      totalEpisodes: 12,
      timestamp: DateTime.now().millisecondsSinceEpoch - 7200000,
    ),
    WatchHistoryItem(
      animeId: '6098-11',
      animeSlug: 'sora-no-manimani-6098',
      animeTitle: 'Sora no Manimani (At The Mercy of the Sky)',
      animePoster:
          'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx6098-GfPxtwnEsDAx.jpg',
      episodeNumber: 11,
      episodeTitle: 'Episode 11',
      totalEpisodes: 12,
      timestamp: DateTime.now().millisecondsSinceEpoch - 10800000,
    ),
    WatchHistoryItem(
      animeId: '6098-10',
      animeSlug: 'sora-no-manimani-6098',
      animeTitle: 'Sora no Manimani (At The Mercy of the Sky)',
      animePoster:
          'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx6098-GfPxtwnEsDAx.jpg',
      episodeNumber: 10,
      episodeTitle: 'Episode 10',
      totalEpisodes: 12,
      timestamp: DateTime.now().millisecondsSinceEpoch - 14400000,
    ),
    WatchHistoryItem(
      animeId: '6098-9',
      animeSlug: 'sora-no-manimani-6098',
      animeTitle: 'Sora no Manimani (At The Mercy of the Sky)',
      animePoster:
          'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx6098-GfPxtwnEsDAx.jpg',
      episodeNumber: 9,
      episodeTitle: 'Episode 9',
      totalEpisodes: 12,
      timestamp: DateTime.now().millisecondsSinceEpoch - 18000000,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    final list = StorageService.getHistory();
    setState(() {
      if (list.isNotEmpty) {
        _history = list;
        _usingSeed = false;
      } else {
        _history = List.from(_seedHistory);
        _usingSeed = true;
      }
    });
  }

  Future<void> _deleteItem(WatchHistoryItem item) async {
    if (_usingSeed) {
      setState(() {
        _history.removeWhere((h) =>
            h.animeId == item.animeId && h.episodeNumber == item.episodeNumber);
      });
    } else {
      await StorageService.deleteHistoryItem(item.animeId, item.animeSlug);
      _loadHistory();
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item.animeTitle} dihapus dari riwayat'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _clearAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Hapus Semua Riwayat?'),
        content: const Text(
            'Semua riwayat episode yang telah Anda tonton akan dihapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (_usingSeed) {
        setState(() {
          _history = [];
        });
      } else {
        await StorageService.clearHistory();
        _loadHistory();
      }
    }
  }

  String _formatDate(int millis) {
    final dt = DateTime.fromMillisecondsSinceEpoch(millis);
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Ags',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Riwayat Episode',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 3),
            Container(
              width: 80,
              height: 2.5,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded,
                color: AppColors.textSecondary),
            color: AppColors.surface,
            onSelected: (val) {
              if (val == 'clear') _clearAll();
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline,
                        color: AppColors.viewsRed, size: 18),
                    SizedBox(width: 8),
                    Text('Hapus Semua Riwayat',
                        style: TextStyle(color: AppColors.viewsRed)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _history.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(Icons.history_rounded,
                          size: 34, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Belum Ada Riwayat Tontonan',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Episode yang Anda tonton akan otomatis tercatat di sini.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _history.length,
              separatorBuilder: (context, index) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final item = _history[index];

                return InkWell(
                  onTap: () {
                    final anime = AnimeItem(
                      id: item.animeId,
                      slug: item.animeSlug,
                      title: item.animeTitle,
                      posterUrl: item.animePoster,
                      totalEpisodes: item.totalEpisodes,
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AnimeDetailScreen(anime: anime),
                      ),
                    ).then((_) => _loadHistory());
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Row(
                    children: [
                      // Rounded Square Poster (matching screenshot 3)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: SizedBox(
                          width: 68,
                          height: 68,
                          child: item.animePoster.isNotEmpty
                              ? Image.network(
                                  item.animePoster,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
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
                      const SizedBox(width: 14),

                      // Info Column (matching screenshot 3)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.animeTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Episode ${item.episodeNumber}',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today_rounded,
                                  size: 11,
                                  color: AppColors.dateCyan,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _formatDate(item.timestamp),
                                  style: const TextStyle(
                                    color: AppColors.dateCyan,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Icon(
                                  Icons.play_circle_fill_rounded,
                                  size: 11,
                                  color: AppColors.viewsRed,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${(item.animeSlug.hashCode.abs() % 5000 + 300)} views',
                                  style: const TextStyle(
                                    color: AppColors.viewsRed,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Delete X button (matching screenshot 3)
                      IconButton(
                        icon: const Icon(Icons.close_rounded,
                            color: AppColors.textSecondary, size: 20),
                        tooltip: 'Hapus',
                        onPressed: () => _deleteItem(item),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
