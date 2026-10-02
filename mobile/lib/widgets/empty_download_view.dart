import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Empty state view for "Download" screen matching Figma reference screenshot.
class EmptyDownloadView extends StatelessWidget {
  final String? title;
  final String? description;

  const EmptyDownloadView({
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
            // 1. Vector Illustration: Person sitting under green tree with floating play button
            const SizedBox(
              width: 250,
              height: 190,
              child: CustomPaint(
                painter: _DownloadEmptyIllustrationPainter(),
              ),
            ),
            const SizedBox(height: 36),

            // 2. Title "Your Download is Empty" in vibrant emerald green
            Text(
              title ?? 'Your Download is Empty',
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
                  "Looks like you haven't downloaded\nanime at all",
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

/// Custom vector painter matching the Figma illustration:
/// - Green circular tree on the left with trunk
/// - Anime character sitting against the tree holding a tablet
/// - Dark circular play button floating on the right
/// - Clean horizontal ground line
class _DownloadEmptyIllustrationPainter extends CustomPainter {
  const _DownloadEmptyIllustrationPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // Reference coordinate dimensions
    const groundY = 152.0;

    // Paints
    final groundPaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    final treeCanopyPaint = Paint()
      ..color = AppColors.accent // Vibrant emerald green #16D458
      ..style = PaintingStyle.fill;

    final trunkPaint = Paint()
      ..color = const Color(0xFF2C3440)
      ..style = PaintingStyle.fill;

    final playCirclePaint = Paint()
      ..color = const Color(0xFF33384B)
      ..style = PaintingStyle.fill;

    final playTrianglePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final darkClothingPaint = Paint()
      ..color = const Color(0xFF2C3440)
      ..style = PaintingStyle.fill;

    final sweaterPaint = Paint()
      ..color = const Color(0xFFDDE3EA)
      ..style = PaintingStyle.fill;

    final hairPaint = Paint()
      ..color = const Color(0xFF202530)
      ..style = PaintingStyle.fill;

    final skinPaint = Paint()
      ..color = const Color(0xFFFDE8D7)
      ..style = PaintingStyle.fill;

    final tabletPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final tabletStrokePaint = Paint()
      ..color = const Color(0xFF2C3440)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final greenDotPaint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.fill;

    // 1. Ground line
    canvas.drawLine(
      const Offset(18, groundY),
      const Offset(232, groundY),
      groundPaint,
    );

    // Subtle faint bush left of tree
    final bushPaint = Paint()..color = const Color(0xFFEFF3F8);
    final bushPath = Path()
      ..moveTo(30, groundY)
      ..quadraticBezierTo(38, groundY - 14, 46, groundY)
      ..close();
    canvas.drawPath(bushPath, bushPaint);

    // 2. Tree
    // Trunk
    final trunkRect = Rect.fromLTWH(73, 56, 3.8, groundY - 56);
    canvas.drawRect(trunkRect, trunkPaint);

    // Small notch/branch
    final branchPath = Path()
      ..moveTo(76.8, 102)
      ..lineTo(82.5, 99)
      ..lineTo(76.8, 105)
      ..close();
    canvas.drawPath(branchPath, trunkPaint);

    // Tree canopy (perfect emerald green circle)
    canvas.drawCircle(const Offset(75, 60), 45, treeCanopyPaint);

    // 3. Floating Play Button on Right
    const playCenterX = 168.0;
    const playCenterY = 90.0;
    const playRadius = 29.0;
    canvas.drawCircle(
      const Offset(playCenterX, playCenterY),
      playRadius,
      playCirclePaint,
    );

    // White Play Triangle
    final playTriangle = Path()
      ..moveTo(playCenterX - 6.5, playCenterY - 12.5)
      ..lineTo(playCenterX + 12.5, playCenterY)
      ..lineTo(playCenterX - 6.5, playCenterY + 12.5)
      ..close();
    canvas.drawPath(playTriangle, playTrianglePaint);

    // 4. Sitting Character
    // Head & Hair
    canvas.drawCircle(const Offset(84, 114), 7.5, skinPaint);
    final hairPath = Path()
      ..addArc(
        Rect.fromCircle(center: const Offset(84, 113), radius: 8.5),
        -3.14,
        3.14,
      )
      ..lineTo(80, 118)
      ..lineTo(76, 122)
      ..lineTo(84, 122)
      ..close();
    canvas.drawPath(hairPath, hairPaint);

    // Face / nose profile looking toward the tablet
    final profilePath = Path()
      ..moveTo(88, 113)
      ..lineTo(91, 115)
      ..lineTo(88, 118)
      ..close();
    canvas.drawPath(profilePath, skinPaint);

    // Torso (Light grey sweater)
    final torsoPath = Path()
      ..moveTo(76.8, 122)
      ..lineTo(90, 124)
      ..lineTo(83, 143)
      ..lineTo(76.8, 141)
      ..close();
    canvas.drawPath(torsoPath, sweaterPaint);

    // Arm holding tablet
    final armPath = Path()
      ..moveTo(84, 126)
      ..lineTo(98, 134)
      ..lineTo(94, 138)
      ..lineTo(82, 131)
      ..close();
    canvas.drawPath(armPath, sweaterPaint);
    canvas.drawCircle(const Offset(98, 134), 3.0, skinPaint);

    // Tablet
    canvas.save();
    canvas.translate(101, 131);
    canvas.rotate(-0.35);
    final tabletRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-7, -9, 14, 18),
      const Radius.circular(2.5),
    );
    canvas.drawRRect(tabletRect, tabletPaint);
    canvas.drawRRect(tabletRect, tabletStrokePaint);
    canvas.drawCircle(const Offset(0, 0), 2.8, greenDotPaint);
    canvas.restore();

    // Legs & Pants (Dark navy / charcoal)
    // Thigh extending forward
    final legPath = Path()
      ..moveTo(79, 140)
      ..lineTo(94, 140)
      ..lineTo(112, 145)
      ..lineTo(129, 150)
      ..lineTo(132, 152)
      ..lineTo(124, 152)
      ..lineTo(108, 148)
      ..lineTo(84, 146)
      ..close();
    canvas.drawPath(legPath, darkClothingPaint);

    // Bent knee & second leg
    final secondLegPath = Path()
      ..moveTo(82, 141)
      ..lineTo(101, 141)
      ..lineTo(116, 147)
      ..lineTo(112, 152)
      ..lineTo(96, 145)
      ..close();
    canvas.drawPath(secondLegPath, darkClothingPaint);

    // Shoe at bottom right
    final shoePath = Path()
      ..moveTo(128, 148)
      ..lineTo(136, 150)
      ..lineTo(134, 152)
      ..lineTo(126, 152)
      ..close();
    canvas.drawPath(shoePath, darkClothingPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
