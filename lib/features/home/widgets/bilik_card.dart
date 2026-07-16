import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wicara_application_1/core/theme/app_colors.dart';
import 'package:wicara_application_1/features/shared/widgets/fun_ui_components.dart';
import 'package:wicara_application_1/features/shared/widgets/wicara_illustration_icon.dart';
import 'package:wicara_application_1/models/revision3_content.dart';

class BilikCard extends StatelessWidget {
  final LearningBilik bilik;
  final int completed;
  final int total;
  final String? nextMission;
  final VoidCallback onTap;

  const BilikCard({
    super.key,
    required this.bilik,
    required this.completed,
    required this.total,
    this.nextMission,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSchool = bilik.isSchool;
    final brand = isSchool ? AppColors.indigo : AppColors.purple;
    final dark = isSchool ? AppColors.indigoDark : AppColors.purpleDark;
    final soft = isSchool ? AppColors.softBlue : AppColors.softPurple;
    final open = completed == total ? 0 : (completed + 1).clamp(1, total);
    final progress = total == 0 ? 0.0 : completed / total;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.line),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A4B5DFF),
                blurRadius: 36,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            children: [
              SizedBox(
                height: 190,
                child: Stack(
                  clipBehavior: Clip.antiAlias,
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: soft,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(27),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      width: 210,
                      height: 158,
                      child: CustomPaint(
                        painter: _BilikWorldPainter(isSchool: isSchool),
                      ),
                    ),
                    Positioned(
                      left: 18,
                      top: 18,
                      right: 124,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 7,
                            runSpacing: 7,
                            children: [
                              _Badge(
                                color: brand,
                                text: '$total Kasus',
                                illustration: isSchool
                                    ? WicaraIllustrationType.school
                                    : WicaraIllustrationType.work,
                              ),
                              _Badge(
                                color: Colors.white.withValues(alpha: 0.82),
                                text: completed == total
                                    ? 'Selesai ✓'
                                    : '$open Terbuka',
                                foreground: AppColors.text2,
                                bordered: true,
                              ),
                            ],
                          ),
                          const SizedBox(height: 13),
                          Text(
                            bilik.title,
                            maxLines: 2,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 22,
                              height: 1.08,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            bilik.description,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.nunitoSans(
                              fontSize: 12,
                              height: 1.35,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF3A4A7A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 18,
                      right: 164,
                      bottom: 14,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Progres',
                                style: GoogleFonts.nunitoSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.text2,
                                ),
                              ),
                              Text(
                                '${(progress * 100).round()}%',
                                style: GoogleFonts.nunitoSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: brand,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          AnimatedProgressBar(
                            value: progress,
                            color: brand,
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.78,
                            ),
                            height: 7,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 15, 14, 17),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.workspace_premium_outlined,
                                size: 16,
                                color: Color(0xFFA66A00),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                '+${isSchool ? 50 : 75} XP per misi',
                                style: GoogleFonts.nunitoSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFFA66A00),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            completed >= total
                                ? '$completed dari $total kasus selesai'
                                : 'Berikutnya: ${nextMission ?? 'Misi selanjutnya'}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.nunitoSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: brand,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(color: dark, offset: const Offset(0, 5)),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isSchool ? 'Mulai Petualangan' : 'Jelajahi Bilik',
                              style: GoogleFonts.nunitoSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BilikWorldPainter extends CustomPainter {
  final bool isSchool;

  const _BilikWorldPainter({required this.isSchool});

  Color _color(int value, [double opacity = 1]) =>
      Color(value).withValues(alpha: opacity);

  void _rect(
    Canvas canvas,
    double x,
    double y,
    double width,
    double height,
    int color, {
    double radius = 0,
    double opacity = 1,
  }) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, width, height),
        Radius.circular(radius),
      ),
      Paint()..color = _color(color, opacity),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 210, size.height / 158);
    if (isSchool) {
      _paintSchool(canvas);
    } else {
      _paintOffice(canvas);
    }
  }

  void _paintSchool(Canvas canvas) {
    _rect(canvas, 0, 128, 210, 30, 0xFFB8D4F0, radius: 6, opacity: 0.42);
    _rect(canvas, 36, 134, 130, 14, 0xFF8EB4E3, radius: 7, opacity: 0.5);
    _rect(canvas, 72, 139, 18, 3.5, 0xFFFFFFFF, radius: 1.5, opacity: 0.65);
    _rect(canvas, 104, 139, 18, 3.5, 0xFFFFFFFF, radius: 1.5, opacity: 0.65);
    _rect(canvas, 120, 52, 76, 78, 0xFF4C5FD7, radius: 7, opacity: 0.88);
    final roof = Path()
      ..moveTo(118, 54)
      ..lineTo(198, 54)
      ..lineTo(158, 22)
      ..close();
    canvas.drawPath(roof, Paint()..color = _color(0xFF3445AC, 0.92));
    for (final x in [130.0, 152.0, 174.0]) {
      _rect(canvas, x, 68, 14, 13, 0xFFFFFFFF, radius: 3.5, opacity: 0.75);
    }
    _rect(canvas, 148, 100, 22, 28, 0xFFFFFFFF, radius: 5, opacity: 0.52);
    _rect(canvas, 134, 90, 36, 9, 0xFFFFD36A, radius: 4.5, opacity: 0.92);
    canvas.drawCircle(
      const Offset(102, 104),
      19,
      Paint()..color = _color(0xFF72D7B2, 0.62),
    );
    _rect(canvas, 98, 120, 8, 14, 0xFF2D7A5E, radius: 4, opacity: 0.52);
    canvas.drawCircle(
      const Offset(60, 94),
      27,
      Paint()..color = _color(0xFF72D7B2, 0.92),
    );
    canvas.drawCircle(
      const Offset(42, 107),
      17,
      Paint()..color = _color(0xFF4FC9A0, 0.8),
    );
    canvas.drawCircle(
      const Offset(78, 104),
      19,
      Paint()..color = _color(0xFF5ACCA6, 0.78),
    );
    _rect(canvas, 55, 118, 10, 20, 0xFF2D7A5E, radius: 5, opacity: 0.72);
    canvas.drawCircle(
      const Offset(184, 14),
      16,
      Paint()..color = _color(0xFFFFD36A, 0.72),
    );
    for (final cloud in const [
      Rect.fromLTWH(14, 18, 44, 24),
      Rect.fromLTWH(37, 15, 34, 22),
      Rect.fromLTWH(4, 25, 28, 18),
    ]) {
      canvas.drawOval(cloud, Paint()..color = _color(0xFFFFFFFF, 0.68));
    }
  }

  void _paintOffice(Canvas canvas) {
    _rect(canvas, 122, 18, 76, 132, 0xFF6C4FD3, radius: 9, opacity: 0.82);
    for (var row = 0; row < 4; row++) {
      for (var col = 0; col < 3; col++) {
        _rect(
          canvas,
          131 + col * 20,
          30 + row * 24,
          12,
          15,
          0xFFFFFFFF,
          radius: 3.5,
          opacity: row < 2 ? 0.55 : 0.22,
        );
      }
    }
    _rect(canvas, 144, 116, 28, 34, 0xFFFFFFFF, radius: 6, opacity: 0.38);
    _rect(canvas, 8, 88, 80, 52, 0xFFB8A3FF, radius: 9, opacity: 0.48);
    _rect(canvas, 16, 74, 58, 36, 0xFF5137AA, radius: 6, opacity: 0.74);
    _rect(canvas, 10, 108, 70, 8, 0xFF4B3A9A, radius: 4, opacity: 0.62);
    _rect(canvas, 22, 80, 44, 24, 0xFFFFFFFF, radius: 3.5, opacity: 0.32);
    _rect(canvas, 100, 92, 16, 22, 0xFFD9485F, radius: 5.5, opacity: 0.6);
    final handle = Path()
      ..moveTo(116, 98)
      ..quadraticBezierTo(123, 98, 123, 105)
      ..quadraticBezierTo(123, 112, 116, 112);
    canvas.drawPath(
      handle,
      Paint()
        ..color = _color(0xFFD9485F, 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
    canvas.drawCircle(
      const Offset(196, 116),
      17,
      Paint()..color = _color(0xFF72D7B2, 0.72),
    );
    _rect(canvas, 191, 130, 9, 18, 0xFF2D7A5E, radius: 4.5, opacity: 0.58);
    _rect(canvas, 16, 40, 38, 38, 0xFF6C4FD3, radius: 8, opacity: 0.55);
    _rect(canvas, 16, 40, 38, 13, 0xFF5137AA, radius: 8, opacity: 0.85);
    _rect(canvas, 78, 26, 32, 22, 0xFFFFFFFF, radius: 7, opacity: 0.78);

    final at = TextPainter(
      text: TextSpan(
        text: '@',
        style: TextStyle(
          color: _color(0xFF4C5FD7, 0.88),
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    at.paint(canvas, const Offset(87, 29));
    canvas.drawCircle(
      const Offset(106, 28),
      5.5,
      Paint()..color = _color(0xFFD9485F, 0.92),
    );
  }

  @override
  bool shouldRepaint(covariant _BilikWorldPainter oldDelegate) =>
      oldDelegate.isSchool != isSchool;
}

class _Badge extends StatelessWidget {
  final Color color;
  final Color foreground;
  final String text;
  final bool bordered;
  final WicaraIllustrationType? illustration;

  const _Badge({
    required this.color,
    required this.text,
    this.foreground = Colors.white,
    this.bordered = false,
    this.illustration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(99),
        border: bordered ? Border.all(color: Colors.white) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (illustration != null) ...[
            WicaraIllustrationIcon(
              type: illustration!,
              size: 16,
              accent: foreground,
              showBackground: false,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: GoogleFonts.nunitoSans(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}
