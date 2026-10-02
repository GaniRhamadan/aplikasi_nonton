import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ani_mobile/widgets/download_progress_dialog.dart';

void main() {
  testWidgets('DownloadProgressDialog renders all visual elements per Figma reference',
      (WidgetTester tester) async {
    bool hideCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () {
                  DownloadProgressDialog.show(
                    context,
                    episodeNumber: 1,
                    autoSimulate: false,
                    onHide: () => hideCalled = true,
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      ),
    );

    // Open dialog
    await tester.tap(find.text('Show Dialog'));
    await tester.pumpAndSettle();

    // 1. Title
    expect(find.text('Download'), findsOneWidget);

    // 2. Subtitle
    expect(
      find.text('Episode 1 is still downloading...\nPlease wait or hide the process'),
      findsOneWidget,
    );

    // 3. Stats & Percentage
    expect(find.text('122.8 / 239.5 MB'), findsOneWidget);
    expect(find.text('47%'), findsOneWidget);

    // 4. Progress bar and cancel icon
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.byIcon(Icons.close_rounded), findsOneWidget);

    // 5. Hide button
    expect(find.text('Hide'), findsOneWidget);

    // Tap Hide button
    await tester.tap(find.text('Hide'));
    await tester.pumpAndSettle();

    expect(hideCalled, isTrue);
    expect(find.text('Hide'), findsNothing);
  });

  testWidgets('DownloadProgressDialog cancel button triggers onCancel callback',
      (WidgetTester tester) async {
    bool cancelCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () {
                  DownloadProgressDialog.show(
                    context,
                    episodeNumber: 2,
                    autoSimulate: false,
                    onCancel: () => cancelCalled = true,
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show Dialog'));
    await tester.pumpAndSettle();

    expect(
      find.text('Episode 2 is still downloading...\nPlease wait or hide the process'),
      findsOneWidget,
    );

    // Tap close icon
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    expect(cancelCalled, isTrue);
    expect(find.text('Episode 2 is still downloading...'), findsNothing);
  });
}
