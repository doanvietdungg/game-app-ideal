import 'dart:math';
import 'package:flutter/material.dart';

class PetPhysicsCanvas extends StatelessWidget {
  final Offset? touchOffset;
  final String expression; // 'happy', 'eating', 'tickled', 'sleeping'
  final String species; // 'cat', 'dog', 'dragon', 'rabbit'
  final String skin; // 'Mèo Thường 🐱', 'Mèo Robot 🤖', 'Mèo Ninja 🥷', 'Mèo Quý Tộc 👑'
  final double scaleX;
  final double scaleY;
  final bool isMouthOpen;

  const PetPhysicsCanvas({
    super.key,
    this.touchOffset,
    this.expression = 'happy',
    this.species = 'cat',
    this.skin = 'Mèo Thường 🐱',
    this.scaleX = 1.0,
    this.scaleY = 1.0,
    this.isMouthOpen = false,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scaleX: scaleX,
      scaleY: scaleY,
      child: CustomPaint(
        size: const Size(220, 220),
        painter: _PetPainter(
          touchOffset: touchOffset,
          expression: expression,
          species: species,
          skin: skin,
          isMouthOpen: isMouthOpen,
        ),
      ),
    );
  }
}

class _PetPainter extends CustomPainter {
  final Offset? touchOffset;
  final String expression;
  final String species;
  final String skin;
  final bool isMouthOpen;

  _PetPainter({
    this.touchOffset,
    required this.expression,
    required this.species,
    required this.skin,
    required this.isMouthOpen,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Shadow
    final shadowPaint = Paint()..color = Colors.black.withValues(alpha: 0.1);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(center.dx, center.dy + 75), width: 140, height: 24),
      shadowPaint,
    );

    // ----------------------------------------------------
    // SPECIAL ROBOT CAT CUSTOM HEAD DRAWING 🤖
    // ----------------------------------------------------
    if (skin.contains('Robot') || skin.contains('🤖')) {
      // 1. Cyber Cat Ears on Top
      final leftEar = Path()
        ..moveTo(center.dx - 50, center.dy - 55)
        ..lineTo(center.dx - 70, center.dy - 100)
        ..lineTo(center.dx - 20, center.dy - 60)
        ..close();
      canvas.drawPath(leftEar, Paint()..color = const Color(0xFF00ACC1));
      canvas.drawPath(leftEar, Paint()..color = const Color(0xFF006064)..style = PaintingStyle.stroke..strokeWidth = 3);

      final rightEar = Path()
        ..moveTo(center.dx + 50, center.dy - 55)
        ..lineTo(center.dx + 70, center.dy - 100)
        ..lineTo(center.dx + 20, center.dy - 60)
        ..close();
      canvas.drawPath(rightEar, Paint()..color = const Color(0xFF00ACC1));
      canvas.drawPath(rightEar, Paint()..color = const Color(0xFF006064)..style = PaintingStyle.stroke..strokeWidth = 3);

      // 2. Top Antenna Rod & Glowing Red LED (exact 🤖 match)
      canvas.drawRect(Rect.fromLTWH(center.dx - 4, center.dy - 102, 8, 40), Paint()..color = Colors.blueGrey.shade900);
      canvas.drawCircle(Offset(center.dx, center.dy - 105), 9, Paint()..color = Colors.redAccent);
      canvas.drawCircle(Offset(center.dx - 2, center.dy - 107), 3, Paint()..color = Colors.white);

      // 3. Side Red Ear/Speaker Knobs (exact 🤖 match)
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(center.dx - 84, center.dy - 20, 16, 40), const Radius.circular(6)), Paint()..color = Colors.red.shade700);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(center.dx + 68, center.dy - 20, 16, 40), const Radius.circular(6)), Paint()..color = Colors.red.shade700);

      // 4. Main Square Metallic Box Robot Head
      final boxRect = Rect.fromCenter(center: center, width: 140, height: 130);
      final boxRRect = RRect.fromRectAndRadius(boxRect, const Radius.circular(24));
      canvas.drawRRect(boxRRect, Paint()..color = const Color(0xFF78909C));
      canvas.drawRRect(boxRRect, Paint()..color = const Color(0xFF37474F)..style = PaintingStyle.stroke..strokeWidth = 4);

      // 5. Metallic Cheek Accents
      canvas.drawCircle(Offset(center.dx - 48, center.dy + 25), 10, Paint()..color = Colors.cyan.shade300.withValues(alpha: 0.5));
      canvas.drawCircle(Offset(center.dx + 48, center.dy + 25), 10, Paint()..color = Colors.cyan.shade300.withValues(alpha: 0.5));

      // Eye Gaze Offset Calculation
      double eyeDx = 0;
      double eyeDy = 0;
      if (touchOffset != null) {
        final deltaX = touchOffset!.dx - center.dx;
        final deltaY = touchOffset!.dy - center.dy;
        final distance = sqrt(deltaX * deltaX + deltaY * deltaY);
        if (distance > 0) {
          eyeDx = (deltaX / distance) * 6.0;
          eyeDy = (deltaY / distance) * 6.0;
        }
      }

      // 6. Robot Eyes (Large Round White Eye Sockets with Pupils)
      final leftEyeCenter = Offset(center.dx - 28, center.dy - 12);
      final rightEyeCenter = Offset(center.dx + 28, center.dy - 12);

      canvas.drawCircle(leftEyeCenter, 18, Paint()..color = Colors.white);
      canvas.drawCircle(rightEyeCenter, 18, Paint()..color = Colors.white);
      canvas.drawCircle(leftEyeCenter, 18, Paint()..color = Colors.black87..style = PaintingStyle.stroke..strokeWidth = 3);
      canvas.drawCircle(rightEyeCenter, 18, Paint()..color = Colors.black87..style = PaintingStyle.stroke..strokeWidth = 3);

      canvas.drawCircle(Offset(leftEyeCenter.dx + eyeDx, leftEyeCenter.dy + eyeDy), 9, Paint()..color = Colors.black87);
      canvas.drawCircle(Offset(rightEyeCenter.dx + eyeDx, rightEyeCenter.dy + eyeDy), 9, Paint()..color = Colors.black87);
      canvas.drawCircle(Offset(leftEyeCenter.dx + eyeDx - 3, leftEyeCenter.dy + eyeDy - 3), 3, Paint()..color = Colors.white);
      canvas.drawCircle(Offset(rightEyeCenter.dx + eyeDx - 3, rightEyeCenter.dy + eyeDy - 3), 3, Paint()..color = Colors.white);

      // 7. Red Triangle Nose
      final nosePath = Path()
        ..moveTo(center.dx - 6, center.dy + 8)
        ..lineTo(center.dx + 6, center.dy + 8)
        ..lineTo(center.dx, center.dy + 16)
        ..close();
      canvas.drawPath(nosePath, Paint()..color = Colors.red.shade600);

      // 8. Metallic Mouth Grill / Teeth (exact 🤖 match)
      if (isMouthOpen || expression == 'eating') {
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(center.dx - 24, center.dy + 24, 48, 22), const Radius.circular(8)), Paint()..color = Colors.red.shade400);
      } else {
        final mouthGrillRect = Rect.fromLTWH(center.dx - 26, center.dy + 24, 52, 18);
        canvas.drawRRect(RRect.fromRectAndRadius(mouthGrillRect, const Radius.circular(6)), Paint()..color = Colors.grey.shade200);
        canvas.drawRRect(RRect.fromRectAndRadius(mouthGrillRect, const Radius.circular(6)), Paint()..color = Colors.black87..style = PaintingStyle.stroke..strokeWidth = 2);
        // Vertical grill lines for robot teeth
        for (int i = -18; i <= 18; i += 9) {
          canvas.drawLine(Offset(center.dx + i, center.dy + 24), Offset(center.dx + i, center.dy + 42), Paint()..color = Colors.black87..strokeWidth = 2);
        }
      }
      return;
    }

    // Color palette based on species & equipped skin
    Color bodyColor = Colors.orange.shade300;
    Color earColor = Colors.orange.shade400;

    if (skin.contains('Robot') || skin.contains('🤖')) {
      bodyColor = const Color(0xFF78909C); // Metallic Cyan-Grey
      earColor = const Color(0xFF00ACC1); // Glowing Cyan Ears
    } else if (skin.contains('Ninja') || skin.contains('🥷')) {
      bodyColor = const Color(0xFF263238); // Dark Ninja Armor
      earColor = const Color(0xFF37474F);
    } else if (skin.contains('Quý Tộc') || skin.contains('👑')) {
      bodyColor = const Color(0xFFFFD54F); // Imperial Gold Fur
      earColor = const Color(0xFFFFB300);
    } else if (species == 'dog') {
      bodyColor = Colors.amber.shade600;
      earColor = Colors.brown.shade400;
    } else if (species == 'dragon') {
      bodyColor = Colors.purple.shade300;
      earColor = Colors.purple.shade500;
    } else if (species == 'rabbit') {
      bodyColor = Colors.pink.shade100;
      earColor = Colors.pink.shade300;
    }

    // Ears / Horns rendering
    final earPaint = Paint()..color = earColor;
    final innerEarPaint = Paint()..color = Colors.pink.shade200;

    if (species == 'rabbit') {
      // Long rabbit ears
      canvas.drawRRect(RRect.fromLTRBAndCorners(center.dx - 50, center.dy - 120, center.dx - 20, center.dy - 30, topLeft: const Radius.circular(20), topRight: const Radius.circular(20)), earPaint);
      canvas.drawRRect(RRect.fromLTRBAndCorners(center.dx + 20, center.dy - 120, center.dx + 50, center.dy - 30, topLeft: const Radius.circular(20), topRight: const Radius.circular(20)), earPaint);
      canvas.drawRRect(RRect.fromLTRBAndCorners(center.dx - 42, center.dy - 110, center.dx - 28, center.dy - 40, topLeft: const Radius.circular(15), topRight: const Radius.circular(15)), innerEarPaint);
      canvas.drawRRect(RRect.fromLTRBAndCorners(center.dx + 28, center.dy - 110, center.dx + 42, center.dy - 40, topLeft: const Radius.circular(15), topRight: const Radius.circular(15)), innerEarPaint);
    } else if (species == 'dog') {
      // Flappy dog ears
      canvas.drawOval(Rect.fromLTWH(center.dx - 95, center.dy - 40, 45, 80), earPaint);
      canvas.drawOval(Rect.fromLTWH(center.dx + 50, center.dy - 40, 45, 80), earPaint);
    } else {
      // Cat ears / Dragon horns
      final leftEar = Path()
        ..moveTo(center.dx - 60, center.dy - 30)
        ..lineTo(center.dx - 80, center.dy - 90)
        ..lineTo(center.dx - 20, center.dy - 60)
        ..close();
      canvas.drawPath(leftEar, earPaint);

      final rightEar = Path()
        ..moveTo(center.dx + 60, center.dy - 30)
        ..lineTo(center.dx + 80, center.dy - 90)
        ..lineTo(center.dx + 20, center.dy - 60)
        ..close();
      canvas.drawPath(rightEar, earPaint);

      final leftInnerEar = Path()
        ..moveTo(center.dx - 55, center.dy - 35)
        ..lineTo(center.dx - 72, center.dy - 80)
        ..lineTo(center.dx - 28, center.dy - 58)
        ..close();
      canvas.drawPath(leftInnerEar, innerEarPaint);

      final rightInnerEar = Path()
        ..moveTo(center.dx + 55, center.dy - 35)
        ..lineTo(center.dx + 72, center.dy - 80)
        ..lineTo(center.dx + 28, center.dy - 58)
        ..close();
      canvas.drawPath(rightInnerEar, innerEarPaint);
    }

    // Body (Round chubby circle)
    final bodyPaint = Paint()..color = bodyColor;
    canvas.drawCircle(center, 70, bodyPaint);

    // Render Unique Skin Accessories (Robot / Ninja / Noble)
    if (skin.contains('Robot') || skin.contains('🤖')) {
      // 1. Robot Top Antenna Rod & Glowing LED
      canvas.drawRect(Rect.fromLTWH(center.dx - 4, center.dy - 102, 8, 35), Paint()..color = Colors.blueGrey.shade800);
      canvas.drawCircle(Offset(center.dx, center.dy - 105), 8, Paint()..color = Colors.redAccent);
      canvas.drawCircle(Offset(center.dx - 2, center.dy - 107), 3, Paint()..color = Colors.white);

      // 2. Metallic Side Screws / Bolts
      canvas.drawCircle(Offset(center.dx - 68, center.dy), 7, Paint()..color = Colors.grey.shade400);
      canvas.drawLine(Offset(center.dx - 72, center.dy), Offset(center.dx - 64, center.dy), Paint()..color = Colors.black54..strokeWidth = 2);
      canvas.drawCircle(Offset(center.dx + 68, center.dy), 7, Paint()..color = Colors.grey.shade400);
      canvas.drawLine(Offset(center.dx + 64, center.dy), Offset(center.dx + 72, center.dy), Paint()..color = Colors.black54..strokeWidth = 2);

      // 3. Cyber Visor Frame around eyes
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(center.dx - 48, center.dy - 25, 96, 32), const Radius.circular(10)), Paint()..color = Colors.cyan.shade300.withValues(alpha: 0.35));
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(center.dx - 48, center.dy - 25, 96, 32), const Radius.circular(10)), Paint()..color = Colors.cyan.shade600..style = PaintingStyle.stroke..strokeWidth = 3);
    } else if (skin.contains('Ninja') || skin.contains('🥷')) {
      // Red Ninja Headband & Silver Badge
      canvas.drawRect(Rect.fromLTWH(center.dx - 68, center.dy - 48, 136, 18), Paint()..color = Colors.red.shade700);
      canvas.drawCircle(Offset(center.dx, center.dy - 39), 10, Paint()..color = Colors.grey.shade300);
      canvas.drawCircle(Offset(center.dx, center.dy - 39), 4, Paint()..color = Colors.black);
    } else if (skin.contains('Quý Tộc') || skin.contains('👑')) {
      // Golden Royal Crown
      final crownPath = Path()
        ..moveTo(center.dx - 35, center.dy - 65)
        ..lineTo(center.dx - 40, center.dy - 100)
        ..lineTo(center.dx - 18, center.dy - 82)
        ..lineTo(center.dx, center.dy - 108)
        ..lineTo(center.dx + 18, center.dy - 82)
        ..lineTo(center.dx + 40, center.dy - 100)
        ..lineTo(center.dx + 35, center.dy - 65)
        ..close();
      canvas.drawPath(crownPath, Paint()..color = Colors.amber.shade500);
      canvas.drawCircle(Offset(center.dx - 40, center.dy - 100), 5, Paint()..color = Colors.redAccent);
      canvas.drawCircle(Offset(center.dx, center.dy - 108), 6, Paint()..color = Colors.blueAccent);
      canvas.drawCircle(Offset(center.dx + 40, center.dy - 100), 5, Paint()..color = Colors.redAccent);
    }

    // Cheeks
    final cheekPaint = Paint()..color = Colors.pink.shade300.withValues(alpha: 0.5);
    canvas.drawCircle(Offset(center.dx - 45, center.dy + 15), 14, cheekPaint);
    canvas.drawCircle(Offset(center.dx + 45, center.dy + 15), 14, cheekPaint);

    // Eye Gaze Offset Calculation
    double eyeDx = 0;
    double eyeDy = 0;

    if (touchOffset != null) {
      final deltaX = touchOffset!.dx - center.dx;
      final deltaY = touchOffset!.dy - center.dy;
      final distance = sqrt(deltaX * deltaX + deltaY * deltaY);
      if (distance > 0) {
        eyeDx = (deltaX / distance) * 6.0;
        eyeDy = (deltaY / distance) * 6.0;
      }
    }

    // Eyes rendering
    final eyeWhitePaint = Paint()..color = Colors.white;
    final eyePupilPaint = Paint()..color = Colors.black87;

    final leftEyeCenter = Offset(center.dx - 28, center.dy - 10);
    final rightEyeCenter = Offset(center.dx + 28, center.dy - 10);

    if (expression == 'tickled') {
      final happyEyePaint = Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(Rect.fromCircle(center: leftEyeCenter, radius: 12), pi, pi, false, happyEyePaint);
      canvas.drawArc(Rect.fromCircle(center: rightEyeCenter, radius: 12), pi, pi, false, happyEyePaint);
    } else if (expression == 'sleeping') {
      final sleepPaint = Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(leftEyeCenter.dx - 10, leftEyeCenter.dy), Offset(leftEyeCenter.dx + 10, leftEyeCenter.dy), sleepPaint);
      canvas.drawLine(Offset(rightEyeCenter.dx - 10, rightEyeCenter.dy), Offset(rightEyeCenter.dx + 10, rightEyeCenter.dy), sleepPaint);
    } else {
      canvas.drawCircle(leftEyeCenter, 16, eyeWhitePaint);
      canvas.drawCircle(rightEyeCenter, 16, eyeWhitePaint);

      canvas.drawCircle(Offset(leftEyeCenter.dx + eyeDx, leftEyeCenter.dy + eyeDy), 8, eyePupilPaint);
      canvas.drawCircle(Offset(rightEyeCenter.dx + eyeDx, rightEyeCenter.dy + eyeDy), 8, eyePupilPaint);

      final catchLightPaint = Paint()..color = Colors.white;
      canvas.drawCircle(Offset(leftEyeCenter.dx + eyeDx - 3, leftEyeCenter.dy + eyeDy - 3), 3, catchLightPaint);
      canvas.drawCircle(Offset(rightEyeCenter.dx + eyeDx - 3, rightEyeCenter.dy + eyeDy - 3), 3, catchLightPaint);
    }

    // Nose
    final nosePaint = Paint()..color = species == 'dog' ? Colors.black87 : Colors.pink.shade400;
    final nosePath = Path()
      ..moveTo(center.dx - 6, center.dy + 8)
      ..lineTo(center.dx + 6, center.dy + 8)
      ..lineTo(center.dx, center.dy + 14)
      ..close();
    canvas.drawPath(nosePath, nosePaint);

    // Mouth rendering
    final mouthPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    if (isMouthOpen || expression == 'eating') {
      final openMouthPaint = Paint()..color = Colors.red.shade400;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(center.dx, center.dy + 25), width: 28, height: 24),
        openMouthPaint,
      );
    } else {
      canvas.drawArc(Rect.fromCircle(center: Offset(center.dx - 8, center.dy + 16), radius: 8), 0, pi * 0.8, false, mouthPaint);
      canvas.drawArc(Rect.fromCircle(center: Offset(center.dx + 8, center.dy + 16), radius: 8), 0.2 * pi, pi * 0.8, false, mouthPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PetPainter oldDelegate) {
    return oldDelegate.touchOffset != touchOffset ||
        oldDelegate.expression != expression ||
        oldDelegate.species != species ||
        oldDelegate.skin != skin ||
        oldDelegate.isMouthOpen != isMouthOpen;
  }
}
