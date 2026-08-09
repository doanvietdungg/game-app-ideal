import 'package:flutter/material.dart';

class PetPhysicsCanvas extends StatelessWidget {
  final Offset? touchOffset;
  final String expression; // 'happy', 'eating', 'tickled', 'sleeping'
  final double scaleX;
  final double scaleY;
  final bool isMouthOpen;

  const PetPhysicsCanvas({
    super.key,
    this.touchOffset,
    this.expression = 'happy',
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
          isMouthOpen: isMouthOpen,
        ),
      ),
    );
  }
}

class _PetPainter extends CustomPainter {
  final Offset? touchOffset;
  final String expression;
  final bool isMouthOpen;

  _PetPainter({this.touchOffset, required this.expression, required this.isMouthOpen});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Shadow
    final shadowPaint = Paint()..color = Colors.black.withValues(alpha: 0.1);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(center.dx, center.dy + 75), width: 140, height: 24),
      shadowPaint,
    );

    // Ears
    final earPaint = Paint()..color = Colors.orange.shade400;
    final innerEarPaint = Paint()..color = Colors.pink.shade200;

    // Left Ear
    final leftEar = Path()
      ..moveTo(center.dx - 60, center.dy - 30)
      ..lineTo(center.dx - 85, center.dy - 90)
      ..lineTo(center.dx - 20, center.dy - 65)
      ..close();
    canvas.drawPath(leftEar, earPaint);

    final leftInnerEar = Path()
      ..moveTo(center.dx - 55, center.dy - 35)
      ..lineTo(center.dx - 75, center.dy - 80)
      ..lineTo(center.dx - 28, center.dy - 60)
      ..close();
    canvas.drawPath(leftInnerEar, innerEarPaint);

    // Right Ear
    final rightEar = Path()
      ..moveTo(center.dx + 60, center.dy - 30)
      ..lineTo(center.dx + 85, center.dy - 90)
      ..lineTo(center.dx + 20, center.dy - 65)
      ..close();
    canvas.drawPath(rightEar, earPaint);

    final rightInnerEar = Path()
      ..moveTo(center.dx + 55, center.dy - 35)
      ..lineTo(center.dx + 75, center.dy - 80)
      ..lineTo(center.dx + 28, center.dy - 60)
      ..close();
    canvas.drawPath(rightInnerEar, innerEarPaint);

    // Body
    final bodyGradient = RadialGradient(
      colors: [Colors.amber.shade300, Colors.orange.shade400],
      center: const Alignment(-0.2, -0.3),
    );
    final bodyPaint = Paint()..shader = bodyGradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawOval(Rect.fromCenter(center: center, width: 160, height: 140), bodyPaint);

    // Cheeks
    final cheekPaint = Paint()..color = Colors.pink.shade300.withValues(alpha: 0.5);
    canvas.drawCircle(Offset(center.dx - 50, center.dy + 15), 14, cheekPaint);
    canvas.drawCircle(Offset(center.dx + 50, center.dy + 15), 14, cheekPaint);

    // Eyes Tracking Offset
    double gazeX = 0;
    double gazeY = 0;
    if (touchOffset != null) {
      gazeX = (touchOffset!.dx - center.dx).clamp(-10.0, 10.0);
      gazeY = (touchOffset!.dy - center.dy).clamp(-6.0, 6.0);
    }

    final eyeWhitePaint = Paint()..color = Colors.white;
    final pupilPaint = Paint()..color = Colors.black87;

    if (expression == 'tickled' || expression == 'sleeping') {
      // Closed happy eyes ^ ^
      final eyeArcPaint = Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round;

      final leftPath = Path()..addArc(Rect.fromCircle(center: Offset(center.dx - 35, center.dy - 10), radius: 12), 3.14, 3.14);
      final rightPath = Path()..addArc(Rect.fromCircle(center: Offset(center.dx + 35, center.dy - 10), radius: 12), 3.14, 3.14);
      canvas.drawPath(leftPath, eyeArcPaint);
      canvas.drawPath(rightPath, eyeArcPaint);
    } else {
      // Left Eye
      canvas.drawCircle(Offset(center.dx - 35, center.dy - 10), 16, eyeWhitePaint);
      canvas.drawCircle(Offset(center.dx - 35 + gazeX, center.dy - 10 + gazeY), 8, pupilPaint);
      canvas.drawCircle(Offset(center.dx - 31 + gazeX, center.dy - 14 + gazeY), 3, eyeWhitePaint);

      // Right Eye
      canvas.drawCircle(Offset(center.dx + 35, center.dy - 10), 16, eyeWhitePaint);
      canvas.drawCircle(Offset(center.dx + 35 + gazeX, center.dy - 10 + gazeY), 8, pupilPaint);
      canvas.drawCircle(Offset(center.dx + 39 + gazeX, center.dy - 14 + gazeY), 3, eyeWhitePaint);
    }

    // Nose
    final nosePaint = Paint()..color = Colors.pink.shade400;
    final nosePath = Path()
      ..moveTo(center.dx - 6, center.dy + 8)
      ..lineTo(center.dx + 6, center.dy + 8)
      ..lineTo(center.dx, center.dy + 14)
      ..close();
    canvas.drawPath(nosePath, nosePaint);

    // Mouth
    final mouthPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    if (isMouthOpen || expression == 'eating') {
      final openMouthPaint = Paint()..color = Colors.pink.shade400;
      canvas.drawArc(
        Rect.fromCenter(center: Offset(center.dx, center.dy + 25), width: 30, height: 24),
        0,
        3.14,
        true,
        openMouthPaint,
      );
    } else {
      final leftMouth = Path()..addArc(Rect.fromCircle(center: Offset(center.dx - 8, center.dy + 18), radius: 8), 0.2, 2.5);
      final rightMouth = Path()..addArc(Rect.fromCircle(center: Offset(center.dx + 8, center.dy + 18), radius: 8), 0.5, 2.5);
      canvas.drawPath(leftMouth, mouthPaint);
      canvas.drawPath(rightMouth, mouthPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PetPainter oldDelegate) {
    return oldDelegate.touchOffset != touchOffset ||
        oldDelegate.expression != expression ||
        oldDelegate.isMouthOpen != isMouthOpen;
  }
}
