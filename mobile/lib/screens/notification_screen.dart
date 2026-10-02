import 'package:flutter/material.dart';
import '../models/anime_models.dart';
import '../services/anime_service.dart';
import '../theme/app_theme.dart';
import 'anime_detail_screen.dart';

class NotificationItem {
  final String id;
  final String slug;
  final String title;
  final String posterUrl;
  final String episodeText;
  final String date;
  final String badgeText;
  final bool hasPlayIcon;

  const NotificationItem({
    required this.id,
    required this.slug,
    required this.title,
    required this.posterUrl,
    required this.episodeText,
    required this.date,
    required this.badgeText,
    this.hasPlayIcon = true,
  });
}

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final AnimeService _animeService = AnimeService();

  // Curated initial notifications matching the reference screenshot exactly
  static final List<NotificationItem> _initialNotifications = [
    const NotificationItem(
      id: '21',
      slug: 'one-piece',
      title: 'One Piece',
      posterUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx21-ELSYx3yMPcKM.jpg',
      episodeText: 'Episodes 1080',
      date: '12/20/2024',
      badgeText: 'Update',
      hasPlayIcon: true,
    ),
    const NotificationItem(
      id: '145064',
      slug: 'jujutsu-kaisen-season-2',
      title: 'Jujutsu Kaisen Season 2',
      posterUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx145064-hSNRJM03pvv1.jpg',
      episodeText: 'Episodes 10',
      date: '12/18/2024',
      badgeText: 'Update',
      hasPlayIcon: true,
    ),
    const NotificationItem(
      id: '133898',
      slug: 'dragon-ball-super-super-hero',
      title: 'Dragon Ball Super: Super Hero',
      posterUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx133898-KdQ7fWTG06n4.png',
      episodeText: '',
      date: '12/17/2024',
      badgeText: 'New Release',
      hasPlayIcon: true,
    ),
    const NotificationItem(
      id: '111321',
      slug: 'the-rising-of-the-shield-hero-season-2',
      title: 'The Rising of The Shield Hero: Sea...',
      posterUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx111321-dIr3dEKOIPer.png',
      episodeText: 'Episodes 20',
      date: '12/15/2024',
      badgeText: 'Update',
      hasPlayIcon: true,
    ),
    const NotificationItem(
      id: '145916',
      slug: 'idol-bu-show-movie',
      title: 'Idol Bu Show Movie',
      posterUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx145916-XkQ9CSdKepBQ.jpg',
      episodeText: '',
      date: '12/14/2024',
      badgeText: 'New Release',
      hasPlayIcon: true,
    ),
    const NotificationItem(
      id: '116605',
      slug: 'date-a-live-iv',
      title: 'Date a Live Season IV',
      posterUrl:
          'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx116605-uzDakXnaZ1OW.jpg',
      episodeText: 'Episodes 12',
      date: '12/12/2024',
      badgeText: 'Update',
      hasPlayIcon: true,
    ),
  ];

  late List<NotificationItem> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = List.from(_initialNotifications);
    _loadLatestEpisodeUpdates();
  }

  Future<void> _loadLatestEpisodeUpdates() async {
    try {
      final latest = await _animeService.getEpisodeBaru();
      if (mounted && latest.isNotEmpty) {
        final List<NotificationItem> dynamicItems = [];
        final now = DateTime.now();

        for (int i = 0; i < latest.take(6).length; i++) {
          final anime = latest[i];
          final date =
              '${now.month.toString().padLeft(2, '0')}/${(now.day - i).clamp(1, 31).toString().padLeft(2, '0')}/${now.year}';
          final ep = anime.episodeLabel != null && anime.episodeLabel!.isNotEmpty
              ? anime.episodeLabel!.replaceAll('Episode', 'Episodes')
              : 'Episodes 01';

          dynamicItems.add(
            NotificationItem(
              id: anime.id,
              slug: anime.slug,
              title: anime.title,
              posterUrl: anime.posterUrl,
              episodeText: ep,
              date: date,
              badgeText: 'Update',
              hasPlayIcon: true,
            ),
          );
        }

        // Merge: keep reference items at top and dynamic items following
        setState(() {
          final Set<String> existingSlugs =
              _initialNotifications.map((e) => e.slug).toSet();
          final List<NotificationItem> merged = List.from(_initialNotifications);
          for (var item in dynamicItems) {
            if (!existingSlugs.contains(item.slug)) {
              merged.add(item);
            }
          }
          _notifications = merged;
        });
      }
    } catch (_) {}
  }

  void _showMoreMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.done_all_rounded, color: AppColors.accent),
                title: Text(
                  'Tandai Semua Dibaca',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Semua notifikasi telah ditandai dibaca'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded,
                    color: Colors.redAccent),
                title: Text(
                  'Bersihkan Notifikasi',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _notifications.clear();
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openDetail(NotificationItem notif, {bool autoPlay = false}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnimeDetailScreen(
          anime: AnimeItem(
            id: notif.id,
            slug: notif.slug,
            title: notif.title,
            posterUrl: notif.posterUrl,
            episodeLabel: notif.episodeText,
          ),
          autoPlayFirstEpisode: autoPlay,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notification',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
        centerTitle: false,
        actions: [
          // Circular 3-dots outline icon matching screenshot
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: InkWell(
              onTap: _showMoreMenu,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.textPrimary,
                    width: 1.4,
                  ),
                ),
                child: Icon(
                  Icons.more_horiz_rounded,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none_rounded,
                    size: 64,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Belum ada notifikasi baru',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _notifications.length,
              separatorBuilder: (context, _) => const SizedBox(height: 20),
              itemBuilder: (context, index) {
                final item = _notifications[index];

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Landscape Thumbnail with Rounded Corners & Centered Play Icon
                    // Direct tap on thumbnail triggers immediate playback!
                    GestureDetector(
                      onTap: () => _openDetail(item, autoPlay: true),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 124,
                        height: 78,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: AppColors.surfaceHighlight,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Positioned.fill(
                                child: Image.network(
                                  item.posterUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    color: AppColors.surfaceHighlight,
                                    child: const Center(
                                      child: Icon(
                                        Icons.movie_outlined,
                                        color: Colors.white24,
                                        size: 28,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Centered Play Button Icon: white circle with black arrow
                              if (item.hasPlayIcon)
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Colors.black.withValues(alpha: 0.35),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.play_arrow_rounded,
                                      color: Colors.black,
                                      size: 16,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 14),

                    // 2. Info: Title, Date, Episode, Badge
                    // Direct tap opens details
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _openDetail(item, autoPlay: false),
                        behavior: HitTestBehavior.opaque,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title & Date Row
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    item.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.2,
                                      height: 1.2,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    item.date,
                                    style: TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // Episode Text (if available)
                            if (item.episodeText.isNotEmpty) ...[
                              const SizedBox(height: 5),
                              Text(
                                item.episodeText,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],

                            const SizedBox(height: 6),

                            // Badge: "Update" or "New Release" in light green pill
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 3.5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                item.badgeText,
                                style: const TextStyle(
                                  color: AppColors.accent,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
