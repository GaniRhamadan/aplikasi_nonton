import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ani_mobile/models/anime_models.dart';
import 'package:ani_mobile/widgets/delete_download_bottom_sheet.dart';

void main() {
  const testItem = DownloadItem(
    animeId: '101922',
    animeSlug: 'kimetsu-no-yaiba',
    animeTitle: 'Demon Slayer: Kimetsu no Yaiba Entertainm...',
    animePoster: '',
    episodeNumber: 24,
    episodeTitle: 'Episode 24',
    resolution: '720p',
    sizeMb: 246.5,
  );

  testWidgets('DeleteDownloadBottomSheet renders all visual elements per Figma reference',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: DeleteDownloadBottomSheet(item: testItem),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify "Delete" Title with Red color
    final deleteTitleFinder = find.text('Delete');
    expect(deleteTitleFinder, findsOneWidget);
    final Text deleteTitleText = tester.widget(deleteTitleFinder);
    expect(deleteTitleText.style?.color, const Color(0xFFF75555));

    // 2. Verify Confirmation Prompt
    expect(
      find.text('Are you sure you want to delete this\ndownload?'),
      findsOneWidget,
    );

    // 3. Verify Item details (Title, Episode, Size pill)
    expect(
      find.text('Demon Slayer: Kimetsu no Yaiba Entertainm...'),
      findsOneWidget,
    );
    expect(find.text('Episode 24'), findsOneWidget);
    expect(find.text('246.5 MB'), findsOneWidget);

    // 4. Verify Play icon on thumbnail
    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);

    // 5. Verify action buttons
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Yes, Delete'), findsOneWidget);
  });

  testWidgets('DeleteDownloadBottomSheet.show returns false on Cancel and true on Yes, Delete',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    bool? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await DeleteDownloadBottomSheet.show(context, testItem);
              },
              child: const Text('Open Sheet'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Open bottom sheet
    await tester.tap(find.text('Open Sheet'));
    await tester.pumpAndSettle();

    // Tap Cancel
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(result, isFalse);

    // Open again
    await tester.tap(find.text('Open Sheet'));
    await tester.pumpAndSettle();

    // Tap Yes, Delete
    await tester.tap(find.text('Yes, Delete'));
    await tester.pumpAndSettle();
    expect(result, isTrue);
  });
}
