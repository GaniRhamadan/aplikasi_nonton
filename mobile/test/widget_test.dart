import 'package:flutter_test/flutter_test.dart';
import 'package:ani_mobile/main.dart';

void main() {
  testWidgets('AniMobile smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AniMobileApp());

    // Verify AniMobile title exists
    expect(find.text('AniMobile'), findsOneWidget);
  });
}
