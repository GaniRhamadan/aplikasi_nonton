import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/brand_logo.dart';
import 'home_screen.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    // Set system status bar icons to dark since splash screen background is white
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeOutCubic,
      ),
    );

    _fadeController.forward();

    // Navigate to next screen after splash display duration
    _navigationTimer = Timer(const Duration(milliseconds: 2100), _proceedToNextScreen);
  }

  void _proceedToNextScreen() {
    if (!mounted) return;

    // Reset system overlay to match current user theme preferences
    AppTheme.updateThemeMode(AppTheme.themeNotifier.value);

    final bool completedOnboarding = StorageService.isOnboardingCompleted;
    final Widget nextScreen = completedOnboarding
        ? const HomeScreen()
        : const OnboardingScreen();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 450),
      ),
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              const Spacer(flex: 7),
              // Iconic Centered Brand Logo
              ScaleTransition(
                scale: _scaleAnimation,
                child: const BrandLogo(
                  size: 76,
                  color: AppColors.accent,
                ),
              ),
              const Spacer(flex: 6),
              // Circular 8-Dot Loading Spinner
              const BrandDotsSpinner(
                size: 32,
                color: AppColors.accent,
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}
