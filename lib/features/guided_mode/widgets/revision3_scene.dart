import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:wicara_application_1/models/revision3_content.dart';

class Revision3Scene extends StatelessWidget {
  final LearningMission mission;
  final int frame;
  final String studentExpression;
  final bool showStudent;
  final bool showOther;

  const Revision3Scene({
    super.key,
    required this.mission,
    this.frame = 0,
    this.studentExpression = 'neutral',
    this.showStudent = true,
    this.showOther = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final characterHeight = math.min(constraints.maxHeight * 0.72, 230.0);
        final characterWidth = characterHeight * 100 / 180;
        return Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.hardEdge,
          children: [
            CustomPaint(painter: _SceneBackgroundPainter(mission.scene, frame)),
            if (showOther)
              Positioned(
                left: 18,
                bottom: 0,
                width: characterWidth,
                height: characterHeight,
                child: CustomPaint(
                  painter: _OtherCharacterPainter(mission.otherPersona),
                ),
              ),
            if (showStudent)
              Positioned(
                right: showOther ? 24 : 30,
                bottom: 0,
                width: characterWidth,
                height: characterHeight,
                child: CustomPaint(
                  painter: _StudentCharacterPainter(
                    expression: studentExpression,
                    workTheme: !mission.isSchool,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SceneBackgroundPainter extends CustomPainter {
  final String scene;
  final int frame;

  const _SceneBackgroundPainter(this.scene, this.frame);

  Color c(int value, [double opacity = 1]) =>
      Color(value).withValues(alpha: opacity);

  RRect rr(double x, double y, double w, double h, double radius) =>
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, w, h),
        Radius.circular(radius),
      );

  void rect(
    Canvas canvas,
    double x,
    double y,
    double w,
    double h,
    int color, {
    double radius = 0,
    double opacity = 1,
    PaintingStyle style = PaintingStyle.fill,
    double strokeWidth = 1,
  }) {
    canvas.drawRRect(
      rr(x, y, w, h, radius),
      Paint()
        ..color = c(color, opacity)
        ..style = style
        ..strokeWidth = strokeWidth,
    );
  }

  void line(
    Canvas canvas,
    Offset from,
    Offset to,
    int color, {
    double width = 2,
    double opacity = 1,
  }) {
    canvas.drawLine(
      from,
      to,
      Paint()
        ..color = c(color, opacity)
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 393;
    final scaleY = size.height / 320;
    canvas.save();
    canvas.scale(scaleX, scaleY);
    switch (scene) {
      case 'classroom':
        _classroom(canvas);
        break;
      case 'lab':
        _lab(canvas);
        break;
      case 'office':
        _office(canvas);
        break;
      case 'mentor':
        _mentor(canvas);
        break;
      default:
        _bedroom(canvas);
        break;
    }
    canvas.restore();
  }

  void _bedroom(Canvas canvas) {
    canvas.drawColor(c(0xFFFFF6DC), BlendMode.src);
    rect(canvas, 0, 280, 393, 40, 0xFFE8C87A, opacity: 0.4);

    rect(canvas, 260, 14, 108, 90, 0xFFDAEEFF, radius: 8, opacity: 0.7);
    rect(
      canvas,
      260,
      14,
      108,
      90,
      0xFFF0C030,
      radius: 8,
      style: PaintingStyle.stroke,
      strokeWidth: 4,
    );
    line(
      canvas,
      const Offset(314, 14),
      const Offset(314, 104),
      0xFFF0C030,
      width: 3,
    );
    line(
      canvas,
      const Offset(260, 59),
      const Offset(368, 59),
      0xFFF0C030,
      width: 3,
    );
    line(
      canvas,
      const Offset(300, 104),
      const Offset(360, 260),
      0xFFFFE070,
      width: 22,
      opacity: 0.22,
    );
    canvas.drawCircle(
      const Offset(310, 36),
      14,
      Paint()..color = c(0xFF46C98B, 0.28),
    );
    canvas.drawCircle(
      const Offset(326, 28),
      10,
      Paint()..color = c(0xFF46C98B, 0.22),
    );

    rect(canvas, 155, 16, 58, 55, 0xFFFFFFFF, radius: 5, opacity: 0.75);
    rect(canvas, 155, 16, 58, 18, 0xFFFF7A6B, radius: 5, opacity: 0.7);
    for (var i = 0; i < 7; i++) {
      rect(
        canvas,
        159 + i * 7,
        38,
        5,
        5,
        0xFFD0D5DD,
        radius: 1.5,
        opacity: 0.6,
      );
    }

    rect(canvas, -5, 185, 195, 100, 0xFFFF9B8A, radius: 12, opacity: 0.55);
    rect(canvas, -5, 174, 195, 28, 0xFFFFB3A7, radius: 8, opacity: 0.65);
    rect(canvas, 8, 176, 72, 24, 0xFFFFFFFF, radius: 8, opacity: 0.85);
    final blanket = Path()
      ..moveTo(-5, 200)
      ..quadraticBezierTo(45, 194, 95, 200)
      ..quadraticBezierTo(145, 206, 190, 200);
    canvas.drawPath(
      blanket,
      Paint()
        ..color = c(0xFFFFFFFF, 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    rect(canvas, 218, 155, 175, 25, 0xFFC8A060, radius: 5, opacity: 0.65);
    rect(canvas, 228, 178, 8, 45, 0xFFB08040, radius: 4, opacity: 0.5);
    rect(canvas, 373, 178, 8, 45, 0xFFB08040, radius: 4, opacity: 0.5);
    rect(canvas, 264, 127, 48, 30, 0xFF2943A6, radius: 8, opacity: 0.75);
    rect(canvas, 268, 131, 40, 22, 0xFFFFFFFF, radius: 5, opacity: 0.35);
    canvas.drawCircle(
      const Offset(288, 142),
      7,
      Paint()..color = c(0xFF4C5FD7, 0.6),
    );

    if (frame == 0) {
      rect(canvas, 222, 112, 10, 42, 0xFFFFFFFF, radius: 5, opacity: 0.9);
      canvas.drawCircle(
        const Offset(227, 153),
        8,
        Paint()..color = c(0xFFFF7A6B, 0.95),
      );
      rect(canvas, 224, 128, 6, 25, 0xFFFF7A6B, radius: 3, opacity: 0.6);
    }

    canvas.drawCircle(
      const Offset(210, 30),
      18,
      Paint()..color = c(0xFFFFFFFF, 0.78),
    );
    canvas.drawCircle(
      const Offset(210, 30),
      18,
      Paint()
        ..color = c(0xFFF0C030)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    line(
      canvas,
      const Offset(210, 30),
      const Offset(210, 18),
      0xFF24304A,
      width: 2,
      opacity: 0.7,
    );
    line(
      canvas,
      const Offset(210, 30),
      const Offset(220, 34),
      0xFF24304A,
      width: 1.5,
      opacity: 0.7,
    );
  }

  void _classroom(Canvas canvas) {
    canvas.drawColor(c(0xFFEEF3FF), BlendMode.src);
    rect(canvas, 0, 282, 393, 38, 0xFFB8C6EE, opacity: 0.35);
    rect(canvas, 24, 18, 200, 110, 0xFF2D7A5E, radius: 8, opacity: 0.75);
    rect(
      canvas,
      24,
      18,
      200,
      110,
      0xFFC8A060,
      radius: 8,
      style: PaintingStyle.stroke,
      strokeWidth: 5,
    );
    line(
      canvas,
      const Offset(42, 42),
      const Offset(150, 42),
      0xFFFFFFFF,
      width: 3,
      opacity: 0.6,
    );
    line(
      canvas,
      const Offset(42, 60),
      const Offset(190, 60),
      0xFFFFFFFF,
      width: 2.5,
      opacity: 0.42,
    );
    line(
      canvas,
      const Offset(42, 76),
      const Offset(128, 76),
      0xFFFFFFFF,
      width: 2.5,
      opacity: 0.42,
    );
    rect(canvas, 30, 128, 188, 7, 0xFFC8A060, radius: 3.5, opacity: 0.7);

    canvas.drawCircle(
      const Offset(292, 34),
      18,
      Paint()..color = c(0xFFFFFFFF, 0.85),
    );
    canvas.drawCircle(
      const Offset(292, 34),
      18,
      Paint()
        ..color = c(0xFF4C5FD7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
    line(
      canvas,
      const Offset(292, 34),
      const Offset(292, 23),
      0xFF24304A,
      width: 2,
      opacity: 0.7,
    );
    line(
      canvas,
      const Offset(292, 34),
      const Offset(300, 38),
      0xFF24304A,
      width: 1.5,
      opacity: 0.7,
    );

    rect(canvas, 318, 16, 64, 84, 0xFFDAEEFF, radius: 7, opacity: 0.7);
    rect(
      canvas,
      318,
      16,
      64,
      84,
      0xFF73A7E8,
      radius: 7,
      style: PaintingStyle.stroke,
      strokeWidth: 3.5,
    );
    line(
      canvas,
      const Offset(350, 16),
      const Offset(350, 100),
      0xFF73A7E8,
      width: 2.5,
    );
    line(
      canvas,
      const Offset(318, 58),
      const Offset(382, 58),
      0xFF73A7E8,
      width: 2.5,
    );

    rect(canvas, 243, 70, 58, 70, 0xFFFFFFFF, radius: 6, opacity: 0.8);
    rect(canvas, 249, 78, 20, 10, 0xFF4D91FF, radius: 4, opacity: 0.8);
    rect(canvas, 249, 92, 26, 10, 0xFFD9485F, radius: 4, opacity: 0.7);
    rect(canvas, 249, 106, 18, 10, 0xFF1F9D70, radius: 4, opacity: 0.7);
    rect(canvas, 249, 120, 30, 10, 0xFFE5A91D, radius: 4, opacity: 0.7);

    rect(canvas, 236, 196, 150, 22, 0xFFC8A060, radius: 6, opacity: 0.7);
    rect(canvas, 246, 216, 9, 52, 0xFFB08040, radius: 4, opacity: 0.55);
    rect(canvas, 368, 216, 9, 52, 0xFFB08040, radius: 4, opacity: 0.55);
    rect(canvas, 252, 182, 52, 16, 0xFF4C5FD7, radius: 3, opacity: 0.65);
    rect(canvas, 258, 176, 46, 12, 0xFFD9485F, radius: 3, opacity: 0.5);
    rect(canvas, 6, 222, 120, 18, 0xFFD9B87C, radius: 5, opacity: 0.6);
    rect(canvas, 14, 238, 8, 42, 0xFFB08040, radius: 4, opacity: 0.5);
    rect(canvas, 104, 238, 8, 42, 0xFFB08040, radius: 4, opacity: 0.5);
    rect(canvas, 136, 238, 40, 44, 0xFF6C4FD3, radius: 8, opacity: 0.5);
  }

  void _lab(Canvas canvas) {
    canvas.drawColor(c(0xFFE8F8F1), BlendMode.src);
    rect(canvas, 0, 284, 393, 36, 0xFF9CD8BE, opacity: 0.35);
    rect(canvas, 16, 20, 150, 10, 0xFFC8A060, radius: 4, opacity: 0.7);
    rect(canvas, 16, 78, 150, 10, 0xFFC8A060, radius: 4, opacity: 0.7);
    const bottleColors = [
      0xFF73C7FF,
      0xFF46C98B,
      0xFFFFD36A,
      0xFFD9485F,
      0xFF8B5CF6,
    ];
    for (var i = 0; i < bottleColors.length; i++) {
      rect(
        canvas,
        26 + i * 25,
        i.isEven ? -2 : 2,
        16,
        24,
        bottleColors[i],
        radius: 5,
        opacity: 0.7,
      );
    }
    rect(canvas, 28, 52, 24, 28, 0xFFFFFFFF, radius: 5, opacity: 0.8);
    rect(canvas, 62, 58, 34, 22, 0xFF4C5FD7, radius: 4, opacity: 0.5);
    rect(canvas, 106, 54, 22, 26, 0xFFFFFFFF, radius: 5, opacity: 0.7);

    rect(canvas, 296, 14, 82, 88, 0xFFDAEEFF, radius: 8, opacity: 0.7);
    rect(
      canvas,
      296,
      14,
      82,
      88,
      0xFF38B886,
      radius: 8,
      style: PaintingStyle.stroke,
      strokeWidth: 3.5,
    );
    line(
      canvas,
      const Offset(337, 14),
      const Offset(337, 102),
      0xFF38B886,
      width: 2.5,
    );
    line(
      canvas,
      const Offset(296, 58),
      const Offset(378, 58),
      0xFF38B886,
      width: 2.5,
    );
    rect(canvas, 196, 26, 76, 58, 0xFFFFFFFF, radius: 6, opacity: 0.8);
    canvas.drawCircle(
      const Offset(216, 48),
      10,
      Paint()..color = c(0xFFD9485F, 0.6),
    );
    rect(canvas, 232, 40, 32, 6, 0xFF8490AA, radius: 3, opacity: 0.5);
    rect(canvas, 232, 52, 26, 6, 0xFF8490AA, radius: 3, opacity: 0.4);

    rect(canvas, 0, 192, 393, 20, 0xFFF7F8FC, opacity: 0.95);
    rect(canvas, 0, 210, 393, 8, 0xFFC4CBDF, opacity: 0.6);
    for (final x in [24.0, 200.0, 360.0]) {
      rect(canvas, x, 218, 10, 64, 0xFF8490AA, radius: 4, opacity: 0.45);
    }
    rect(canvas, 52, 176, 52, 10, 0xFF3445AC, radius: 4, opacity: 0.85);
    canvas.save();
    canvas.translate(71, 153);
    canvas.rotate(18 * math.pi / 180);
    rect(canvas, -5, -25, 10, 50, 0xFF4C5FD7, radius: 4, opacity: 0.9);
    canvas.restore();
    canvas.drawCircle(
      const Offset(72, 164),
      9,
      Paint()..color = c(0xFF73C7FF, 0.8),
    );
    rect(canvas, 58, 150, 24, 7, 0xFF4C5FD7, radius: 3.5, opacity: 0.7);
    rect(canvas, 140, 158, 52, 34, 0xFFC8A060, radius: 5, opacity: 0.55);
    for (var i = 0; i < 3; i++) {
      rect(
        canvas,
        148 + i * 15,
        140 - (i % 2) * 4,
        9,
        40 + (i % 2) * 4,
        bottleColors[i],
        radius: 4.5,
        opacity: 0.75,
      );
    }
    rect(canvas, 292, 170, 58, 20, 0xFF4C5FD7, radius: 3, opacity: 0.7);
  }

  void _office(Canvas canvas) {
    canvas.drawColor(c(0xFFEEF3FF), BlendMode.src);
    rect(canvas, 258, 10, 118, 95, 0xFFDAEEFF, radius: 8, opacity: 0.55);
    rect(
      canvas,
      258,
      10,
      118,
      95,
      0xFF73C7FF,
      radius: 8,
      style: PaintingStyle.stroke,
      strokeWidth: 3.5,
    );
    line(
      canvas,
      const Offset(317, 10),
      const Offset(317, 105),
      0xFF73C7FF,
      width: 2.5,
    );
    line(
      canvas,
      const Offset(258, 57),
      const Offset(376, 57),
      0xFF73C7FF,
      width: 2.5,
    );
    rect(canvas, 270, 20, 28, 38, 0xFF8B5CF6, radius: 3, opacity: 0.22);
    rect(canvas, 304, 28, 22, 30, 0xFF4263EB, radius: 3, opacity: 0.22);
    rect(canvas, 330, 22, 18, 36, 0xFF46C98B, radius: 3, opacity: 0.15);
    rect(canvas, -5, 200, 403, 20, 0xFFC8A060, opacity: 0.55);
    rect(canvas, -5, 218, 403, 102, 0xFFB08040, opacity: 0.35);
    rect(canvas, 22, 132, 148, 90, 0xFF8B5CF6, radius: 7, opacity: 0.6);
    rect(canvas, 30, 139, 132, 78, 0xFFFFFFFF, radius: 5, opacity: 0.28);
    rect(canvas, 8, 219, 178, 10, 0xFF6D28D9, radius: 5, opacity: 0.5);
    rect(canvas, 206, 148, 38, 50, 0xFFFF7A6B, radius: 9, opacity: 0.6);
    final handle = Path()
      ..moveTo(244, 162)
      ..quadraticBezierTo(258, 162, 258, 178)
      ..quadraticBezierTo(258, 194, 244, 194);
    canvas.drawPath(
      handle,
      Paint()
        ..color = c(0xFFFF7A6B, 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.5
        ..strokeCap = StrokeCap.round,
    );
    rect(canvas, 278, 148, 88, 58, 0xFFFFFFFF, radius: 5, opacity: 0.72);
    canvas.drawCircle(
      const Offset(370, 122),
      26,
      Paint()..color = c(0xFF46C98B, 0.38),
    );
    canvas.drawCircle(
      const Offset(384, 136),
      16,
      Paint()..color = c(0xFF46C98B, 0.28),
    );
    rect(canvas, 364, 146, 12, 30, 0xFF1B7A4E, radius: 6, opacity: 0.4);
  }

  void _mentor(Canvas canvas) {
    canvas.drawColor(c(0xFFF1EDFF), BlendMode.src);
    rect(canvas, 0, 284, 393, 36, 0xFFC9BCF2, opacity: 0.35);
    rect(canvas, 14, 14, 110, 92, 0xFFDAEEFF, radius: 8, opacity: 0.65);
    rect(
      canvas,
      14,
      14,
      110,
      92,
      0xFF8C6CFF,
      radius: 8,
      style: PaintingStyle.stroke,
      strokeWidth: 3.5,
    );
    line(
      canvas,
      const Offset(69, 14),
      const Offset(69, 106),
      0xFF8C6CFF,
      width: 2.5,
    );
    line(
      canvas,
      const Offset(14, 60),
      const Offset(124, 60),
      0xFF8C6CFF,
      width: 2.5,
    );
    for (var i = 0; i < 4; i++) {
      rect(
        canvas,
        24 + i * 24,
        26 + (i % 2) * 6,
        16,
        30 - (i % 2) * 6,
        0xFF6C4FD3,
        radius: 2.5,
        opacity: 0.25,
      );
    }
    rect(canvas, 152, 22, 64, 48, 0xFFFFFFFF, radius: 5, opacity: 0.85);
    canvas.drawCircle(
      const Offset(184, 38),
      7,
      Paint()..color = c(0xFFFFD36A, 0.85),
    );
    rect(canvas, 242, 16, 136, 96, 0xFFFFFFFF, radius: 8, opacity: 0.85);
    rect(canvas, 242, 16, 136, 20, 0xFF6C4FD3, radius: 8, opacity: 0.75);
    for (var row = 0; row < 3; row++) {
      for (var col = 0; col < 4; col++) {
        const colors = [0xFFF1EDFF, 0xFFE8F8F1, 0xFFFFF6DC];
        rect(
          canvas,
          250 + col * 31,
          44 + row * 21,
          26,
          15,
          colors[(row + col) % 3],
          radius: 3.5,
          opacity: 0.95,
        );
      }
    }
    rect(canvas, 188, 196, 205, 22, 0xFFC8A060, radius: 6, opacity: 0.7);
    rect(canvas, 200, 216, 10, 52, 0xFFB08040, radius: 4, opacity: 0.55);
    rect(canvas, 372, 216, 10, 52, 0xFFB08040, radius: 4, opacity: 0.55);
    rect(canvas, 212, 158, 76, 42, 0xFF6C4FD3, radius: 6, opacity: 0.75);
    rect(canvas, 218, 164, 64, 30, 0xFFFFFFFF, radius: 4, opacity: 0.3);
    rect(canvas, 206, 198, 88, 7, 0xFF5137AA, radius: 3.5, opacity: 0.6);
    canvas.drawCircle(
      const Offset(44, 216),
      30,
      Paint()..color = c(0xFF46C98B, 0.5),
    );
    canvas.drawCircle(
      const Offset(24, 234),
      20,
      Paint()..color = c(0xFF46C98B, 0.38),
    );
    canvas.drawCircle(
      const Offset(66, 234),
      18,
      Paint()..color = c(0xFF46C98B, 0.42),
    );
    final pot = Path()
      ..moveTo(30, 258)
      ..lineTo(58, 258)
      ..lineTo(54, 288)
      ..lineTo(34, 288)
      ..close();
    canvas.drawPath(pot, Paint()..color = c(0xFFB08040, 0.6));
  }

  @override
  bool shouldRepaint(covariant _SceneBackgroundPainter oldDelegate) =>
      oldDelegate.scene != scene || oldDelegate.frame != frame;
}

class _StudentCharacterPainter extends CustomPainter {
  final String expression;
  final bool workTheme;

  const _StudentCharacterPainter({
    required this.expression,
    required this.workTheme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 100, size.height / 180);
    final happy = {'happy', 'relieved', 'celebrate'}.contains(expression);
    final sick = expression == 'sick';
    final excited = expression == 'celebrate';
    const skin = Color(0xFFFDDBB4);
    final hair = Color(workTheme ? 0xFF5A3E78 : 0xFF3D2C1E);
    final uniform = Color(workTheme ? 0xFF6C4FD3 : 0xFF4C5FD7);
    final shirt = Color(workTheme ? 0xFFF5F0FF : 0xFFFFFFFF);

    canvas.drawRRect(_rr(19, 105, 62, 75, 14), Paint()..color = shirt);
    final collar = Path()
      ..moveTo(37, 105)
      ..lineTo(50, 122)
      ..lineTo(63, 105)
      ..close();
    canvas.drawPath(collar, Paint()..color = uniform.withValues(alpha: 0.88));
    canvas.drawRRect(
      _rr(32, 102, 36, 7, 3.5),
      Paint()..color = uniform.withValues(alpha: 0.72),
    );
    canvas.drawRRect(_rr(43, 90, 14, 18, 7), Paint()..color = skin);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(50, 67), width: 72, height: 74),
      Paint()..color = skin,
    );

    final hairPath = Path()
      ..moveTo(16, 58)
      ..quadraticBezierTo(14, 20, 50, 14)
      ..quadraticBezierTo(86, 20, 84, 58)
      ..quadraticBezierTo(78, 36, 50, 33)
      ..quadraticBezierTo(22, 36, 16, 58)
      ..close();
    canvas.drawPath(hairPath, Paint()..color = hair);
    if (workTheme) {
      canvas.drawOval(
        Rect.fromCenter(center: const Offset(50, 15), width: 30, height: 16),
        Paint()..color = hair,
      );
    }

    final faceLine = Paint()
      ..color = hair
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    if (happy) {
      _curve(
        canvas,
        const Offset(29, 64),
        const Offset(38, 57),
        const Offset(47, 64),
        faceLine,
      );
      _curve(
        canvas,
        const Offset(53, 64),
        const Offset(62, 57),
        const Offset(71, 64),
        faceLine,
      );
    } else if (sick) {
      _eye(canvas, 37, 68, hair, small: true);
      _eye(canvas, 63, 68, hair, small: true);
      _curve(
        canvas,
        const Offset(29, 61),
        const Offset(37, 66),
        const Offset(45, 61),
        faceLine..strokeWidth = 1.8,
      );
      _curve(
        canvas,
        const Offset(55, 61),
        const Offset(63, 66),
        const Offset(71, 61),
        faceLine,
      );
    } else {
      _eye(canvas, 37, 65, hair);
      _eye(canvas, 63, 65, hair);
    }
    canvas.drawCircle(
      const Offset(50, 77),
      2.5,
      Paint()..color = const Color(0xFFE8A887),
    );
    if (happy || excited) {
      _curve(
        canvas,
        const Offset(36, 87),
        const Offset(50, 98),
        const Offset(64, 87),
        faceLine..strokeWidth = 2.5,
      );
    } else if (sick) {
      _curve(
        canvas,
        const Offset(40, 90),
        const Offset(50, 87),
        const Offset(60, 90),
        faceLine..strokeWidth = 2,
      );
    } else {
      _curve(
        canvas,
        const Offset(39, 88),
        const Offset(50, 93),
        const Offset(61, 88),
        faceLine..strokeWidth = 2,
      );
    }
    if (sick) {
      canvas.drawCircle(
        const Offset(27, 76),
        9,
        Paint()..color = const Color(0xFFFF7A6B).withValues(alpha: 0.2),
      );
      canvas.drawCircle(
        const Offset(73, 76),
        9,
        Paint()..color = const Color(0xFFFF7A6B).withValues(alpha: 0.2),
      );
      canvas.drawCircle(
        const Offset(50, 77),
        4,
        Paint()..color = const Color(0xFFFF9B8A).withValues(alpha: 0.55),
      );
    }
    final handY = excited ? 116.0 : 138.0;
    canvas.drawCircle(
      Offset(excited ? 8 : 10, handY),
      10,
      Paint()..color = skin,
    );
    canvas.drawCircle(
      Offset(excited ? 92 : 90, handY),
      10,
      Paint()..color = skin,
    );
  }

  static RRect _rr(double x, double y, double w, double h, double radius) =>
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, w, h),
        Radius.circular(radius),
      );

  static void _curve(
    Canvas canvas,
    Offset start,
    Offset control,
    Offset end,
    Paint paint,
  ) {
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);
    canvas.drawPath(path, paint);
  }

  static void _eye(
    Canvas canvas,
    double x,
    double y,
    Color hair, {
    bool small = false,
  }) {
    canvas.drawOval(
      Rect.fromCenter(center: Offset(x, y), width: 16, height: small ? 13 : 18),
      Paint()..color = Colors.white,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(x + 2, y + 2),
        width: 9,
        height: small ? 7 : 10,
      ),
      Paint()..color = hair,
    );
  }

  @override
  bool shouldRepaint(covariant _StudentCharacterPainter oldDelegate) =>
      oldDelegate.expression != expression ||
      oldDelegate.workTheme != workTheme;
}

class _OtherCharacterPainter extends CustomPainter {
  final String persona;

  const _OtherCharacterPainter(this.persona);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 100, size.height / 180);
    const skin = Color(0xFFFDDBB4);
    final labCoat = persona == 'petugas-lab';
    final bun = {'ibu-guru', 'hrd', 'pembimbing'}.contains(persona);
    final hair = switch (persona) {
      'wali-kelas' => const Color(0xFF7A6558),
      'petugas-lab' => const Color(0xFF24304A),
      'pembimbing' => const Color(0xFF5A3E78),
      _ => const Color(0xFF3D2C1E),
    };
    final clothes = switch (persona) {
      'wali-kelas' => const Color(0xFF2943A6),
      'ibu-guru' => const Color(0xFF6C4FD3),
      'hrd' => const Color(0xFF1B7A4E),
      'pembimbing' => const Color(0xFF3445AC),
      _ => Colors.white,
    };
    canvas.drawRRect(
      _StudentCharacterPainter._rr(18, 103, 64, 77, 14),
      Paint()..color = clothes,
    );
    if (labCoat) {
      canvas.drawRRect(
        _StudentCharacterPainter._rr(18, 103, 64, 77, 14),
        Paint()
          ..color = const Color(0xFFC4CBDF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
    canvas.drawRRect(
      _StudentCharacterPainter._rr(43, 87, 14, 18, 7),
      Paint()..color = skin,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(50, 65), width: 76, height: 72),
      Paint()..color = skin,
    );
    final hairPath = Path()
      ..moveTo(14, 55)
      ..quadraticBezierTo(12, 18, 50, 13)
      ..quadraticBezierTo(88, 18, 86, 55)
      ..quadraticBezierTo(80, 30, 50, 27)
      ..quadraticBezierTo(20, 30, 14, 55)
      ..close();
    canvas.drawPath(hairPath, Paint()..color = hair);
    if (bun) canvas.drawCircle(const Offset(50, 14), 13, Paint()..color = hair);

    final glasses = Paint()
      ..color = const Color(0xFF555555)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    canvas.drawRRect(_StudentCharacterPainter._rr(24, 59, 21, 15, 6), glasses);
    canvas.drawRRect(_StudentCharacterPainter._rr(55, 59, 21, 15, 6), glasses);
    canvas.drawLine(const Offset(45, 66), const Offset(55, 66), glasses);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(35, 67), width: 12, height: 10),
      Paint()..color = Colors.white70,
    );
    canvas.drawCircle(
      const Offset(36, 68),
      3.5,
      Paint()..color = const Color(0xFF3D2C1E),
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(65, 67), width: 12, height: 10),
      Paint()..color = Colors.white70,
    );
    canvas.drawCircle(
      const Offset(66, 68),
      3.5,
      Paint()..color = const Color(0xFF3D2C1E),
    );
    _StudentCharacterPainter._curve(
      canvas,
      const Offset(36, 83),
      const Offset(50, 93),
      const Offset(64, 83),
      Paint()
        ..color = const Color(0xFF3D2C1E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(const Offset(10, 142), 10, Paint()..color = skin);
    canvas.drawCircle(const Offset(90, 142), 10, Paint()..color = skin);
  }

  @override
  bool shouldRepaint(covariant _OtherCharacterPainter oldDelegate) =>
      oldDelegate.persona != persona;
}
