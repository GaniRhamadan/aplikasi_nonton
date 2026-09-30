import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppColors {
  static bool isDarkMode = true;

  // Canvas & Surfaces
  static Color get canvas =>
      isDarkMode ? const Color(0xFF0C0D11) : const Color(0xFFF6F8FC);
  static Color get surface =>
      isDarkMode ? const Color(0xFF14151B) : const Color(0xFFFFFFFF);
  static Color get surfaceMuted =>
      isDarkMode ? const Color(0xFF1C1E26) : const Color(0xFFEFF2F7);
  static Color get surfaceHighlight =>
      isDarkMode ? const Color(0xFF252834) : const Color(0xFFE2E8F0);
  static Color get border =>
      isDarkMode ? const Color(0xFF232532) : const Color(0xFFE2E8F0);
  static Color get borderHover =>
      isDarkMode ? const Color(0xFF333748) : const Color(0xFFCBD5E1);

  // Card specific tokens
  static Color get cardBackground =>
      isDarkMode ? const Color(0xFF141724) : const Color(0xFFFFFFFF);
  static Color get cardBorder =>
      isDarkMode ? const Color(0xFF242838) : const Color(0xFFE2E8F0);

  // Text Hierarchy
  static Color get textPrimary =>
      isDarkMode ? const Color(0xFFFFFFFF) : const Color(0xFF0F172A);
  static Color get textSecondary =>
      isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF475569);
  static Color get textMuted =>
      isDarkMode ? const Color(0xFF64748B) : const Color(0xFF94A3B8);

  // Brand Accent (Anime Orange / Coral)
  static const Color accent = Color(0xFFFA5A32);
  static const Color accentHover = Color(0xFFFF6E40);
  static Color get accentMuted =>
      isDarkMode ? const Color(0x28FA5A32) : const Color(0x18FA5A32);
  static Color get accentBorder =>
      isDarkMode ? const Color(0x60FA5A32) : const Color(0x35FA5A32);

  // UI Specific Tokens
  static const Color viewsRed = Color(0xFFFF3B30);
  static const Color favYellow = Color(0xFFFFCC00);
  static const Color dateCyan = Color(0xFF38BDF8);
  static const Color badgePurple = Color(0xFFC084FC);
  static const Color success = Color(0xFF30D158);

  // Bottom Navigation Bar
  static Color get navBackground =>
      isDarkMode ? const Color(0xFF101116) : const Color(0xFFFFFFFF);
  static Color get navUnselected =>
      isDarkMode ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
}

class AppTheme {
  static final ValueNotifier<ThemeMode> themeNotifier =
      ValueNotifier<ThemeMode>(ThemeMode.dark);

  static void updateThemeMode(ThemeMode mode) {
    themeNotifier.value = mode;
    AppColors.isDarkMode = (mode == ThemeMode.dark);
    _updateSystemOverlay(mode);
  }

  static void _updateSystemOverlay(ThemeMode mode) {
    final isDark = mode == ThemeMode.dark;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor:
            isDark ? const Color(0xFF101116) : const Color(0xFFFFFFFF),
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0C0D11),
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accent,
        onPrimary: Colors.white,
        surface: Color(0xFF14151B),
        onSurface: Color(0xFFFFFFFF),
        outline: Color(0xFF232532),
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0C0D11),
        foregroundColor: Color(0xFFFFFFFF),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.4,
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF14151B),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0xFF232532), width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1C1E26),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF232532)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF232532)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFFFFFFF),
          side: const BorderSide(color: Color(0xFF232532), width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF6F8FC),
      colorScheme: const ColorScheme.light(
        primary: AppColors.accent,
        onPrimary: Colors.white,
        surface: Color(0xFFFFFFFF),
        onSurface: Color(0xFF0F172A),
        outline: Color(0xFFE2E8F0),
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF6F8FC),
        foregroundColor: Color(0xFF0F172A),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Color(0xFF0F172A),
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.4,
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFFFFFFFF),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFEEF2F6),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF0F172A),
          side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
