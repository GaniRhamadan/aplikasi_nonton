import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ani_mobile/models/anime_models.dart';
import 'package:ani_mobile/widgets/player_episode_drawer.dart';

void main() {
  final sampleEpisodes = List.generate(
    10,
    (i) => EpisodeItem(
      id: '${i + 1}',
      number: i + 1,
      title: 'Episode ${i + 1}',
      slug: 'demon-slayer',
    ),
  );

  testWidgets('PlayerEpisodeDrawer renders header, episodes, duration, and progress line',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    bool closed = false;
    EpisodeItem? selectedEp;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PlayerEpisodeDrawer(
            episodes: sampleEpisodes,
            currentEpisodeNumber: 1,
            currentProgress: 0.85,
            totalDurationText: '24:20',
            onEpisodeSelected: (ep) => selectedEp = ep,
            onClose: () => closed = true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify Header
    expect(find.text('Episode'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);

    // 2. Verify Episodes & Duration
    expect(find.text('Episode 1'), findsOneWidget);
    expect(find.text('Episode 2'), findsOneWidget);
    expect(find.text('Episode 3'), findsOneWidget);
    expect(find.text('Episode 4'), findsOneWidget);
    expect(find.text('Episode 5'), findsOneWidget);
    expect(find.text('24:20'), findsWidgets);

    // 3. Test Back Arrow Close
    await tester.tap(find.byIcon(Icons.arrow_back));
    expect(closed, isTrue);

    // 4. Test Episode Selection
    await tester.tap(find.text('Episode 3'));
    expect(selectedEp?.number, equals(3));
  });
}
