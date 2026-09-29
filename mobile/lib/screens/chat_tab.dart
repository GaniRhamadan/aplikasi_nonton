import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ChatTab extends StatelessWidget {
  const ChatTab({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> discussions = [
      {
        'title': 'Diskusi One Piece Episode Terbaru',
        'subtitle': 'Luffy Gear 5 vs Gorosei makin intens!',
        'members': '2.4K anggota',
        'time': 'Baru saja',
        'icon': Icons.local_fire_department_rounded,
        'iconColor': AppColors.accent,
      },
      {
        'title': 'Rekomendasi Anime Musim Ini',
        'subtitle': 'Sharing judul favorit kamu di season 2026',
        'members': '1.8K anggota',
        'time': '5m lalu',
        'icon': Icons.star_rounded,
        'iconColor': AppColors.favYellow,
      },
      {
        'title': 'Info Update Server & Rilis Subtitle',
        'subtitle': 'Server CDN HD-1 online dan lancar tanpa buffer',
        'members': 'Official',
        'time': 'Aktif',
        'icon': Icons.dns_rounded,
        'iconColor': AppColors.success,
      },
      {
        'title': 'Ruang Santai Wibu Indonesia',
        'subtitle': 'Ngobrol santai seputar anime, cosplay, dan manga',
        'members': '5.1K anggota',
        'time': '12m lalu',
        'icon': Icons.chat_bubble_outline_rounded,
        'iconColor': AppColors.dateCyan,
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text(
          'Komunitas & Obrolan',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Banner announcement
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2C1613), Color(0xFF1E1722)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.accentBorder),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.forum_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Forum Diskusi Penggemar',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Bergabung bersama ribuan sesama pecinta anime secara gratis.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'Ruang Obrolan Populer',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),

          ...discussions.map((room) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(room['icon'] as IconData, color: room['iconColor'] as Color, size: 22),
                ),
                title: Text(
                  room['title'] as String,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text(
                  room['subtitle'] as String,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      room['time'] as String,
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      room['members'] as String,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Membuka ${room['title']}...'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}
