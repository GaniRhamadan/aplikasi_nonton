import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Custom Video Player Controls Overlay matching Figma reference:
/// Top Bar:
/// - Back button
/// - Anime / Episode Title
/// - Right action icons: Speed, Sleep Timer, Subtitle CC, Mic (Sub/Dub), Cast, PiP, 3-dots More
///
/// Progress Bar:
/// - Left timestamp (e.g. "20:28")
/// - Vibrant emerald green progress track with white circular knob
/// - Right timestamp (e.g. "24:20")
///
/// Bottom Controls Row:
/// - Left: Lock screen, Volume/Mute
/// - Center: Rewind 10s, Previous episode, Large white Play/Pause, Next episode, Forward 10s
/// - Right: Download icon, Fullscreen/Aspect ratio icon
class VideoPlayerOverlay extends StatefulWidget {
  final String title;
  final Duration currentPosition;
  final Duration totalDuration;
  final bool isPlaying;
  final bool isMuted;
  final bool isLocked;
  final bool isFullscreen;
  final bool isSubIndoActive;
  final double playbackSpeed;
  final VoidCallback onBackPressed;
  final VoidCallback onPlayPausePressed;
  final ValueChanged<Duration> onSeek;
  final VoidCallback onRewind10;
  final VoidCallback onForward10;
  final VoidCallback? onPreviousEpisode;
  final VoidCallback? onNextEpisode;
  final VoidCallback onToggleMute;
  final VoidCallback onToggleLock;
  final VoidCallback onToggleFullscreen;
  final VoidCallback onSpeedPressed;
  final VoidCallback onTimerPressed;
  final VoidCallback onSubtitlesPressed;
  final VoidCallback onAudioTrackPressed;
  final VoidCallback onCastPressed;
  final VoidCallback onPipPressed;
  final VoidCallback onMorePressed;
  final VoidCallback onDownloadPressed;
  final VoidCallback? onEpisodeListPressed;
  final ValueChanged<bool>? onControlsVisibilityChanged;
  final bool showSkipIntro;
  final VoidCallback? onSkipIntro;
  final bool showSkipOutro;
  final VoidCallback? onSkipOutro;
  final bool isBuffering;
  final bool isNetworkStalled;
  final int stallSeconds;
  final VoidCallback? onRetryPlayback;
  final VoidCallback? onSwitchServer;

  const VideoPlayerOverlay({
    super.key,
    required this.title,
    required this.currentPosition,
    required this.totalDuration,
    required this.isPlaying,
    required this.isMuted,
    required this.isLocked,
    required this.isFullscreen,
    this.isSubIndoActive = true,
    this.playbackSpeed = 1.0,
    required this.onBackPressed,
    required this.onPlayPausePressed,
    required this.onSeek,
    required this.onRewind10,
    required this.onForward10,
    this.onPreviousEpisode,
    this.onNextEpisode,
    required this.onToggleMute,
    required this.onToggleLock,
    required this.onToggleFullscreen,
    required this.onSpeedPressed,
    required this.onTimerPressed,
    required this.onSubtitlesPressed,
    required this.onAudioTrackPressed,
    required this.onCastPressed,
    required this.onPipPressed,
    required this.onMorePressed,
    required this.onDownloadPressed,
    this.onEpisodeListPressed,
    this.onControlsVisibilityChanged,
    this.showSkipIntro = false,
    this.onSkipIntro,
    this.showSkipOutro = false,
    this.onSkipOutro,
    this.isBuffering = false,
    this.isNetworkStalled = false,
    this.stallSeconds = 0,
    this.onRetryPlayback,
    this.onSwitchServer,
  });

  @override
  State<VideoPlayerOverlay> createState() => _VideoPlayerOverlayState();
}

class _VideoPlayerOverlayState extends State<VideoPlayerOverlay> {
  bool _isVisible = true;
  Timer? _hideTimer;
  bool _isDragging = false;
  double _dragValueSeconds = 0.0;

  @override
  void initState() {
    super.initState();
    _startHideTimer();
  }

  @override
  void didUpdateWidget(VideoPlayerOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying && widget.isPlaying) {
      _startHideTimer();
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    if (!widget.isPlaying || _isDragging) return;
    _hideTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _isVisible = false;
        });
        widget.onControlsVisibilityChanged?.call(false);
      }
    });
  }

  void _toggleVisibility() {
    setState(() {
      _isVisible = !_isVisible;
    });
    widget.onControlsVisibilityChanged?.call(_isVisible);
    if (_isVisible) {
      _startHideTimer();
    }
  }

  String _formatDuration(Duration duration) {
    if (duration < Duration.zero) duration = Duration.zero;
    final totalSeconds = duration.inSeconds;
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    if (duration.inHours > 0) {
      final hours = duration.inHours.toString();
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final effectiveTotalDuration = widget.totalDuration > Duration.zero
        ? widget.totalDuration
        : Duration.zero;

    final currentSeconds = _isDragging
        ? _dragValueSeconds
        : (effectiveTotalDuration > Duration.zero
            ? widget.currentPosition.inSeconds
                .toDouble()
                .clamp(0.0, effectiveTotalDuration.inSeconds.toDouble())
            : 0.0);

    final maxSeconds = effectiveTotalDuration.inSeconds > 0
        ? effectiveTotalDuration.inSeconds.toDouble()
        : 1.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 600;

        return GestureDetector(
          onTap: _toggleVisibility,
          behavior: HitTestBehavior.opaque,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // If locked, show only floating unlock button when visible
              if (widget.isLocked) ...[
                if (_isVisible)
                  Positioned(
                    left: 20,
                    bottom: 24,
                    child: SafeArea(
                      child: GestureDetector(
                        onTap: widget.onToggleLock,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white30, width: 1),
                          ),
                          child: const Icon(
                            Icons.lock_rounded,
                            color: AppColors.accent,
                            size: 26,
                          ),
                        ),
                      ),
                    ),
                  ),
              ] else ...[
                // Top and Bottom Controls with animated fade
                AnimatedOpacity(
                  opacity: _isVisible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 250),
                  child: IgnorePointer(
                    ignoring: !_isVisible,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Top Gradient Shadow
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          height: widget.isFullscreen ? 90 : 54,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.82),
                                  Colors.black.withValues(alpha: 0.40),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Bottom Gradient Shadow
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          height: 120,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.88),
                                  Colors.black.withValues(alpha: 0.50),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),

                        // 1. Top Bar: Back Button, Title, and Action Icons
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: SafeArea(
                            bottom: false,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              child: Row(
                                children: [
                                  // Back Button & Title (only in Fullscreen to avoid duplicating Scaffold AppBar in portrait)
                                  if (widget.isFullscreen) ...[
                                    IconButton(
                                      icon: const Icon(
                                        Icons.arrow_back,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                      padding: const EdgeInsets.all(4),
                                      constraints: const BoxConstraints(
                                        minWidth: 34,
                                        minHeight: 34,
                                      ),
                                      onPressed: widget.onBackPressed,
                                    ),
                                    const SizedBox(width: 4),

                                    // Anime Title / Episode (tapping opens Episode Drawer)
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: widget.onEpisodeListPressed,
                                        behavior: HitTestBehavior.opaque,
                                        child: Text(
                                          widget.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: isCompact ? 13.0 : 14.5,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: -0.2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ] else ...[
                                    const Spacer(),
                                  ],
                                  const SizedBox(width: 4),

                                  if (isCompact) ...[
                                    // In portrait / compact: Subtitle CC and 3-dots More menu
                                    _buildTopIcon(
                                      icon: widget.isSubIndoActive
                                          ? Icons.subtitles_rounded
                                          : Icons.subtitles_outlined,
                                      tooltip: widget.isSubIndoActive
                                          ? 'Subtitle Indonesia (Aktif)'
                                          : 'Subtitle Indonesia (Nonaktif)',
                                      color: widget.isSubIndoActive
                                          ? AppColors.accent
                                          : Colors.white,
                                      onPressed: widget.onSubtitlesPressed,
                                    ),
                                    _buildTopIcon(
                                      icon: Icons.more_vert_rounded,
                                      tooltip: 'Opsi Video Lengkap',
                                      onPressed: widget.onMorePressed,
                                    ),
                                  ] else ...[
                                    // In widescreen / landscape / tablet: full suite of 8 icons
                                    _buildTopIcon(
                                      icon: Icons.speed_rounded,
                                      tooltip: 'Kecepatan',
                                      onPressed: widget.onSpeedPressed,
                                    ),
                                    _buildTopIcon(
                                      icon: Icons.timer_outlined,
                                      tooltip: 'Timer Tidur',
                                      onPressed: widget.onTimerPressed,
                                    ),
                                    _buildTopIcon(
                                      icon: Icons.video_library_outlined,
                                      tooltip: 'Daftar Episode',
                                      onPressed:
                                          widget.onEpisodeListPressed ?? () {},
                                    ),
                                    _buildTopIcon(
                                      icon: widget.isSubIndoActive
                                          ? Icons.subtitles_rounded
                                          : Icons.subtitles_outlined,
                                      tooltip: widget.isSubIndoActive
                                          ? 'Subtitle Indonesia (Aktif)'
                                          : 'Subtitle Indonesia (Nonaktif)',
                                      color: widget.isSubIndoActive
                                          ? AppColors.accent
                                          : Colors.white,
                                      onPressed: widget.onSubtitlesPressed,
                                    ),
                                    _buildTopIcon(
                                      icon: Icons.mic_none_rounded,
                                      tooltip: 'Audio (SUB/DUB)',
                                      onPressed: widget.onAudioTrackPressed,
                                    ),
                                    _buildTopIcon(
                                      icon: Icons.cast_rounded,
                                      tooltip: 'Cast ke TV',
                                      onPressed: widget.onCastPressed,
                                    ),
                                    _buildTopIcon(
                                      icon: Icons.picture_in_picture_alt_rounded,
                                      tooltip: 'Picture in Picture',
                                      onPressed: widget.onPipPressed,
                                    ),
                                    _buildTopIcon(
                                      icon: Icons.more_vert_rounded,
                                      tooltip: 'Opsi Lainnya',
                                      onPressed: widget.onMorePressed,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),

                        // 2. Bottom Area: Progress Bar + Bottom Controls Row
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: SafeArea(
                            top: false,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                isCompact ? 10 : 16,
                                0,
                                isCompact ? 10 : 16,
                                isCompact ? 4 : 8,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Progress / Seek Bar with left and right timestamps
                                  Row(
                                    children: [
                                      // Left Current Time (e.g. 20:28)
                                      SizedBox(
                                        width: isCompact ? 38 : 44,
                                        child: Text(
                                          _formatDuration(
                                            Duration(
                                                seconds: currentSeconds.toInt()),
                                          ),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: isCompact ? 11 : 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),

                                      // Sleek Emerald Green Slider
                                      Expanded(
                                        child: SliderTheme(
                                          data: SliderThemeData(
                                            trackHeight: isCompact ? 2.8 : 3.2,
                                            activeTrackColor: AppColors.accent,
                                            inactiveTrackColor: Colors.white
                                                .withValues(alpha: 0.35),
                                            thumbColor: Colors.white,
                                            thumbShape: RoundSliderThumbShape(
                                              enabledThumbRadius:
                                                  isCompact ? 5.5 : 6.5,
                                              elevation: 2,
                                            ),
                                            overlayColor: AppColors.accent
                                                .withValues(alpha: 0.22),
                                            overlayShape:
                                                RoundSliderOverlayShape(
                                              overlayRadius:
                                                  isCompact ? 11.0 : 14.0,
                                            ),
                                            trackShape:
                                                const RectangularSliderTrackShape(),
                                          ),
                                          child: Slider(
                                            min: 0.0,
                                            max: maxSeconds > 0
                                                ? maxSeconds
                                                : 1.0,
                                            value: currentSeconds.clamp(
                                                0.0,
                                                maxSeconds > 0
                                                    ? maxSeconds
                                                    : 1.0),
                                            onChangeStart: (val) {
                                              setState(() {
                                                _isDragging = true;
                                                _dragValueSeconds = val;
                                              });
                                              _hideTimer?.cancel();
                                            },
                                            onChanged: (val) {
                                              setState(() {
                                                _dragValueSeconds = val;
                                              });
                                            },
                                            onChangeEnd: (val) {
                                              setState(() {
                                                _isDragging = false;
                                              });
                                              widget.onSeek(
                                                Duration(seconds: val.toInt()),
                                              );
                                              _startHideTimer();
                                            },
                                          ),
                                        ),
                                      ),

                                      // Right Total Duration (e.g. 24:20)
                                      SizedBox(
                                        width: isCompact ? 38 : 44,
                                        child: Text(
                                          effectiveTotalDuration > Duration.zero
                                              ? _formatDuration(effectiveTotalDuration)
                                              : '--:--',
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: isCompact ? 11 : 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 2),

                                  // Bottom Controls Row wrapped in FittedBox to guarantee ZERO overflow on any screen
                                  SizedBox(
                                    width: double.infinity,
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.center,
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          minWidth: (constraints.maxWidth -
                                                  (isCompact ? 16 : 32))
                                              .clamp(0.0, double.infinity),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                          // Left Cluster: Lock & Volume/Mute
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              _buildBottomIconButton(
                                                icon: Icons.lock_outline_rounded,
                                                tooltip: 'Kunci Layar',
                                                size: isCompact ? 19 : 21,
                                                onPressed: widget.onToggleLock,
                                              ),
                                              _buildBottomIconButton(
                                                icon: widget.isMuted
                                                    ? Icons.volume_off_rounded
                                                    : Icons.volume_up_rounded,
                                                tooltip: widget.isMuted
                                                    ? 'Bunyikan'
                                                    : 'Bisukan',
                                                size: isCompact ? 20 : 22,
                                                onPressed: widget.onToggleMute,
                                              ),
                                            ],
                                          ),

                                          // Center Cluster: Prev, Rewind 10, Play/Pause, Forward 10, Next
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (widget.onPreviousEpisode !=
                                                  null)
                                                _buildBottomIconButton(
                                                  icon: Icons
                                                      .skip_previous_rounded,
                                                  tooltip: 'Episode Sebelumnya',
                                                  size: isCompact ? 22 : 26,
                                                  onPressed:
                                                      widget.onPreviousEpisode!,
                                                ),
                                              _buildBottomIconButton(
                                                icon: Icons.replay_10_rounded,
                                                tooltip: 'Mundur 10d',
                                                size: isCompact ? 22 : 26,
                                                onPressed: widget.onRewind10,
                                              ),
                                              const SizedBox(width: 4),
                                              GestureDetector(
                                                onTap:
                                                    widget.onPlayPausePressed,
                                                behavior:
                                                    HitTestBehavior.opaque,
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal:
                                                        isCompact ? 4.0 : 8.0,
                                                  ),
                                                  child: widget.isBuffering &&
                                                          !widget.isNetworkStalled
                                                      ? SizedBox(
                                                          width: isCompact ? 32 : 40,
                                                          height: isCompact ? 32 : 40,
                                                          child: const Padding(
                                                            padding: EdgeInsets.all(4.0),
                                                            child: CircularProgressIndicator(
                                                              strokeWidth: 2.8,
                                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                            ),
                                                          ),
                                                        )
                                                      : Icon(
                                                          widget.isPlaying
                                                              ? Icons.pause_rounded
                                                              : Icons.play_arrow_rounded,
                                                          color: Colors.white,
                                                          size: isCompact ? 38 : 46,
                                                        ),
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              _buildBottomIconButton(
                                                icon: Icons.forward_10_rounded,
                                                tooltip: 'Maju 10d',
                                                size: isCompact ? 22 : 26,
                                                onPressed: widget.onForward10,
                                              ),
                                              if (widget.onNextEpisode != null)
                                                _buildBottomIconButton(
                                                  icon: Icons.skip_next_rounded,
                                                  tooltip: 'Episode Berikutnya',
                                                  size: isCompact ? 22 : 26,
                                                  onPressed:
                                                      widget.onNextEpisode!,
                                                ),
                                            ],
                                          ),

                                          // Right Cluster: Download (if not compact) & Fullscreen
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (!isCompact)
                                                _buildBottomIconButton(
                                                  icon: Icons
                                                      .file_download_outlined,
                                                  tooltip: 'Unduh Episode',
                                                  size: 22,
                                                  onPressed:
                                                      widget.onDownloadPressed,
                                                ),
                                              _buildBottomIconButton(
                                                icon: widget.isFullscreen
                                                    ? Icons
                                                        .fullscreen_exit_rounded
                                                    : Icons.fullscreen_rounded,
                                                tooltip: widget.isFullscreen
                                                    ? 'Keluar Layar Penuh'
                                                    : 'Layar Penuh',
                                                size: isCompact ? 22 : 25,
                                                onPressed:
                                                    widget.onToggleFullscreen,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 3. Floating Skip Intro Button (Visible whenever intro is active)
                if (widget.showSkipIntro && widget.onSkipIntro != null)
                  Positioned(
                    bottom: _isVisible
                        ? (isCompact ? 96.0 : 108.0)
                        : (isCompact ? 28.0 : 36.0),
                    right: isCompact ? 16.0 : 28.0,
                    child: SafeArea(
                      child: _buildSkipPillButton(
                        label: 'Lewati Intro',
                        icon: Icons.fast_forward_rounded,
                        isCompact: isCompact,
                        onTap: widget.onSkipIntro!,
                      ),
                    ),
                  ),

                // 4. Floating Skip Outro / Ending Button (Visible whenever outro is active)
                if (widget.showSkipOutro &&
                    widget.onSkipOutro != null &&
                    !widget.showSkipIntro)
                  Positioned(
                    bottom: _isVisible
                        ? (isCompact ? 96.0 : 108.0)
                        : (isCompact ? 28.0 : 36.0),
                    right: isCompact ? 16.0 : 28.0,
                    child: SafeArea(
                      child: _buildSkipPillButton(
                        label: 'Lewati Ending',
                        icon: Icons.skip_next_rounded,
                        isCompact: isCompact,
                        onTap: widget.onSkipOutro!,
                      ),
                    ),
                  ),

                // 5. Centered Buffering / Network Lag Notice Card
                if (widget.isBuffering)
                  Center(
                    child: IgnorePointer(
                      ignoring: !widget.isNetworkStalled,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: EdgeInsets.symmetric(
                          horizontal: isCompact ? 16 : 22,
                          vertical: isCompact ? 12 : 16,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10131B).withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: widget.isNetworkStalled
                                ? Colors.amber
                                : AppColors.accent.withValues(alpha: 0.6),
                            width: 1.5,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black54,
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: isCompact ? 28 : 34,
                              height: isCompact ? 28 : 34,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  widget.isNetworkStalled
                                      ? Colors.amber
                                      : AppColors.accent,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              widget.isNetworkStalled
                                  ? 'Jaringan Internet Lambat / Buffering Terhenti'
                                  : 'Memuat Video (Buffering Jaringan)...',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isCompact ? 13.0 : 14.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.isNetworkStalled
                                  ? 'Koneksi internet lambat atau server CDN video sedang sibuk.\nSilakan muat ulang atau beralih server.'
                                  : 'Menstabilkan pemutaran video...',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: isCompact ? 11.0 : 12.0,
                              ),
                            ),
                            if (widget.isNetworkStalled) ...[
                              const SizedBox(height: 12),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (widget.onRetryPlayback != null)
                                    ElevatedButton.icon(
                                      onPressed: widget.onRetryPlayback,
                                      icon: const Icon(Icons.refresh, size: 16),
                                      label: const Text('Muat Ulang'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.accent,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 8,
                                        ),
                                        minimumSize: Size.zero,
                                        textStyle: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  if (widget.onSwitchServer != null) ...[
                                    const SizedBox(width: 10),
                                    OutlinedButton.icon(
                                      onPressed: widget.onSwitchServer,
                                      icon: const Icon(Icons.dns_rounded, size: 16),
                                      label: const Text('Ganti Server'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        side: const BorderSide(
                                          color: Colors.white70,
                                          width: 1.2,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 8,
                                        ),
                                        minimumSize: Size.zero,
                                        textStyle: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildSkipPillButton({
    required String label,
    required IconData icon,
    required bool isCompact,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 14 : 18,
          vertical: isCompact ? 8 : 10,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF141720).withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: AppColors.accent,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.4),
              blurRadius: 12,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.7),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: AppColors.accent,
              size: isCompact ? 18 : 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: isCompact ? 12.5 : 14.0,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopIcon({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    Color color = Colors.white,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1.0),
      child: IconButton(
        icon: Icon(icon, color: color, size: 21),
        tooltip: tooltip,
        padding: const EdgeInsets.all(4),
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        visualDensity: VisualDensity.compact,
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildBottomIconButton({
    required IconData icon,
    required String tooltip,
    required double size,
    required VoidCallback onPressed,
    Color color = Colors.white,
  }) {
    return IconButton(
      icon: Icon(icon, color: color, size: size),
      tooltip: tooltip,
      padding: const EdgeInsets.all(3),
      constraints: BoxConstraints(minWidth: size + 8, minHeight: size + 8),
      visualDensity: VisualDensity.compact,
      onPressed: onPressed,
    );
  }
}
