import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ani_mobile/screens/search_screen.dart';

void main() {
  testWidgets('SearchScreen renders Top Searches and search bar properly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SearchScreen(autoFocus: false),
      ),
    );

    // Verify search input with hint text exists
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Abcdefghijklm'), findsOneWidget);

    // Verify filter icon button exists
    expect(find.byIcon(Icons.tune_rounded), findsOneWidget);

    // Verify "Top Searches" section title
    expect(find.text('Top Searches'), findsOneWidget);

    // Verify initial seed anime matching screenshot are present
    expect(find.text('Attack on Titan Final Season Part 2'), findsOneWidget);
    expect(find.text('Demon Slayer: Entertainment Distri Arc'), findsOneWidget);
    expect(find.text('Kaguya-sama: Love is War Season 3'), findsOneWidget);
    expect(find.text('Spy x Family'), findsOneWidget);
  });

  testWidgets('SearchScreen shows 2-column GridView with rating badges on matching search',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SearchScreen(autoFocus: false),
      ),
    );

    // Enter "Season 2" into search input
    await tester.enterText(find.byType(TextField), 'Season 2');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    // Verify "Top Searches" header is gone
    expect(find.text('Top Searches'), findsNothing);

    // Verify GridView is used for search results
    expect(find.byType(GridView), findsOneWidget);

    // Verify ratings from Season 2 seed are displayed
    expect(find.text('9.8'), findsOneWidget);
    expect(find.text('9.7'), findsOneWidget);
  });

  testWidgets('SearchScreen shows NotFoundView when no anime matches the search',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SearchScreen(autoFocus: false),
      ),
    );

    // Enter a non-matching query
    await tester.enterText(find.byType(TextField), 'zzzzqwer9999notfound');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    // Verify "Top Searches" header is gone
    expect(find.text('Top Searches'), findsNothing);

    // Verify "Not Found" message from NotFoundView
    expect(find.text('Not Found'), findsOneWidget);
    expect(
      find.textContaining('zzzzqwer9999notfound'),
      findsOneWidget,
    );
  });

  testWidgets('SearchScreen opens SortFilterScreen and applies genre filter',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SearchScreen(autoFocus: false),
      ),
    );

    // Tap tune / filter icon in search bar
    await tester.tap(find.byIcon(Icons.tune_rounded));
    await tester.pumpAndSettle();

    // Verify SortFilterScreen is opened
    expect(find.text('Sort & Filter'), findsOneWidget);

    // Tap 'Action' genre chip
    await tester.tap(find.text('Action'));
    await tester.pumpAndSettle();

    // Tap Apply button
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    // Verify we are back on search screen and filter is active
    expect(find.text('Sort & Filter'), findsNothing);

    // Verify active filter chips are rendered horizontally
    expect(find.text('Popularity'), findsOneWidget);
    expect(find.text('Episode'), findsOneWidget);
    expect(find.text('Japan'), findsOneWidget);
    expect(find.text('Action'), findsOneWidget);

    // Verify 2-column GridView is rendered for matching anime
    expect(find.byType(GridView), findsOneWidget);
  });
}



