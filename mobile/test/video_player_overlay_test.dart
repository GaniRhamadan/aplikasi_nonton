import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ani_mobile/widgets/video_player_overlay.dart';

void main() {
  testWidgets('VideoPlayerOverlay renders all controls matching Figma screenshot',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1600, 800); // Landscape
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    bool playPauseTapped = false;
    bool rewind10Tapped = false;
    bool forward10Tapped = false;
    bool lockToggled = false;
    bool speedTapped = false;
    bool timerTapped = false;
    bool subTapped = false;
    bool audioTapped = false;
    bool castTapped = false;
    bool pipTapped = false;
    bool moreTapped = false;
    bool downloadTapped = false;
    bool fullscreenTapped = false;
    bool episodeListTapped = false;
    Duration? seekDuration;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 1600,
            height: 800,
            child: VideoPlayerOverlay(
              title: 'Demon Slayer: Kimetsu no Yaiba Enter...',
              currentPosition: const Duration(minutes: 20, seconds: 28),
              totalDuration: const Duration(minutes: 24, seconds: 20),
              isPlaying: true,
              isMuted: false,
              isLocked: false,
              isFullscreen: true,
              playbackSpeed: 1.0,
              onBackPressed: () {},
              onPlayPausePressed: () => playPauseTapped = true,
              onSeek: (d) => seekDuration = d,
              onRewind10: () => rewind10Tapped = true,
              onForward10: () => forward10Tapped = true,
              onPreviousEpisode: () {},
              onNextEpisode: () {},
              onToggleMute: () {},
              onToggleLock: () => lockToggled = true,
              onToggleFullscreen: () => fullscreenTapped = true,
              onSpeedPressed: () => speedTapped = true,
              onTimerPressed: () => timerTapped = true,
              onSubtitlesPressed: () => subTapped = true,
              onAudioTrackPressed: () => audioTapped = true,
              onCastPressed: () => castTapped = true,
              onPipPressed: () => pipTapped = true,
              onMorePressed: () => moreTapped = true,
              onDownloadPressed: () => downloadTapped = true,
              onEpisodeListPressed: () => episodeListTapped = true,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify Top Bar: Title & Right Action Icons
    expect(find.text('Demon Slayer: Kimetsu no Yaiba Enter...'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    expect(find.byIcon(Icons.speed_rounded), findsOneWidget);
    expect(find.byIcon(Icons.timer_outlined), findsOneWidget);
    expect(find.byIcon(Icons.video_library_outlined), findsOneWidget);
    expect(find.byIcon(Icons.subtitles_rounded), findsOneWidget);
    expect(find.byIcon(Icons.mic_none_rounded), findsOneWidget);
    expect(find.byIcon(Icons.cast_rounded), findsOneWidget);
    expect(find.byIcon(Icons.picture_in_picture_alt_rounded), findsOneWidget);
    expect(find.byIcon(Icons.more_vert_rounded), findsOneWidget);

    // 2. Verify Seekbar Timestamps
    expect(find.text('20:28'), findsOneWidget);
    expect(find.text('24:20'), findsOneWidget);
    expect(find.byType(Slider), findsOneWidget);

    // 3. Verify Bottom Bar Left: Lock & Volume
    expect(find.byIcon(Icons.lock_outline_rounded), findsOneWidget);
    expect(find.byIcon(Icons.volume_up_rounded), findsOneWidget);

    // 4. Verify Bottom Bar Center: Rewind 10, Skip Prev, Pause/Play, Skip Next, Forward 10
    expect(find.byIcon(Icons.replay_10_rounded), findsOneWidget);
    expect(find.byIcon(Icons.skip_previous_rounded), findsOneWidget);
    expect(find.byIcon(Icons.pause_rounded), findsOneWidget); // isPlaying = true
    expect(find.byIcon(Icons.skip_next_rounded), findsOneWidget);
    expect(find.byIcon(Icons.forward_10_rounded), findsOneWidget);

    // 5. Verify Bottom Bar Right: Download & Fullscreen
    expect(find.byIcon(Icons.file_download_outlined), findsOneWidget);
    expect(find.byIcon(Icons.fullscreen_exit_rounded), findsOneWidget); // isFullscreen = true

    // 6. Test Interactive callbacks
    await tester.tap(find.byIcon(Icons.pause_rounded));
    expect(playPauseTapped, isTrue);

    await tester.tap(find.byIcon(Icons.replay_10_rounded));
    expect(rewind10Tapped, isTrue);

    await tester.tap(find.byIcon(Icons.forward_10_rounded));
    expect(forward10Tapped, isTrue);

    await tester.tap(find.byIcon(Icons.speed_rounded));
    expect(speedTapped, isTrue);

    await tester.tap(find.byIcon(Icons.timer_outlined));
    expect(timerTapped, isTrue);

    await tester.tap(find.byIcon(Icons.video_library_outlined));
    expect(episodeListTapped, isTrue);

    await tester.tap(find.byIcon(Icons.subtitles_rounded));
    expect(subTapped, isTrue);

    await tester.tap(find.byIcon(Icons.mic_none_rounded));
    expect(audioTapped, isTrue);

    await tester.tap(find.byIcon(Icons.cast_rounded));
    expect(castTapped, isTrue);

    await tester.tap(find.byIcon(Icons.picture_in_picture_alt_rounded));
    expect(pipTapped, isTrue);

    await tester.tap(find.byIcon(Icons.more_vert_rounded));
    expect(moreTapped, isTrue);

    await tester.tap(find.byIcon(Icons.file_download_outlined));
    expect(downloadTapped, isTrue);

    await tester.tap(find.byIcon(Icons.fullscreen_exit_rounded));
    expect(fullscreenTapped, isTrue);

    await tester.tap(find.byIcon(Icons.lock_outline_rounded));
    expect(lockToggled, isTrue);

    // Drag slider to test onSeek
    await tester.drag(find.byType(Slider), const Offset(50, 0));
    await tester.pumpAndSettle();
    expect(seekDuration, isNotNull);
  });

  testWidgets('VideoPlayerOverlay when locked hides controls and shows lock badge',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1600, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    bool unlockToggled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 1600,
            height: 800,
            child: VideoPlayerOverlay(
              title: 'Demon Slayer',
              currentPosition: const Duration(minutes: 5),
              totalDuration: const Duration(minutes: 24),
              isPlaying: true,
              isMuted: false,
              isLocked: true, // LOCKED
              isFullscreen: true,
              playbackSpeed: 1.0,
              onBackPressed: () {},
              onPlayPausePressed: () {},
              onSeek: (d) {},
              onRewind10: () {},
              onForward10: () {},
              onToggleMute: () {},
              onToggleLock: () => unlockToggled = true,
              onToggleFullscreen: () {},
              onSpeedPressed: () {},
              onTimerPressed: () {},
              onSubtitlesPressed: () {},
              onAudioTrackPressed: () {},
              onCastPressed: () {},
              onPipPressed: () {},
              onMorePressed: () {},
              onDownloadPressed: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Standard controls should not be rendered
    expect(find.text('Demon Slayer'), findsNothing);
    expect(find.byIcon(Icons.pause_rounded), findsNothing);

    // Floating lock icon should be present
    expect(find.byIcon(Icons.lock_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.lock_rounded));
    expect(unlockToggled, isTrue);
  });

  testWidgets('VideoPlayerOverlay renders clickable Lewati Intro button when showSkipIntro is true',
      (WidgetTester tester) async {
    bool skipIntroTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 800,
            height: 450,
            child: VideoPlayerOverlay(
              title: 'Jujutsu Kaisen Episode 1',
              currentPosition: const Duration(seconds: 45),
              totalDuration: const Duration(minutes: 24),
              isPlaying: true,
              isMuted: false,
              isLocked: false,
              isFullscreen: false,
              showSkipIntro: true,
              onSkipIntro: () => skipIntroTapped = true,
              onBackPressed: () {},
              onPlayPausePressed: () {},
              onSeek: (d) {},
              onRewind10: () {},
              onForward10: () {},
              onToggleMute: () {},
              onToggleLock: () {},
              onToggleFullscreen: () {},
              onSpeedPressed: () {},
              onTimerPressed: () {},
              onSubtitlesPressed: () {},
              onAudioTrackPressed: () {},
              onCastPressed: () {},
              onPipPressed: () {},
              onMorePressed: () {},
              onDownloadPressed: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify "Lewati Intro" button appears with fast forward icon
    expect(find.text('Lewati Intro'), findsOneWidget);
    expect(find.byIcon(Icons.fast_forward_rounded), findsOneWidget);

    // Tap on the button and verify callback triggers
    await tester.tap(find.text('Lewati Intro'));
    expect(skipIntroTapped, isTrue);
  });
}
