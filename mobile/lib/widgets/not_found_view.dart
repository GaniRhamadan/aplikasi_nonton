import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NotFoundView extends StatelessWidget {
  final String? keyword;

  const NotFoundView({
    super.key,
    this.keyword,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. The 404 Landscape Illustration matching reference screenshot
            SizedBox(
              width: 260,
              height: 195,
              child: Image.asset(
                'assets/images/not_found_404.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const CustomPaint(
                  size: Size(260, 195),
                  painter: _NotFoundFallbackPainter(),
                ),
              ),
            ),

            const SizedBox(height: 18),

            // 2. Heading "Not Found" in vibrant emerald green
            const Text(
              'Not Found',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.accent,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),

            const SizedBox(height: 12),

            // 3. Subtitle / Description matching reference screenshot
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Sorry, the keyword you entered could not be found. Try to check again or search with other keywords.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.textSecondary
                      : const Color(0xFF4B5563),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  height: 1.45,
                  letterSpacing: -0.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotFoundFallbackPainter extends CustomPainter {
  const _NotFoundFallbackPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Mountain line paint
    final mountainPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;

    // Mountain 1 (Left peak)
    final p1 = Path()
      ..moveTo(0, h * 0.46)
      ..lineTo(w * 0.28, h * 0.28)
      ..lineTo(w * 0.48, h * 0.46);
    canvas.drawPath(p1, mountainPaint);

    // Mountain 2 (Center high peak)
    final p2 = Path()
      ..moveTo(w * 0.22, h * 0.45)
      ..lineTo(w * 0.50, h * 0.22)
      ..lineTo(w * 0.86, h * 0.48);
    canvas.drawPath(p2, mountainPaint);

    // Mountain 3 (Right peak)
    final p3 = Path()
      ..moveTo(w * 0.60, h * 0.42)
      ..lineTo(w * 0.82, h * 0.28)
      ..lineTo(w, h * 0.42);
    canvas.drawPath(p3, mountainPaint);

    // Sun & Clouds
    final sunPaint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.74, h * 0.16), 16, sunPaint);

    final cloudPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.64, h * 0.19, 36, 12),
        const Radius.circular(6),
      ),
      cloudPaint,
    );

    // Ground baseline
    final groundY = h * 0.68;
    canvas.drawLine(
      Offset(w * 0.08, groundY),
      Offset(w * 0.92, groundY),
      mountainPaint,
    );

    // 404 Text Elements
    final textStyle = const TextStyle(
      color: Color(0xFF23272F),
      fontSize: 52,
      fontWeight: FontWeight.w700,
      fontFamily: 'serif',
    );

    final textPainter4 = TextPainter(
      text: TextSpan(text: '4', style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter4.paint(canvas, Offset(w * 0.20, groundY - 60));
    textPainter4.paint(canvas, Offset(w * 0.68, groundY - 60));

    // Center Terrarium Ring (the "0")
    final ringPaint = Paint()
      ..color = const Color(0xFF23272F)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(w * 0.50, groundY - 30), 22, ringPaint);

    // Sprouting plant in 0
    final plantPaint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(w * 0.50, groundY - 30), width: 14, height: 22),
      plantPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
