import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Empty state view for "My List" screen matching Figma reference screenshot.
class EmptyMyListView extends StatelessWidget {
  final String? title;
  final String? description;

  const EmptyMyListView({
    super.key,
    this.title,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Vector Illustration of two overlapping clipboards
            const SizedBox(
              width: 220,
              height: 210,
              child: CustomPaint(
                painter: _MyListEmptyIllustrationPainter(),
              ),
            ),
            const SizedBox(height: 36),

            // 2. Title "Your List is Empty" in vibrant emerald green
            Text(
              title ?? 'Your List is Empty',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.accent,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 12),

            // 3. Subtitle description
            Text(
              description ??
                  "It seems that you haven't added\nany anime to the list",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for the two overlapping clipboards matching the Figma vector style.
class _MyListEmptyIllustrationPainter extends CustomPainter {
  const _MyListEmptyIllustrationPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const boardOutlineColor = Color(0xFF78849E);
    const boardFillColor = Colors.white;
    const paperFillColor = Color(0xFFECEFF3);
    const clipColor = AppColors.accent; // #16D458

    final outlinePaint = Paint()
      ..color = boardOutlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = boardFillColor
      ..style = PaintingStyle.fill;

    final paperPaint = Paint()
      ..color = paperFillColor
      ..style = PaintingStyle.fill;

    final clipPaint = Paint()
      ..color = clipColor
      ..style = PaintingStyle.fill;

    final clipRingPaint = Paint()
      ..color = clipColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // ==========================================
    // 1. BACK CLIPBOARD (Tilted by -14 degrees)
    // ==========================================
    canvas.save();
    // Center of back clipboard
    canvas.translate(size.width * 0.40, size.height * 0.46);
    canvas.rotate(-14.0 * math.pi / 180.0);

    const backBoardWidth = 108.0;
    const backBoardHeight = 152.0;
    final backBoardRRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset.zero,
        width: backBoardWidth,
        height: backBoardHeight,
      ),
      const Radius.circular(10),
    );

    // Board background & stroke
    canvas.drawRRect(backBoardRRect, fillPaint);
    canvas.drawRRect(backBoardRRect, outlinePaint);

    // Inner paper sheet
    final backPaperRRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(
        -backBoardWidth / 2 + 8,
        -backBoardHeight / 2 + 18,
        backBoardWidth / 2 - 8,
        backBoardHeight / 2 - 8,
      ),
      const Radius.circular(4),
    );
    canvas.drawRRect(backPaperRRect, paperPaint);

    // Top Clip Ring/Hole
    canvas.drawCircle(
      const Offset(0, -backBoardHeight / 2 - 3),
      5.5,
      clipRingPaint,
    );

    // Top Clip Body
    final backClipRRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: const Offset(0, -backBoardHeight / 2 + 6),
        width: 50,
        height: 18,
      ),
      const Radius.circular(4),
    );
    canvas.drawRRect(backClipRRect, clipPaint);

    canvas.restore();

    // ==========================================
    // 2. FRONT CLIPBOARD (Upright, slightly offset)
    // ==========================================
    canvas.save();
    // Center of front clipboard
    canvas.translate(size.width * 0.58, size.height * 0.54);

    const frontBoardWidth = 114.0;
    const frontBoardHeight = 158.0;
    final frontBoardRRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset.zero,
        width: frontBoardWidth,
        height: frontBoardHeight,
      ),
      const Radius.circular(10),
    );

    // Board background & stroke
    canvas.drawRRect(frontBoardRRect, fillPaint);
    canvas.drawRRect(frontBoardRRect, outlinePaint);

    // Inner paper sheet
    final frontPaperRRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(
        -frontBoardWidth / 2 + 8,
        -frontBoardHeight / 2 + 20,
        frontBoardWidth / 2 - 8,
        frontBoardHeight / 2 - 8,
      ),
      const Radius.circular(4),
    );
    canvas.drawRRect(frontPaperRRect, paperPaint);

    // Top Clip Ring/Hole
    canvas.drawCircle(
      const Offset(0, -frontBoardHeight / 2 - 3),
      5.5,
      clipRingPaint,
    );

    // Top Clip Body
    final frontClipRRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: const Offset(0, -frontBoardHeight / 2 + 6),
        width: 54,
        height: 19,
      ),
      const Radius.circular(4),
    );
    canvas.drawRRect(frontClipRRect, clipPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
