import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ani_mobile/models/anime_models.dart';
import 'package:ani_mobile/screens/download_tab.dart';
import 'package:ani_mobile/services/storage_service.dart';
import 'package:ani_mobile/widgets/brand_logo.dart';
import 'package:ani_mobile/widgets/empty_download_view.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
  });

  testWidgets('DownloadTab renders empty state when no downloads (matching Figma)',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: DownloadTab(isTab: true),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify Top Bar Header
    expect(find.byType(BrandLogo), findsOneWidget);
    expect(find.text('Download'), findsOneWidget);
    expect(find.byIcon(Icons.search_rounded), findsOneWidget);

    // 2. Verify Empty state view
    expect(find.byType(EmptyDownloadView), findsOneWidget);
    expect(find.text('Your Download is Empty'), findsOneWidget);
    expect(
      find.text("Looks like you haven't downloaded\nanime at all"),
      findsOneWidget,
    );
  });

  testWidgets('DownloadTab displays download items and supports deletion',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Add a downloaded episode
    const item = DownloadItem(
      animeId: '101922',
      animeSlug: 'kimetsu-no-yaiba',
      animeTitle: 'Demon Slayer',
      animePoster: 'https://example.com/poster.jpg',
      episodeNumber: 1,
      episodeTitle: 'Episode 1',
      resolution: '720p',
      sizeMb: 239.5,
    );
    await StorageService.saveDownload(item);

    await tester.pumpWidget(
      const MaterialApp(
        home: DownloadTab(isTab: true),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Header
    expect(find.text('Download'), findsOneWidget);

    // 2. Empty view not visible
    expect(find.byType(EmptyDownloadView), findsNothing);

    // 3. Item details
    expect(find.text('Demon Slayer'), findsOneWidget);
    expect(find.text('Episode 1'), findsOneWidget);
    expect(find.text('239.5 MB'), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);

    // 4. Tap delete icon to open Delete Confirmation Bottom Sheet
    await tester.tap(find.byIcon(Icons.delete_outline_rounded));
    await tester.pumpAndSettle();

    // Verify Bottom Sheet elements per Figma reference
    expect(find.text('Delete'), findsOneWidget);
    expect(find.text('Are you sure you want to delete this\ndownload?'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Yes, Delete'), findsOneWidget);

    // Test Cancel flow: tapping Cancel should dismiss the sheet without deleting
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Demon Slayer'), findsOneWidget);
    expect(find.byType(EmptyDownloadView), findsNothing);

    // Tap delete icon again
    await tester.tap(find.byIcon(Icons.delete_outline_rounded));
    await tester.pumpAndSettle();

    // Test Confirm flow: tapping "Yes, Delete" should delete the download
    await tester.tap(find.text('Yes, Delete'));
    await tester.pumpAndSettle();

    // Now empty state should appear!
    expect(find.byType(EmptyDownloadView), findsOneWidget);
    expect(find.text('Your Download is Empty'), findsOneWidget);
  });
}
