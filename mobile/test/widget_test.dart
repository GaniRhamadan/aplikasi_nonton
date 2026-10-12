import 'package:flutter_test/flutter_test.dart';
import 'package:ani_mobile/main.dart';

void main() {
  testWidgets('Anirama smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AniramaApp());

    // Verify MaterialApp widget exists
    expect(find.byType(AniramaApp), findsOneWidget);
  });
}
