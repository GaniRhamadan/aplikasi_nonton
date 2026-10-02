import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ani_mobile/screens/schedule_tab.dart';
import 'package:ani_mobile/widgets/no_schedule_view.dart';

void main() {
  testWidgets('NoScheduleView renders illustration, title, and description',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: NoScheduleView(),
        ),
      ),
    );

    // Verify Title
    expect(find.text('No Release Schedule'), findsOneWidget);

    // Verify Subtitle description
    expect(
      find.text('Sorry, there is no anime release schedule on this date'),
      findsOneWidget,
    );
  });

  testWidgets('ScheduleTab renders header, horizontal date strip, and calendar views',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ScheduleTab(),
      ),
    );

    // Verify App Bar Title
    expect(find.text('Release Calendar'), findsOneWidget);

    // Verify More icon button
    expect(find.byIcon(Icons.more_horiz_rounded), findsOneWidget);

    // Verify ListViews are present (horizontal date strip and vertical schedule list)
    expect(find.byType(ListView), findsNWidgets(2));

    await tester.pump(const Duration(milliseconds: 100));

    // Verify anime items from schedule matching reference design
    expect(find.text('One Piece'), findsOneWidget);
    expect(find.text('Jujutsu Kaisen Season 2'), findsOneWidget);
    expect(find.text('The Rising of The Shield..'), findsOneWidget);
    expect(find.textContaining('Current Time'), findsOneWidget);

    // Verify My List buttons are present
    expect(find.text('My List'), findsWidgets);
  });

  testWidgets('ScheduleTab switches to NoScheduleView when selecting date with no releases',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ScheduleTab(),
      ),
    );

    await tester.pumpAndSettle();

    // Initially on Mon 20 with anime list
    expect(find.text('One Piece'), findsOneWidget);

    // Tap on date 19 (which has no release schedule)
    final date19Finder = find.byKey(const ValueKey('date_pill_19'));
    expect(date19Finder, findsOneWidget);
    await tester.tap(date19Finder);
    await tester.pumpAndSettle();

    // Should now display NoScheduleView
    expect(find.text('No Release Schedule'), findsOneWidget);
      expect(
        find.text('Sorry, there is no anime release schedule on this date'),
        findsOneWidget,
      );
  });
}
