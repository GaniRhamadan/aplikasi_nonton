import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'favorite_screen.dart';
import 'history_screen.dart';
import 'settings_tab.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  int _historyCount = 0;
  int _bookmarkCount = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() {
    setState(() {
      _historyCount = StorageService.getHistory().length;
      _bookmarkCount = StorageService.getBookmarks().length;
    });
  }

  void _showNotificationSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.notifications_active_rounded,
                      color: AppColors.accent, size: 24),
                  const SizedBox(width: 10),
                  const Text(
                    'Pemberitahuan & Update',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textSecondary),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(color: AppColors.border),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.accentMuted,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Icon(Icons.movie_filter_rounded,
                        color: AppColors.accent, size: 22),
                  ),
                ),
                title: const Text(
                  'Episode Baru Tersedia!',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: const Text(
                  'Solo Leveling S2 Ep 13 & One Piece Ep 1122 sudah dapat diputar dalam HD.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ),
              const SizedBox(height: 10),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFF162520),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Icon(Icons.speed_rounded,
                        color: AppColors.dateCyan, size: 22),
                  ),
                ),
                title: const Text(
                  'Server Pemutar HD-1 CDN Aktif',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: const Text(
                  'Streaming tanpa buffering dengan kualitas 1080p super cepat.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            const SizedBox(height: 10),

            // 1. User Profile Header (Exact match to Screenshot 2)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Info: Username, Emojis, Stats
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Username "MonaKawai"
                      const Text(
                        'MonaKawai',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Emoji badges: 🕶️ 👓 🏎️
                      Row(
                        children: const [
                          Text('🕶️', style: TextStyle(fontSize: 16)),
                          SizedBox(width: 8),
                          Text('👓', style: TextStyle(fontSize: 16)),
                          SizedBox(width: 8),
                          Text('🏎️', style: TextStyle(fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Stat row: 👁 3 intip  ❤️ 1 lope  🧩 0 contrib  📅 2026 february
                      Wrap(
                        spacing: 12,
                        runSpacing: 6,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.remove_red_eye_rounded,
                                  size: 14, color: Color(0xFF4EE2EC)),
                              SizedBox(width: 4),
                              Text(
                                '3 intip',
                                style: TextStyle(
                                  color: Color(0xFF4EE2EC),
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.favorite_rounded,
                                  size: 14, color: Color(0xFFFF5277)),
                              SizedBox(width: 4),
                              Text(
                                '1 lope',
                                style: TextStyle(
                                  color: Color(0xFFFF5277),
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.extension_rounded,
                                  size: 14, color: Color(0xFF75E063)),
                              SizedBox(width: 4),
                              Text(
                                '0 contrib',
                                style: TextStyle(
                                  color: Color(0xFF75E063),
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.calendar_today_rounded,
                                  size: 13, color: Color(0xFF4EE2EC)),
                              SizedBox(width: 4),
                              Text(
                                '2026 february',
                                style: TextStyle(
                                  color: Color(0xFF4EE2EC),
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Right Avatars: Orange Howling Wolf Circle + Floating Ditto
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Glowing wolf howling logo circle (matching screenshot 2)
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFE56338),
                          width: 2.8,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE56338).withValues(alpha: 0.25),
                            blurRadius: 16,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: CustomPaint(
                          painter: _WolfSilhouettePainter(),
                          child: const SizedBox.expand(),
                        ),
                      ),
                    ),

                    // Cute floating Ditto Pokemon on right edge
                    Positioned(
                      right: -36,
                      top: 24,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF141722),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF282C3D)),
                        ),
                        child: const Text('👾', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 2. Currency Capsule: 🟡 6225C | 0G 🔶 (matching screenshot 2)
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF12141D),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFF202330), width: 1.2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Pikachu Coin 6225C
                    Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFACC15),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          '⚡',
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '6225C',
                      style: TextStyle(
                        color: Color(0xFFFACC15),
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(width: 36),

                    // 0G Diamond Crystal
                    const Text(
                      '0G',
                      style: TextStyle(
                        color: Color(0xFFE56338),
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.diamond_rounded,
                      color: Color(0xFFFACC15),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // 3. 4 Action Buttons: FAVORIT, RIWAYAT, NOTIF, SETUP (matching screenshot 2)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(
                  iconWidget: const Icon(Icons.star_rounded,
                      color: Color(0xFFFACC15), size: 30),
                  label: 'FAVORIT',
                  badgeCount: _bookmarkCount > 0 ? '$_bookmarkCount' : null,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FavoriteScreen(),
                      ),
                    ).then((_) => _loadStats());
                  },
                ),
                _buildActionButton(
                  iconWidget: const Icon(Icons.access_time_filled_rounded,
                      color: Color(0xFFFF5277), size: 28),
                  label: 'RIWAYAT',
                  badgeCount: _historyCount > 0 ? '$_historyCount' : null,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HistoryScreen(),
                      ),
                    ).then((_) => _loadStats());
                  },
                ),
                _buildActionButton(
                  iconWidget: const Icon(Icons.notifications_rounded,
                      color: Color(0xFFE56338), size: 28),
                  label: 'NOTIF',
                  onTap: _showNotificationSheet,
                ),
                _buildActionButton(
                  iconWidget: const Icon(Icons.settings_rounded,
                      color: Color(0xFF4EE2EC), size: 28),
                  label: 'SETUP',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SettingsTab(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 36),

            // 4. Quick Preview Section: Anime Terakhir Ditonton
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  const Text(
                    'Riwayat Terbaru',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HistoryScreen(),
                        ),
                      ).then((_) => _loadStats());
                    },
                    child: const Text(
                      'Lihat Semua >',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            _buildRecentHistoryList(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required Widget iconWidget,
    required String label,
    required VoidCallback onTap,
    String? badgeCount,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 66,
                height: 66,
                decoration: BoxDecoration(
                  color: const Color(0xFF141824),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF222638), width: 1.2),
                ),
                child: Center(child: iconWidget),
              ),
              if (badgeCount != null)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      badgeCount,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentHistoryList() {
    final history = StorageService.getHistory();
    if (history.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF12141D),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF1E212E)),
        ),
        child: const Center(
          child: Text(
            'Belum ada riwayat tontonan. Tonton anime untuk melihat riwayat di sini!',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
          ),
        ),
      );
    }

    return Column(
      children: history.take(3).map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF12141D),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF1E212E)),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: item.animePoster.isNotEmpty
                      ? Image.network(item.animePoster, fit: BoxFit.cover)
                      : Container(color: AppColors.surfaceMuted),
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
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Terakhir: Episode ${item.episodeNumber}',
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textMuted, size: 20),
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// Custom painter for Howling Wolf Silhouette inside orange glowing circle (matching screenshot 2)
class _WolfSilhouettePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE56338)
      ..style = PaintingStyle.fill;

    // Stylized howling wolf head path
    final path = Path();
    final w = size.width;
    final h = size.height;

    // Base point at bottom center
    path.moveTo(w * 0.25, h * 0.95);
    // Neck back line
    path.cubicTo(w * 0.20, h * 0.70, w * 0.28, h * 0.45, w * 0.38, h * 0.30);
    // Ear tip
    path.lineTo(w * 0.45, h * 0.14);
    path.lineTo(w * 0.52, h * 0.28);
    // Forehead and snout pointing up-right
    path.lineTo(w * 0.62, h * 0.32);
    path.lineTo(w * 0.78, h * 0.26); // Nose tip
    // Mouth
    path.lineTo(w * 0.70, h * 0.38);
    path.lineTo(w * 0.65, h * 0.42);
    // Chin and throat
    path.cubicTo(w * 0.62, h * 0.55, w * 0.55, h * 0.75, w * 0.68, h * 0.95);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
