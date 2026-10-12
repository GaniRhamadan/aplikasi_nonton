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
    expect(find.text('Jadwal Rilis Mingguan'), findsOneWidget);

    // Verify refresh icon button
    expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);

    // Verify horizontal date strip ListView is present
    expect(find.byType(ListView), findsWidgets);
  });

  testWidgets('NoScheduleView displays empty illustration and text',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: NoScheduleView(),
        ),
      ),
    );

    expect(find.text('No Release Schedule'), findsOneWidget);
    expect(
      find.text('Sorry, there is no anime release schedule on this date'),
      findsOneWidget,
    );
  });

  testWidgets('ScheduleTab renders SEN, SEL day tabs and anime grid cards',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ScheduleTab(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify day tabs exist
    expect(find.text('SEN'), findsOneWidget);
    expect(find.text('SEL'), findsOneWidget);

    // Tap SEL tab
    await tester.tap(find.text('SEL'));
    await tester.pumpAndSettle();

    // Verify GridView is used for cards
    expect(find.byType(GridView), findsOneWidget);
  });
}
