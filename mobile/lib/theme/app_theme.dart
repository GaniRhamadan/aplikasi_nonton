import 'package:flutter/material.dart';

class AppColors {
  // Canvas & Surfaces (Deep Sleek Dark matching the screenshot UI)
  static const Color canvas = Color(0xFF0C0D11); // Pure deep dark background
  static const Color surface = Color(0xFF14151B); // Card surface
  static const Color surfaceMuted = Color(0xFF1C1E26); // Elevated surface
  static const Color surfaceHighlight = Color(0xFF252834);
  static const Color border = Color(0xFF232532); // Subtle borders
  static const Color borderHover = Color(0xFF333748);

  // Text Hierarchy (WCAG compliant on dark background)
  static const Color textPrimary = Color(0xFFFFFFFF); // Pure White
  static const Color textSecondary = Color(0xFF94A3B8); // Slate 400
  static const Color textMuted = Color(0xFF64748B); // Slate 500

  // Brand Accent (Anime Orange / Coral)
  static const Color accent = Color(0xFFFA5A32); // Vibrant Orange #FA5A32
  static const Color accentHover = Color(0xFFFF6E40);
  static const Color accentMuted = Color(0x28FA5A32); // 16% opacity
  static const Color accentBorder = Color(0x60FA5A32);

  // UI Specific Tokens from Screenshot
  static const Color viewsRed = Color(0xFFFF3B30); // Red play icon & view count
  static const Color favYellow = Color(0xFFFFCC00); // Yellow star & favorites count
  static const Color dateCyan = Color(0xFF38BDF8); // Sky blue calendar date
  static const Color badgePurple = Color(0xFFC084FC); // Purple "new !!" badge
  static const Color success = Color(0xFF30D158);

  // Bottom Navigation Bar
  static const Color navBackground = Color(0xFF101116);
  static const Color navUnselected = Color(0xFF64748B);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.canvas,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accent,
        onPrimary: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        outline: AppColors.border,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.canvas,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.4,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceMuted,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
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
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.border, width: 1.2),
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

  // Keep lightTheme getter pointing to darkTheme for consistency
  static ThemeData get lightTheme => darkTheme;
}
