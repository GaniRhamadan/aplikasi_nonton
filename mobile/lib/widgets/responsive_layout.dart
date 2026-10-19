import 'package:flutter/material.dart';

class ResponsiveLayout {
  /// Checks whether current window width qualifies as a desktop/wide screen
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 768;
  }

  /// Returns effective content width excluding the 220px desktop sidebar if present
  static double contentWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return isDesktop(context) ? (width - 220) : width;
  }

  /// Calculates optimal grid column count based on available viewport width
  static int gridColumns(
    BuildContext context, {
    double targetItemWidth = 180,
    int minColumns = 2,
    int maxColumns = 8,
  }) {
    final available = contentWidth(context);
    final count = (available / targetItemWidth).floor();
    return count.clamp(minColumns, maxColumns);
  }
}
