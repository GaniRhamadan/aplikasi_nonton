import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NoScheduleView extends StatelessWidget {
  final DateTime? date;

  const NoScheduleView({
    super.key,
    this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Center Illustration (Large sad green face + anime girl + mint landscape)
            SizedBox(
              width: 240,
              height: 185,
              child: Image.asset(
                'assets/images/no_schedule.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback Vector Illustration matching screenshot
                  return const _FallbackNoScheduleIllustration();
                },
              ),
            ),
            const SizedBox(height: 24),

            // Title
            const Text(
              'No Release Schedule',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.accent,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 8),

            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Sorry, there is no anime release schedule on this date',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Vector fallback matching the sad green character + girl illustration
class _FallbackNoScheduleIllustration extends StatelessWidget {
  const _FallbackNoScheduleIllustration();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(240, 185),
      painter: _NoScheduleIllustrationPainter(),
    );
  }
}

class _NoScheduleIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Soft mint background hill/cloud
    final bgPaint = Paint()
      ..color = const Color(0xFFE8F6ED)
      ..style = PaintingStyle.fill;

    final bgPath = Path()
      ..moveTo(w * 0.15, h * 0.45)
      ..quadraticBezierTo(w * 0.35, h * 0.30, w * 0.70, h * 0.32)
      ..quadraticBezierTo(w * 0.90, h * 0.35, w * 0.88, h * 0.58)
      ..quadraticBezierTo(w * 0.65, h * 0.65, w * 0.15, h * 0.58)
      ..close();
    canvas.drawPath(bgPath, bgPaint);

    // 2. Floating mint leaves
    final leafPaint = Paint()
      ..color = const Color(0xFF22C55E)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.73, h * 0.18),
        width: 14,
        height: 8,
      ),
      leafPaint,
    );

    // 3. Ground line & grass
    final groundPaint = Paint()
      ..color = const Color(0xFFD1EAD8)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(w * 0.1, h * 0.82),
      Offset(w * 0.9, h * 0.82),
      groundPaint,
    );

    // 4. Girl standing beside green character (Navy/Purple dress)
    final dressPaint = Paint()
      ..color = const Color(0xFF3B4262)
      ..style = PaintingStyle.fill;
    final girlPath = Path()
      ..moveTo(w * 0.73, h * 0.45)
      ..lineTo(w * 0.78, h * 0.45)
      ..lineTo(w * 0.81, h * 0.68)
      ..lineTo(w * 0.70, h * 0.68)
      ..close();
    canvas.drawPath(girlPath, dressPaint);

    // Girl boots
    final bootsPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(w * 0.72, h * 0.68, 4, 18), bootsPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.77, h * 0.68, 4, 18), bootsPaint);

    // 5. Large Emerald Green Sad Face Circle
    final facePaint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.fill;
    final faceCenter = Offset(w * 0.46, h * 0.52);
    final faceRadius = w * 0.28;
    canvas.drawCircle(faceCenter, faceRadius, facePaint);

    // 6. Closed eyes (downward curves)
    final eyePaint = Paint()
      ..color = const Color(0xFF232B3A)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.5;

    // Left eye arc
    final leftEyePath = Path()
      ..moveTo(faceCenter.dx - 32, faceCenter.dy - 12)
      ..quadraticBezierTo(
        faceCenter.dx - 20,
        faceCenter.dy - 20,
        faceCenter.dx - 8,
        faceCenter.dy - 12,
      );
    canvas.drawPath(leftEyePath, eyePaint);

    // Right eye arc
    final rightEyePath = Path()
      ..moveTo(faceCenter.dx + 8, faceCenter.dy - 12)
      ..quadraticBezierTo(
        faceCenter.dx + 20,
        faceCenter.dy - 20,
        faceCenter.dx + 32,
        faceCenter.dy - 12,
      );
    canvas.drawPath(rightEyePath, eyePaint);

    // 7. Sad mouth (open frown with upper teeth)
    final mouthPaint = Paint()
      ..color = const Color(0xFF232B3A)
      ..style = PaintingStyle.fill;

    final mouthPath = Path()
      ..moveTo(faceCenter.dx - 26, faceCenter.dy + 15)
      ..quadraticBezierTo(
        faceCenter.dx,
        faceCenter.dy + 4,
        faceCenter.dx + 26,
        faceCenter.dy + 15,
      )
      ..quadraticBezierTo(
        faceCenter.dx + 18,
        faceCenter.dy + 34,
        faceCenter.dx,
        faceCenter.dy + 35,
      )
      ..quadraticBezierTo(
        faceCenter.dx - 18,
        faceCenter.dy + 34,
        faceCenter.dx - 26,
        faceCenter.dy + 15,
      )
      ..close();
    canvas.drawPath(mouthPath, mouthPaint);

    // Teeth highlight inside mouth
    final teethPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final teethPath = Path()
      ..moveTo(faceCenter.dx - 18, faceCenter.dy + 14)
      ..quadraticBezierTo(
        faceCenter.dx,
        faceCenter.dy + 6,
        faceCenter.dx + 18,
        faceCenter.dy + 14,
      )
      ..lineTo(faceCenter.dx + 15, faceCenter.dy + 19)
      ..quadraticBezierTo(
        faceCenter.dx,
        faceCenter.dy + 12,
        faceCenter.dx - 15,
        faceCenter.dy + 19,
      )
      ..close();
    canvas.drawPath(teethPath, teethPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
