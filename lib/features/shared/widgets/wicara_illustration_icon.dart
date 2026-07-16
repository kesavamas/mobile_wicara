import 'dart:math' as math;

import 'package:flutter/material.dart';

enum WicaraIllustrationType {
  dictionary,
  search,
  subject,
  predicate,
  object,
  adverb,
  progress,
  statistics,
  achievement,
  empty,
  school,
  work,
  practice,
  target,
  history,
  sync,
}

class WicaraIllustrationIcon extends StatelessWidget {
  final WicaraIllustrationType type;
  final double size;
  final Color accent;
  final Color background;
  final bool showBackground;

  const WicaraIllustrationIcon({
    super.key,
    required this.type,
    this.size = 56,
    this.accent = const Color(0xFF4C5FD7),
    this.background = const Color(0xFFEEF3FF),
    this.showBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: type.name,
      child: SizedBox.square(
        dimension: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: showBackground ? background : Colors.transparent,
            borderRadius: BorderRadius.circular(size * 0.3),
          ),
          child: Padding(
            padding: EdgeInsets.all(size * 0.13),
            child: CustomPaint(
              painter: _IllustrationPainter(type: type, accent: accent),
            ),
          ),
        ),
      ),
    );
  }
}

class _IllustrationPainter extends CustomPainter {
  final WicaraIllustrationType type;
  final Color accent;

  const _IllustrationPainter({required this.type, required this.accent});

  Color get dark => Color.lerp(accent, const Color(0xFF1F2858), 0.36)!;
  Color get soft => Color.lerp(accent, Colors.white, 0.7)!;

  RRect _rr(double x, double y, double w, double h, double radius) =>
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, w, h),
        Radius.circular(radius),
      );

  void _rect(
    Canvas canvas,
    double x,
    double y,
    double w,
    double h,
    Color color, {
    double radius = 8,
  }) {
    canvas.drawRRect(_rr(x, y, w, h, radius), Paint()..color = color);
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 100, size.height / 100);
    switch (type) {
      case WicaraIllustrationType.dictionary:
        _dictionary(canvas);
        break;
      case WicaraIllustrationType.search:
        _search(canvas);
        break;
      case WicaraIllustrationType.subject:
        _subject(canvas);
        break;
      case WicaraIllustrationType.predicate:
        _predicate(canvas);
        break;
      case WicaraIllustrationType.object:
        _object(canvas);
        break;
      case WicaraIllustrationType.adverb:
        _adverb(canvas);
        break;
      case WicaraIllustrationType.progress:
        _progress(canvas);
        break;
      case WicaraIllustrationType.statistics:
        _statistics(canvas);
        break;
      case WicaraIllustrationType.achievement:
        _achievement(canvas);
        break;
      case WicaraIllustrationType.empty:
        _empty(canvas);
        break;
      case WicaraIllustrationType.school:
        _school(canvas);
        break;
      case WicaraIllustrationType.work:
        _work(canvas);
        break;
      case WicaraIllustrationType.practice:
        _practice(canvas);
        break;
      case WicaraIllustrationType.target:
        _target(canvas);
        break;
      case WicaraIllustrationType.history:
        _history(canvas);
        break;
      case WicaraIllustrationType.sync:
        _sync(canvas);
        break;
    }
    canvas.restore();
  }

  void _dictionary(Canvas canvas) {
    final left = Path()
      ..moveTo(9, 27)
      ..quadraticBezierTo(31, 20, 48, 34)
      ..lineTo(48, 82)
      ..quadraticBezierTo(30, 69, 9, 77)
      ..close();
    final right = Path()
      ..moveTo(91, 27)
      ..quadraticBezierTo(69, 20, 52, 34)
      ..lineTo(52, 82)
      ..quadraticBezierTo(70, 69, 91, 77)
      ..close();
    canvas.drawShadow(left, dark.withValues(alpha: 0.28), 6, false);
    canvas.drawPath(left, Paint()..color = Colors.white);
    canvas.drawPath(right, Paint()..color = soft);
    canvas.drawLine(
      const Offset(50, 34),
      const Offset(50, 82),
      Paint()
        ..color = dark.withValues(alpha: 0.24)
        ..strokeWidth = 3,
    );
    _rect(canvas, 19, 38, 22, 6, accent, radius: 3);
    _rect(canvas, 59, 39, 20, 6, const Color(0xFFD9485F), radius: 3);
    _rect(canvas, 20, 51, 16, 5, const Color(0xFFE5A91D), radius: 2.5);
    _rect(canvas, 59, 52, 24, 5, const Color(0xFF1F9D70), radius: 2.5);
  }

  void _search(Canvas canvas) {
    canvas.drawCircle(const Offset(43, 42), 25, Paint()..color = Colors.white);
    canvas.drawCircle(
      const Offset(43, 42),
      20,
      Paint()
        ..color = accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9,
    );
    canvas.drawLine(
      const Offset(60, 60),
      const Offset(82, 82),
      Paint()
        ..color = dark
        ..strokeWidth = 13
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(
      const Offset(36, 35),
      5,
      Paint()..color = soft.withValues(alpha: 0.9),
    );
  }

  void _subject(Canvas canvas) {
    _rect(canvas, 13, 13, 74, 74, soft, radius: 20);
    canvas.drawCircle(const Offset(50, 39), 15, Paint()..color = accent);
    final body = Path()
      ..moveTo(25, 79)
      ..quadraticBezierTo(27, 56, 50, 56)
      ..quadraticBezierTo(73, 56, 75, 79)
      ..close();
    canvas.drawPath(body, Paint()..color = dark);
    canvas.drawCircle(const Offset(45, 35), 4, Paint()..color = Colors.white70);
  }

  void _predicate(Canvas canvas) {
    _rect(canvas, 12, 17, 76, 66, soft, radius: 18);
    final bolt = Path()
      ..moveTo(55, 17)
      ..lineTo(29, 53)
      ..lineTo(47, 53)
      ..lineTo(40, 84)
      ..lineTo(73, 43)
      ..lineTo(54, 43)
      ..close();
    canvas.drawShadow(bolt, dark.withValues(alpha: 0.25), 6, false);
    canvas.drawPath(bolt, Paint()..color = accent);
  }

  void _object(Canvas canvas) {
    final top = Path()
      ..moveTo(50, 13)
      ..lineTo(84, 31)
      ..lineTo(50, 49)
      ..lineTo(16, 31)
      ..close();
    final left = Path()
      ..moveTo(16, 31)
      ..lineTo(50, 49)
      ..lineTo(50, 87)
      ..lineTo(16, 68)
      ..close();
    final right = Path()
      ..moveTo(84, 31)
      ..lineTo(50, 49)
      ..lineTo(50, 87)
      ..lineTo(84, 68)
      ..close();
    canvas.drawPath(top, Paint()..color = const Color(0xFFFFD36A));
    canvas.drawPath(left, Paint()..color = accent);
    canvas.drawPath(right, Paint()..color = dark);
    _rect(canvas, 29, 25, 25, 5, Colors.white54, radius: 2.5);
  }

  void _adverb(Canvas canvas) {
    final pin = Path()
      ..moveTo(50, 88)
      ..cubicTo(42, 72, 24, 55, 24, 38)
      ..cubicTo(24, 19, 36, 10, 50, 10)
      ..cubicTo(64, 10, 76, 19, 76, 38)
      ..cubicTo(76, 55, 58, 72, 50, 88)
      ..close();
    canvas.drawShadow(pin, dark.withValues(alpha: 0.25), 6, false);
    canvas.drawPath(pin, Paint()..color = accent);
    canvas.drawCircle(const Offset(50, 37), 17, Paint()..color = Colors.white);
    canvas.drawLine(
      const Offset(50, 37),
      const Offset(50, 26),
      Paint()
        ..color = dark
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      const Offset(50, 37),
      const Offset(60, 42),
      Paint()
        ..color = dark
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
  }

  void _progress(Canvas canvas) {
    _rect(canvas, 13, 17, 74, 70, Colors.white, radius: 17);
    _rect(canvas, 24, 57, 12, 20, soft, radius: 5);
    _rect(canvas, 44, 43, 12, 34, accent, radius: 5);
    _rect(canvas, 64, 27, 12, 50, dark, radius: 5);
    final arrow = Path()
      ..moveTo(22, 48)
      ..lineTo(45, 31)
      ..lineTo(58, 35)
      ..lineTo(78, 15);
    canvas.drawPath(
      arrow,
      Paint()
        ..color = const Color(0xFF1F9D70)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  void _statistics(Canvas canvas) {
    canvas.drawCircle(const Offset(50, 50), 35, Paint()..color = soft);
    canvas.drawArc(
      const Rect.fromLTWH(15, 15, 70, 70),
      -math.pi / 2,
      math.pi * 1.45,
      false,
      Paint()
        ..color = accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 13
        ..strokeCap = StrokeCap.round,
    );
    _rect(canvas, 42, 41, 8, 20, dark, radius: 4);
    _rect(canvas, 54, 31, 8, 30, const Color(0xFF1F9D70), radius: 4);
  }

  void _achievement(Canvas canvas) {
    final ribbon = Path()
      ..moveTo(32, 55)
      ..lineTo(24, 91)
      ..lineTo(49, 75)
      ..lineTo(51, 75)
      ..lineTo(76, 91)
      ..lineTo(68, 55)
      ..close();
    canvas.drawPath(ribbon, Paint()..color = dark);
    canvas.drawCircle(const Offset(50, 38), 30, Paint()..color = accent);
    canvas.drawCircle(const Offset(50, 38), 20, Paint()..color = soft);
    final mark = Path()
      ..moveTo(39, 38)
      ..lineTo(47, 46)
      ..lineTo(63, 29);
    canvas.drawPath(
      mark,
      Paint()
        ..color = dark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  void _empty(Canvas canvas) {
    _rect(canvas, 16, 37, 68, 46, soft, radius: 14);
    _rect(canvas, 26, 18, 48, 48, Colors.white, radius: 12);
    _rect(canvas, 36, 31, 28, 5, accent.withValues(alpha: 0.45), radius: 2.5);
    _rect(canvas, 36, 42, 19, 5, accent.withValues(alpha: 0.28), radius: 2.5);
    final smile = Path()
      ..moveTo(38, 70)
      ..quadraticBezierTo(50, 79, 62, 70);
    canvas.drawPath(
      smile,
      Paint()
        ..color = dark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
  }

  void _school(Canvas canvas) {
    _rect(canvas, 18, 38, 64, 48, accent, radius: 8);
    final roof = Path()
      ..moveTo(11, 40)
      ..lineTo(50, 10)
      ..lineTo(89, 40)
      ..close();
    canvas.drawPath(roof, Paint()..color = dark);
    for (final x in [28.0, 45.0, 62.0]) {
      _rect(canvas, x, 49, 10, 10, Colors.white70, radius: 3);
    }
    _rect(canvas, 43, 66, 15, 20, soft, radius: 4);
  }

  void _work(Canvas canvas) {
    _rect(canvas, 21, 24, 58, 64, accent, radius: 10);
    for (var row = 0; row < 2; row++) {
      for (var col = 0; col < 3; col++) {
        _rect(
          canvas,
          30 + col * 16,
          36 + row * 17,
          9,
          10,
          Colors.white70,
          radius: 3,
        );
      }
    }
    _rect(canvas, 42, 70, 16, 18, dark, radius: 4);
    _rect(canvas, 10, 79, 80, 9, soft, radius: 4.5);
  }

  void _practice(Canvas canvas) {
    _rect(canvas, 10, 24, 45, 32, soft, radius: 10);
    _rect(canvas, 45, 46, 45, 32, accent, radius: 10);
    _rect(canvas, 19, 34, 25, 5, dark.withValues(alpha: 0.55), radius: 2.5);
    _rect(canvas, 56, 57, 23, 5, Colors.white70, radius: 2.5);
  }

  void _target(Canvas canvas) {
    for (final item in [
      (const Offset(50, 50), 38.0, soft),
      (const Offset(50, 50), 25.0, accent),
      (const Offset(50, 50), 11.0, dark),
    ]) {
      canvas.drawCircle(item.$1, item.$2, Paint()..color = item.$3);
    }
    canvas.drawLine(
      const Offset(53, 47),
      const Offset(87, 13),
      Paint()
        ..color = const Color(0xFFD9485F)
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );
  }

  void _history(Canvas canvas) {
    canvas.drawCircle(const Offset(50, 50), 36, Paint()..color = soft);
    canvas.drawCircle(
      const Offset(50, 50),
      30,
      Paint()
        ..color = accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8,
    );
    canvas.drawLine(
      const Offset(50, 50),
      const Offset(50, 29),
      Paint()
        ..color = dark
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      const Offset(50, 50),
      const Offset(66, 59),
      Paint()
        ..color = dark
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );
  }

  void _sync(Canvas canvas) {
    final cloud = Path()
      ..moveTo(24, 73)
      ..cubicTo(9, 72, 8, 49, 25, 45)
      ..cubicTo(29, 24, 58, 19, 70, 39)
      ..cubicTo(91, 39, 95, 70, 76, 73)
      ..close();
    canvas.drawPath(cloud, Paint()..color = soft);
    final arrows = Paint()
      ..color = accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      const Rect.fromLTWH(31, 42, 38, 28),
      math.pi,
      math.pi,
      false,
      arrows,
    );
    canvas.drawArc(
      const Rect.fromLTWH(31, 42, 38, 28),
      0,
      math.pi,
      false,
      arrows,
    );
  }

  @override
  bool shouldRepaint(covariant _IllustrationPainter oldDelegate) =>
      oldDelegate.type != type || oldDelegate.accent != accent;
}
