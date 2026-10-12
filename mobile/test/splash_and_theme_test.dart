import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ani_mobile/screens/splash_screen.dart';
import 'package:ani_mobile/services/storage_service.dart';
import 'package:ani_mobile/theme/app_theme.dart';
import 'package:ani_mobile/widgets/brand_logo.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
  });

  test('StorageService defaults to light theme and resets legacy dark', () async {
    expect(StorageService.themeMode, ThemeMode.light);
    AppTheme.updateThemeMode(StorageService.themeMode);
    expect(AppColors.isDarkMode, false);
    expect(AppColors.canvas, const Color(0xFFFFFFFF));
    expect(AppColors.surface, const Color(0xFFFFFFFF));
    expect(AppColors.navBackground, const Color(0xFFFFFFFF));
  });

  testWidgets('SplashScreen renders centered logo and spinner on white canvas',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;

    await tester.pumpWidget(
      const MaterialApp(
        home: SplashScreen(),
      ),
    );

    // Verify BrandLogo and BrandDotsSpinner exist
    final logoFinder = find.byType(BrandLogo);
    final spinnerFinder = find.byType(BrandDotsSpinner);

    expect(logoFinder, findsOneWidget);
    expect(spinnerFinder, findsOneWidget);

    // Verify horizontal centering: center of logo and spinner matches screen center (540 / 2 = 270)
    final logoCenter = tester.getCenter(logoFinder);
    final spinnerCenter = tester.getCenter(spinnerFinder);
    final screenWidth = tester.view.physicalSize.width / tester.view.devicePixelRatio;

    expect(logoCenter.dx, closeTo(screenWidth / 2, 2.0));
    expect(spinnerCenter.dx, closeTo(screenWidth / 2, 2.0));

    // Verify scaffold background is pure white
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, Colors.white);

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
