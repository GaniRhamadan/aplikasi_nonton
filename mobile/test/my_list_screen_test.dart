import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ani_mobile/models/anime_models.dart';
import 'package:ani_mobile/screens/favorite_screen.dart';
import 'package:ani_mobile/services/storage_service.dart';
import 'package:ani_mobile/widgets/brand_logo.dart';
import 'package:ani_mobile/widgets/empty_my_list_view.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
  });

  testWidgets('MyListScreen renders empty state when no anime added (matching Figma)',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: FavoriteScreen(isTab: true),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify Top Bar Header
    expect(find.byType(BrandLogo), findsOneWidget);
    expect(find.text('My List'), findsOneWidget);
    expect(find.byIcon(Icons.search_rounded), findsOneWidget);

    // 2. Verify Empty state view
    expect(find.byType(EmptyMyListView), findsOneWidget);
    expect(find.text('Your List is Empty'), findsOneWidget);
    expect(
      find.text("It seems that you haven't added\nany anime to the list"),
      findsOneWidget,
    );
  });

  testWidgets('MyListScreen displays anime items when bookmarks exist',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Pre-populate bookmark
    const sampleAnime = AnimeItem(
      id: '101922',
      slug: 'kimetsu-no-yaiba',
      title: 'Kimetsu no Yaiba',
      posterUrl: 'https://example.com/poster.jpg',
      genres: ['Action', 'Fantasy'],
    );
    await StorageService.toggleBookmark(sampleAnime);

    await tester.pumpWidget(
      const MaterialApp(
        home: FavoriteScreen(isTab: true),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify header
    expect(find.text('My List'), findsOneWidget);

    // 2. Empty state should NOT be visible
    expect(find.byType(EmptyMyListView), findsNothing);

    // 3. GridView of anime cards with rating badge should be present
    expect(find.byType(GridView), findsOneWidget);
    expect(find.text('9.8'), findsOneWidget);
  });
}
