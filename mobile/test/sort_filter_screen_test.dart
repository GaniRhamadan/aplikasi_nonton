import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ani_mobile/models/sort_filter_data.dart';
import 'package:ani_mobile/screens/sort_filter_screen.dart';

void main() {
  testWidgets('SortFilterScreen renders all 5 sections and buttons properly',
      (WidgetTester tester) async {
    SortFilterData? appliedResult;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  final res = await Navigator.push<SortFilterData>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SortFilterScreen(),
                    ),
                  );
                  appliedResult = res;
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );

    // Tap to open SortFilterScreen
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    // 1. Verify Header
    expect(find.text('Sort & Filter'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);

    // 2. Verify Section Titles
    expect(find.text('Sort'), findsOneWidget);
    expect(find.text('Categories'), findsOneWidget);
    expect(find.text('Region'), findsOneWidget);
    expect(find.text('Genre'), findsOneWidget);
    expect(find.text('Release Year'), findsOneWidget);

    // 3. Verify Sort options
    expect(find.text('Popularity'), findsOneWidget);
    expect(find.text('Latest Release'), findsOneWidget);

    // 4. Verify Categories options
    expect(find.text('Episode'), findsOneWidget);
    expect(find.text('Movie'), findsOneWidget);

    // 5. Verify Region options
    expect(find.text('Japan'), findsOneWidget);
    expect(find.text('Chinese'), findsOneWidget);
    expect(find.text('Others'), findsOneWidget);

    // 6. Verify Genres options matching screenshot
    expect(find.text('Action'), findsOneWidget);
    expect(find.text('Slice of Life'), findsOneWidget);
    expect(find.text('Magic'), findsOneWidget);
    expect(find.text('Sci-Fi'), findsOneWidget);
    expect(find.text('Mystery'), findsOneWidget);
    expect(find.text('Comedy'), findsOneWidget);
    expect(find.text('Romance'), findsOneWidget);
    expect(find.text('Drama'), findsOneWidget);

    // 7. Verify Bottom buttons
    expect(find.text('Reset'), findsOneWidget);
    expect(find.text('Apply'), findsOneWidget);

    // Select Romance genre and Movie category
    await tester.tap(find.text('Romance'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Movie'));
    await tester.pumpAndSettle();

    // Tap Apply
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    // Verify returned data
    expect(appliedResult, isNotNull);
    expect(appliedResult!.genre, 'Romance');
    expect(appliedResult!.category, 'Movie');
  });

  testWidgets('SortFilterScreen Reset resets all selections',
      (WidgetTester tester) async {
    SortFilterData? appliedResult;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  final res = await Navigator.push<SortFilterData>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SortFilterScreen(),
                    ),
                  );
                  appliedResult = res;
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    // Tap Reset
    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();

    // Tap Apply
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    expect(appliedResult, isNotNull);
    expect(appliedResult!.genre, 'All');
    expect(appliedResult!.category, 'Episode');
    expect(appliedResult!.region, 'All');
    expect(appliedResult!.releaseYear, 'All');
  });

  testWidgets('SortFilterScreen See all toggles expandable items',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SortFilterScreen(),
      ),
    );

    // Initial state: Isekai should not be visible yet
    expect(find.text('Isekai'), findsNothing);

    // Tap "See all" for genre (first "See all" text widget)
    await tester.tap(find.text('See all').first);
    await tester.pumpAndSettle();

    // Now expanded items should be visible
    expect(find.text('Isekai'), findsOneWidget);
    expect(find.text('Fantasy'), findsOneWidget);
    expect(find.text('See less'), findsOneWidget);
  });
}
