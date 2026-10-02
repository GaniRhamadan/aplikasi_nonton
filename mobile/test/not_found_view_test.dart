import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ani_mobile/widgets/not_found_view.dart';

void main() {
  testWidgets('NotFoundView renders correctly with title and description',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: NotFoundView(keyword: 'xyznonexistentanime'),
        ),
      ),
    );

    // Verify "Not Found" heading exists
    expect(find.text('Not Found'), findsOneWidget);

    // Verify description exists
    expect(
      find.text(
          'Sorry, the keyword you entered could not be found. Try to check again or search with other keywords.'),
      findsOneWidget,
    );
  });
}
