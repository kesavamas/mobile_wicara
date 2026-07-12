import 'dart:math' as math;
import 'package:flutter/material.dart';

enum WikaMood { welcome, hint, celebrate, retry, point, unlock }

class WikaMascot extends StatefulWidget {
  final WikaMood mood;
  final double size;
  final bool animated;

  const WikaMascot({
    Key? key,
    this.mood = WikaMood.welcome,
    this.size = 72,
    this.animated = true,
  }) : super(key: key);

  @override
  State<WikaMascot> createState() => _WikaMascotState();
}

class _WikaMascotState extends State<WikaMascot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    if (widget.animated) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant WikaMascot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animated && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.animated && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bodyColors = {
      WikaMood.welcome: [const Color(0xFF4C5FD7), const Color(0xFF6C4FD3)],
      WikaMood.hint: [const Color(0xFF4C5FD7), const Color(0xFF3445AC)],
      WikaMood.celebrate: [const Color(0xFF6C4FD3), const Color(0xFF4C5FD7)],
      WikaMood.retry: [const Color(0xFF6C4FD3), const Color(0xFF4C5FD7)],
      WikaMood.point: [const Color(0xFF4C5FD7), const Color(0xFF1F9D70)],
      WikaMood.unlock: [const Color(0xFFFFD36A), const Color(0xFFD9485F)],
    };

    final colors = bodyColors[widget.mood] ?? [const Color(0xFF4C5FD7), const Color(0xFF6C4FD3)];

    Widget mascot = CustomPaint(
      size: Size(widget.size, widget.size * 1.15),
      painter: _WikaPainter(
        mood: widget.mood,
        c1: colors[0],
        c2: colors[1],
      ),
    );

    if (widget.animated) {
      return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final offset = math.sin(_controller.value * math.pi) * 8.0;
          return Transform.translate(
            offset: Offset(0, -offset),
            child: child,
          );
        },
        child: mascot,
      );
    }

    return mascot;
  }
}

class _WikaPainter extends CustomPainter {
  final WikaMood mood;
  final Color c1;
  final Color c2;

  _WikaPainter({required this.mood, required this.c1, required this.c2});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double scale = w / 100.0;

    // Ground shadow
    final Paint shadowPaint = Paint()
      ..color = const Color(0xFF24304A).withOpacity(0.10)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(50 * scale, 111 * scale),
        width: 56 * scale,
        height: 8 * scale,
      ),
      shadowPaint,
    );

    // Body Gradient
    final Rect bodyRect = Rect.fromLTWH(5 * scale, 4 * scale, 90 * scale, 80 * scale);
    final RRect bodyRRect = RRect.fromRectAndRadius(bodyRect, Radius.circular(22 * scale));
    final Paint bodyPaint = Paint()
      ..shader = LinearGradient(
        colors: [c1, c2],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bodyRect);
    canvas.drawRRect(bodyRRect, bodyPaint);

    // Bubble Tail
    final Path tailPath = Path()
      ..moveTo(26 * scale, 80 * scale)
      ..lineTo(16 * scale, 102 * scale)
      ..lineTo(46 * scale, 80 * scale)
      ..close();
    final Paint tailPaint = Paint()
      ..color = c1
      ..style = PaintingStyle.fill;
    canvas.drawPath(tailPath, tailPaint);

    // Shine / Highlight
    final Paint shinePaint = Paint()
      ..color = Colors.white.withOpacity(0.20)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(34 * scale, 19 * scale),
        width: 36 * scale,
        height: 18 * scale,
      ),
      shinePaint,
    );

    // Hands
    final Paint handPaint = Paint()
      ..color = c2
      ..style = PaintingStyle.fill;

    final bool isExcite = [WikaMood.celebrate, WikaMood.unlock].contains(mood);

    if (isExcite) {
      canvas.drawCircle(Offset(5 * scale, 32 * scale), 11 * scale, handPaint);
      canvas.drawCircle(Offset(95 * scale, 32 * scale), 11 * scale, handPaint);
    } else if (mood == WikaMood.welcome) {
      canvas.drawCircle(Offset(3 * scale, 58 * scale), 10 * scale, handPaint);
      canvas.drawCircle(Offset(97 * scale, 50 * scale), 10 * scale, handPaint);
      canvas.drawCircle(Offset(99 * scale, 37 * scale), 8 * scale, handPaint..color = c2.withOpacity(0.82));
    } else if (mood == WikaMood.hint) {
      canvas.drawCircle(Offset(3 * scale, 58 * scale), 10 * scale, handPaint);
      canvas.drawCircle(Offset(97 * scale, 48 * scale), 10 * scale, handPaint);
      
      final Paint linePaint = Paint()
        ..color = c2
        ..strokeWidth = 4 * scale
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(97 * scale, 48 * scale), Offset(110 * scale, 34 * scale), linePaint);
    } else if (mood == WikaMood.point) {
      canvas.drawCircle(Offset(3 * scale, 58 * scale), 10 * scale, handPaint);
      canvas.drawCircle(Offset(97 * scale, 55 * scale), 10 * scale, handPaint);
      
      final Paint linePaint = Paint()
        ..color = c2
        ..strokeWidth = 4 * scale
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(100 * scale, 55 * scale), Offset(113 * scale, 50 * scale), linePaint);
    } else {
      canvas.drawCircle(Offset(3 * scale, 58 * scale), 10 * scale, handPaint);
      canvas.drawCircle(Offset(97 * scale, 58 * scale), 10 * scale, handPaint);
    }

    // Eyes
    final bool isHappy = [WikaMood.celebrate, WikaMood.unlock, WikaMood.welcome].contains(mood);
    final Paint eyeStrokePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.5 * scale
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Paint whiteEyePaint = Paint()..color = Colors.white;
    final Paint darkEyePaint = Paint()..color = const Color(0xFF1F2858);

    if (isHappy) {
      final Path eye1 = Path()
        ..moveTo(27 * scale, 44 * scale)
        ..quadraticBezierTo(35 * scale, 37 * scale, 43 * scale, 44 * scale);
      final Path eye2 = Path()
        ..moveTo(57 * scale, 44 * scale)
        ..quadraticBezierTo(65 * scale, 37 * scale, 73 * scale, 44 * scale);
      canvas.drawPath(eye1, eyeStrokePaint);
      canvas.drawPath(eye2, eyeStrokePaint);
    } else if (mood == WikaMood.retry) {
      canvas.drawCircle(Offset(35 * scale, 44 * scale), 10 * scale, whiteEyePaint);
      canvas.drawCircle(Offset(35 * scale, 47 * scale), 5 * scale, darkEyePaint);
      canvas.drawCircle(Offset(65 * scale, 44 * scale), 10 * scale, whiteEyePaint);
      canvas.drawCircle(Offset(65 * scale, 47 * scale), 5 * scale, darkEyePaint);
    } else {
      canvas.drawCircle(Offset(35 * scale, 44 * scale), 10 * scale, whiteEyePaint);
      canvas.drawCircle(Offset(37 * scale, 45 * scale), 5.5 * scale, darkEyePaint);
      canvas.drawCircle(Offset(65 * scale, 44 * scale), 10 * scale, whiteEyePaint);
      canvas.drawCircle(Offset(67 * scale, 45 * scale), 5.5 * scale, darkEyePaint);
      
      canvas.drawCircle(Offset(39 * scale, 42 * scale), 2.5 * scale, whiteEyePaint);
      canvas.drawCircle(Offset(69 * scale, 42 * scale), 2.5 * scale, whiteEyePaint);
    }

    // Mouth
    final Paint mouthPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.5 * scale
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (isExcite) {
      final Path mouth = Path()
        ..moveTo(33 * scale, 66 * scale)
        ..quadraticBezierTo(50 * scale, 82 * scale, 67 * scale, 66 * scale);
      canvas.drawPath(mouth, mouthPaint..strokeWidth = 3 * scale);
    } else if (isHappy) {
      final Path mouth = Path()
        ..moveTo(36 * scale, 67 * scale)
        ..quadraticBezierTo(50 * scale, 78 * scale, 64 * scale, 67 * scale);
      canvas.drawPath(mouth, mouthPaint);
    } else if (mood == WikaMood.retry) {
      final Path mouth = Path()
        ..moveTo(38 * scale, 70 * scale)
        ..quadraticBezierTo(50 * scale, 68 * scale, 62 * scale, 70 * scale);
      canvas.drawPath(mouth, mouthPaint);
    } else {
      final Path mouth = Path()
        ..moveTo(38 * scale, 68 * scale)
        ..quadraticBezierTo(50 * scale, 76 * scale, 62 * scale, 68 * scale);
      canvas.drawPath(mouth, mouthPaint);
    }

    // Celebrate Sparkles
    if (mood == WikaMood.celebrate) {
      final Paint yellowSparkle = Paint()..color = const Color(0xFFFFD36A);
      canvas.drawCircle(Offset(13 * scale, 12 * scale), 4 * scale, yellowSparkle);
      canvas.drawCircle(Offset(88 * scale, 10 * scale), 3 * scale, whiteEyePaint..color = Colors.white.withOpacity(0.9));

      final Path starPath = Path()
        ..moveTo(88 * scale, 22 * scale)
        ..lineTo(90 * scale, 15 * scale)
        ..lineTo(92 * scale, 22 * scale)
        ..lineTo(86 * scale, 18 * scale)
        ..lineTo(94 * scale, 18 * scale)
        ..close();
      canvas.drawPath(starPath, whiteEyePaint..color = Colors.white.withOpacity(0.8));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
