import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ani_mobile/models/anime_models.dart';
import 'package:ani_mobile/screens/anime_detail_screen.dart';

void main() {
  const testAnime = AnimeItem(
    id: '101922',
    slug: 'kimetsu-no-yaiba',
    title: 'Demon Slayer (Kimetsu no Yaiba)',
    posterUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/bx101922-PEn1CTDYeaRe.jpg',
    bannerUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/banner/101922-YfZhTBblDTad.jpg',
    score: '9.8',
    releaseDate: '2022',
    genres: ['Action', 'Martial Arts', 'Adventure', 'Dark Fantasy', 'Thriller'],
    synopsis: 'Tanjiro Kamado, a kind-hearted boy who sells charcoal for a living, finds his family slaughtered by a demon.',
    totalEpisodes: 26,
  );

  testWidgets('AnimeDetailScreen renders banner, title, metadata, buttons, episodes, and tabs',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: AnimeDetailScreen(anime: testAnime),
      ),
    );

    await tester.pumpAndSettle();

    // 1. Verify title
    expect(find.text('Demon Slayer (Kimetsu no Yaiba)'), findsOneWidget);

    // 2. Verify metadata badges
    expect(find.text('9.8'), findsOneWidget);
    expect(find.text('2022'), findsOneWidget);
    expect(find.text('13+'), findsOneWidget);
    expect(find.text('Japan'), findsOneWidget);
    expect(find.text('Subtitle'), findsOneWidget);

    // 3. Verify Play & Download action buttons
    expect(find.text('Play'), findsOneWidget);
    expect(find.text('Download'), findsOneWidget);

    // 4. Verify Genre & Expandable Synopsis
    expect(find.textContaining('Genre: Action'), findsOneWidget);
    expect(find.text('View More'), findsOneWidget);

    // 5. Verify Episodes section
    expect(find.text('Episodes'), findsOneWidget);
    expect(find.textContaining('Season'), findsOneWidget);

    // 6. Verify Bottom Tabs: "More Like This" and "Recommendations" are present
    expect(find.text('More Like This'), findsOneWidget);
    expect(find.text('Recommendations'), findsOneWidget);

    // 7. Verify "Comments" is NOT present per user instruction
    expect(find.textContaining('Comments'), findsNothing);

    // 8. Test switching to Recommendations tab
    await tester.tap(find.text('Recommendations'));
    await tester.pumpAndSettle();

    // 9. Test View More toggling to View Less
    await tester.tap(find.text('View More'));
    await tester.pumpAndSettle();
    expect(find.text('View Less'), findsOneWidget);
  });

  testWidgets('AnimeDetailScreen Download button opens new Download Bottom Sheet with resolution and episodes',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: AnimeDetailScreen(anime: testAnime),
      ),
    );

    await tester.pumpAndSettle();

    // Tap Download button
    await tester.tap(find.text('Download'));
    await tester.pumpAndSettle();

    // Verify Download modal sheet contents
    expect(find.text('Download'), findsWidgets); // Header title + button
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('720p'), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsWidgets); // Checkmark on selected episode 1

    // Tap Cancel button to close sheet
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Cancel'), findsNothing);
  });

  testWidgets('Download button in bottom sheet opens DownloadProgressDialog',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: AnimeDetailScreen(anime: testAnime),
      ),
    );
    await tester.pumpAndSettle();

    // Tap Download to open bottom sheet
    await tester.tap(find.text('Download'));
    await tester.pumpAndSettle();

    // In bottom sheet, tap the Download button (the bottom button)
    final downloadButtons = find.widgetWithText(GestureDetector, 'Download');
    expect(downloadButtons, findsWidgets);
    await tester.tap(downloadButtons.last);
    await tester.pumpAndSettle();

    // Verify DownloadProgressDialog appears
    expect(find.text('Episode 1 is still downloading...\nPlease wait or hide the process'), findsOneWidget);
    expect(find.text('122.8 / 239.5 MB'), findsOneWidget);
    expect(find.text('47%'), findsOneWidget);
    expect(find.text('Hide'), findsOneWidget);
    expect(find.byIcon(Icons.close_rounded), findsOneWidget);

    // Tap Hide button
    await tester.tap(find.text('Hide'));
    await tester.pumpAndSettle();

    // Verify dialog is dismissed
    expect(find.text('Hide'), findsNothing);
    expect(find.textContaining('sedang diunduh di latar belakang'), findsOneWidget);
  });
}

