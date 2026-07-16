import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wicara_application_1/core/theme/app_colors.dart';
import 'package:wicara_application_1/features/guided_mode/widgets/revision3_scene.dart';
import 'package:wicara_application_1/models/revision3_content.dart';

class IndependentMissionVisual extends StatelessWidget {
  final LearningMission mission;
  final Color brand;

  const IndependentMissionVisual({
    super.key,
    required this.mission,
    required this.brand,
  });

  @override
  Widget build(BuildContext context) {
    final object = _objectFor(mission);
    final expression = mission.guided.frames.isEmpty
        ? 'neutral'
        : mission.guided.frames.first.expression;
    return Container(
      height: 224,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: brand.withValues(alpha: 0.22)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x101F2858),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Revision3Scene(
            mission: mission,
            studentExpression: expression,
            showStudent: true,
            showOther: false,
          ),
          Positioned(
            left: 13,
            top: 13,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(99),
                border: Border.all(color: brand.withValues(alpha: 0.18)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    mission.independent.kind == 'email'
                        ? Icons.alternate_email_rounded
                        : Icons.chat_bubble_outline_rounded,
                    size: 14,
                    color: brand,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    mission.independent.kind == 'email'
                        ? 'SIMULASI EMAIL'
                        : 'SIMULASI PESAN',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: brand,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 13,
            bottom: 13,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 205),
              padding: const EdgeInsets.fromLTRB(8, 7, 12, 7),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: brand.withValues(alpha: 0.16)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox.square(
                    dimension: 42,
                    child: CustomPaint(
                      painter: _MissionObjectPainter(
                        object.type,
                        accent: object.accent,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          object.title,
                          style: GoogleFonts.nunitoSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: AppColors.ink,
                          ),
                        ),
                        Text(
                          object.subtitle,
                          style: GoogleFonts.nunitoSans(
                            fontSize: 8,
                            height: 1.2,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class IndependentCharacterResult extends StatelessWidget {
  final LearningMission mission;
  final Color brand;

  const IndependentCharacterResult({
    super.key,
    required this.mission,
    required this.brand,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFF9DE1C8), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x121F9D70),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 176,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Revision3Scene(
                  mission: mission,
                  studentExpression: 'celebrate',
                  showStudent: true,
                  showOther: false,
                ),
                Positioned(
                  right: 13,
                  top: 13,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.verified_rounded,
                      color: AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            child: Column(
              children: [
                Text(
                  'Hebat, ${mission.studentName}!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Pesan untuk ${mission.otherName} sudah jelas, sopan, dan formal.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 11,
                    height: 1.4,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text2,
                  ),
                ),
                const SizedBox(height: 11),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.softMint,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    'Misi Mandiri Selesai',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _MissionObjectType {
  thermometer,
  calendar,
  microscope,
  laptop,
  mail,
  clock,
}

class _MissionObjectData {
  final _MissionObjectType type;
  final String title;
  final String subtitle;
  final Color accent;

  const _MissionObjectData(this.type, this.title, this.subtitle, this.accent);
}

_MissionObjectData _objectFor(LearningMission mission) {
  return switch (mission.id) {
    'sekolah-1' => const _MissionObjectData(
      _MissionObjectType.thermometer,
      'Sedang demam',
      'Perlu izin tidak masuk',
      Color(0xFFFF7A6B),
    ),
    'sekolah-2' => const _MissionObjectData(
      _MissionObjectType.calendar,
      'Jadwal remedial',
      'Tanyakan waktu dengan sopan',
      AppColors.indigo,
    ),
    'sekolah-3' => const _MissionObjectData(
      _MissionObjectType.microscope,
      'Praktikum biologi',
      'Pinjam mikroskop',
      AppColors.success,
    ),
    'profesional-1' => const _MissionObjectData(
      _MissionObjectType.laptop,
      'Email magang',
      'Buat pembuka yang formal',
      AppColors.purple,
    ),
    'profesional-2' => const _MissionObjectData(
      _MissionObjectType.mail,
      'Undangan wawancara',
      'Konfirmasi waktu dan tempat',
      AppColors.indigo,
    ),
    _ => const _MissionObjectData(
      _MissionObjectType.clock,
      'Janji dokter',
      'Sampaikan izin terlambat',
      Color(0xFFD94865),
    ),
  };
}

class _MissionObjectPainter extends CustomPainter {
  final _MissionObjectType type;
  final Color accent;

  const _MissionObjectPainter(this.type, {required this.accent});

  Color get dark => Color.lerp(accent, AppColors.ink, 0.45)!;
  Color get soft => Color.lerp(accent, Colors.white, 0.72)!;

  RRect rr(double x, double y, double w, double h, double radius) =>
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, w, h),
        Radius.circular(radius),
      );

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 100, size.height / 100);
    canvas.drawRRect(rr(4, 4, 92, 92, 26), Paint()..color = soft);
    switch (type) {
      case _MissionObjectType.thermometer:
        _thermometer(canvas);
        break;
      case _MissionObjectType.calendar:
        _calendar(canvas);
        break;
      case _MissionObjectType.microscope:
        _microscope(canvas);
        break;
      case _MissionObjectType.laptop:
        _laptop(canvas);
        break;
      case _MissionObjectType.mail:
        _mail(canvas);
        break;
      case _MissionObjectType.clock:
        _clock(canvas);
        break;
    }
    canvas.restore();
  }

  void _thermometer(Canvas canvas) {
    canvas.drawRRect(rr(43, 18, 14, 55, 7), Paint()..color = Colors.white);
    canvas.drawRRect(rr(47, 29, 6, 44, 3), Paint()..color = accent);
    canvas.drawCircle(const Offset(50, 75), 15, Paint()..color = accent);
    canvas.drawCircle(const Offset(45, 70), 4, Paint()..color = Colors.white54);
  }

  void _calendar(Canvas canvas) {
    canvas.drawRRect(rr(18, 24, 64, 58, 12), Paint()..color = Colors.white);
    canvas.drawRRect(rr(18, 24, 64, 18, 10), Paint()..color = accent);
    for (final x in [31.0, 50.0, 69.0]) {
      canvas.drawCircle(Offset(x, 54), 5, Paint()..color = soft);
      canvas.drawCircle(
        Offset(x, 69),
        5,
        Paint()..color = x == 50 ? accent : soft,
      );
    }
  }

  void _microscope(Canvas canvas) {
    final arm = Paint()
      ..color = accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 11
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(45, 22), const Offset(58, 48), arm);
    canvas.drawArc(const Rect.fromLTWH(31, 37, 42, 40), -1.1, 2.3, false, arm);
    canvas.drawRRect(rr(23, 75, 58, 11, 5), Paint()..color = dark);
    canvas.drawRRect(rr(30, 57, 40, 8, 4), Paint()..color = dark);
    canvas.drawCircle(const Offset(63, 42), 8, Paint()..color = Colors.white);
  }

  void _laptop(Canvas canvas) {
    canvas.drawRRect(rr(18, 22, 64, 48, 9), Paint()..color = dark);
    canvas.drawRRect(rr(24, 28, 52, 34, 5), Paint()..color = Colors.white);
    canvas.drawCircle(const Offset(50, 45), 8, Paint()..color = accent);
    canvas.drawRRect(rr(10, 72, 80, 10, 5), Paint()..color = accent);
  }

  void _mail(Canvas canvas) {
    canvas.drawRRect(rr(14, 25, 72, 54, 12), Paint()..color = Colors.white);
    final envelope = Path()
      ..moveTo(17, 32)
      ..lineTo(50, 57)
      ..lineTo(83, 32);
    canvas.drawPath(
      envelope,
      Paint()
        ..color = accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawCircle(const Offset(77, 24), 12, Paint()..color = accent);
  }

  void _clock(Canvas canvas) {
    canvas.drawCircle(const Offset(50, 52), 32, Paint()..color = Colors.white);
    canvas.drawCircle(
      const Offset(50, 52),
      28,
      Paint()
        ..color = accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7,
    );
    canvas.drawLine(
      const Offset(50, 52),
      const Offset(50, 35),
      Paint()
        ..color = dark
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      const Offset(50, 52),
      const Offset(66, 60),
      Paint()
        ..color = dark
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _MissionObjectPainter oldDelegate) =>
      oldDelegate.type != type || oldDelegate.accent != accent;
}
