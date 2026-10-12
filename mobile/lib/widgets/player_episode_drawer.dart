import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/anime_models.dart';
import '../theme/app_theme.dart';

/// Episode side drawer for the video player matching Figma screenshot:
/// - Slides in on the right side of the landscape/fullscreen player
/// - Transparent frosted glass background allowing the video underneath to show through
/// - Header: Back arrow + "Episode" title
/// - Scrollable list of episodes:
///   - "Episode X" on the left, duration (e.g. "24:20") on the right
///   - Currently playing episode features an emerald green progress line underneath
///   - Other episodes separated by subtle hairline divider lines
class PlayerEpisodeDrawer extends StatelessWidget {
  final List<EpisodeItem> episodes;
  final int currentEpisodeNumber;
  final double currentProgress; // 0.0 to 1.0 (watch progress of current episode)
  final String totalDurationText; // e.g. "24:20"
  final ValueChanged<EpisodeItem> onEpisodeSelected;
  final VoidCallback onClose;

  const PlayerEpisodeDrawer({
    super.key,
    required this.episodes,
    required this.currentEpisodeNumber,
    this.currentProgress = 0.85,
    this.totalDurationText = '24:20',
    required this.onEpisodeSelected,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: 290,
          height: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xD416181F), // Transparent glass background
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.55),
                blurRadius: 20,
                offset: const Offset(-5, 0),
              ),
            ],
          ),
      child: SafeArea(
        left: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header: Back Arrow & "Episode" Title
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 22,
                    ),
                    onPressed: onClose,
                    tooltip: 'Tutup',
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Episode',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),

            // 2. Episode List
            Expanded(
              child: episodes.isEmpty
                  ? const Center(
                      child: Text(
                        'Memuat episode...',
                        style: TextStyle(color: Colors.white54, fontSize: 13),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                      itemCount: episodes.length,
                      itemBuilder: (context, index) {
                        final ep = episodes[index];
                        final isCurrent = ep.number == currentEpisodeNumber;
                        final epTitle = 'Episode ${ep.number}';

                        return InkWell(
                          onTap: () => onEpisodeSelected(ep),
                          borderRadius: BorderRadius.circular(6),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title and Duration Row
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      epTitle,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14.5,
                                        fontWeight: isCurrent
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      totalDurationText,
                                      style: TextStyle(
                                        color: isCurrent
                                            ? Colors.white70
                                            : const Color(0xFF9E9E9E),
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),

                                // If current episode: Emerald green watch progress bar
                                if (isCurrent)
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      final progressFactor =
                                          currentProgress.clamp(0.05, 1.0);
                                      final fillWidth =
                                          constraints.maxWidth * progressFactor;

                                      return Container(
                                        height: 2.5,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF2A2E39),
                                          borderRadius:
                                              BorderRadius.circular(1.5),
                                        ),
                                        alignment: Alignment.centerLeft,
                                        child: Container(
                                          width: fillWidth,
                                          decoration: BoxDecoration(
                                            color: AppColors.accent,
                                            borderRadius:
                                                BorderRadius.circular(1.5),
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                else
                                  // Non-active episode: subtle hairline divider
                                  Container(
                                    height: 1,
                                    color: Colors.white.withValues(alpha: 0.08),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    ),
    ),
    );
  }
}
