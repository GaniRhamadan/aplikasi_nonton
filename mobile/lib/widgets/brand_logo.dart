import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// The iconic brand logo: stylized inverted rounded chevron with center dot
class BrandLogo extends StatelessWidget {
  final double size;
  final Color? color;

  const BrandLogo({
    super.key,
    this.size = 68,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.accent;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: BrandLogoPainter(color: effectiveColor),
      ),
    );
  }
}

class BrandLogoPainter extends CustomPainter {
  final Color color;

  const BrandLogoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // Proportional dimensions based on the iconic brand geometry
    final strokeWidth = size.width * 0.165;

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Chevron path from bottom-left to top apex to bottom-right
    final chevronPath = Path()
      ..moveTo(size.width * 0.22, size.height * 0.74)
      ..lineTo(size.width * 0.50, size.height * 0.235)
      ..lineTo(size.width * 0.78, size.height * 0.74);

    canvas.drawPath(chevronPath, strokePaint);

    // Center circular dot beneath the apex
    final dotCenter = Offset(size.width * 0.50, size.height * 0.77);
    final dotRadius = size.width * 0.096;
    canvas.drawCircle(dotCenter, dotRadius, fillPaint);
  }

  @override
  bool shouldRepaint(covariant BrandLogoPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Circular 8-dot loading spinner matching the mobile launch splash
class BrandDotsSpinner extends StatefulWidget {
  final double size;
  final Color? color;

  const BrandDotsSpinner({
    super.key,
    this.size = 28,
    this.color,
  });

  @override
  State<BrandDotsSpinner> createState() => _BrandDotsSpinnerState();
}

class _BrandDotsSpinnerState extends State<BrandDotsSpinner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = widget.color ?? AppColors.accent;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: _BrandDotsSpinnerPainter(
              color: effectiveColor,
              progress: _controller.value,
            ),
          ),
        );
      },
    );
  }
}

class _BrandDotsSpinnerPainter extends CustomPainter {
  final Color color;
  final double progress;

  _BrandDotsSpinnerPainter({
    required this.color,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const int dotCount = 8;
    final center = Offset(size.width / 2, size.height / 2);
    final orbitRadius = size.width * 0.38;
    final dotRadius = size.width * 0.082;

    for (int i = 0; i < dotCount; i++) {
      // Starting from top (angle = -pi/2) going clockwise
      final angle = -math.pi / 2 + (i * 2 * math.pi / dotCount);
      final dotOffset = Offset(
        center.dx + orbitRadius * math.cos(angle),
        center.dy + orbitRadius * math.sin(angle),
      );

      // Opacity calculation based on animation progress
      // The leading dot is full opacity, trailing dots smoothly fade
      final normalizedDiff = ((i / dotCount) - progress) % 1.0;
      final positiveDiff = normalizedDiff < 0 ? normalizedDiff + 1.0 : normalizedDiff;
      final opacity = (0.2 + 0.8 * (1.0 - positiveDiff)).clamp(0.15, 1.0);

      final paint = Paint()
        ..color = color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(dotOffset, dotRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BrandDotsSpinnerPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
