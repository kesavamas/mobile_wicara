import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wicara_application_1/core/theme/app_colors.dart';
import 'package:wicara_application_1/features/case_map/widgets/mode_selection_sheet.dart';
import 'package:wicara_application_1/features/dictionary/screens/color_dictionary_screen.dart';
import 'package:wicara_application_1/features/guided_mode/screens/revision3_guided_vn_screen.dart';
import 'package:wicara_application_1/features/independent_mode/screens/independent_simulation_screen.dart';
import 'package:wicara_application_1/models/bilik.dart';
import 'package:wicara_application_1/models/revision3_content.dart';
import 'package:wicara_application_1/services/api_service.dart';

class CaseMapScreen extends StatefulWidget {
  final LearningBilik bilik;
  final List<LearningMission> missions;

  const CaseMapScreen({super.key, required this.bilik, required this.missions});

  @override
  State<CaseMapScreen> createState() => _CaseMapScreenState();
}

class _CaseMapScreenState extends State<CaseMapScreen> {
  List<StudentProgress> _progress = const [];
  Map<int, int> _bestStars = const {};
  bool _loading = true;

  Color get _brand =>
      widget.bilik.isSchool ? AppColors.indigo : AppColors.purple;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);
    try {
      final results = await Future.wait([
        ApiService.fetchProgress(),
        Future.wait(
          widget.missions.map(
            (mission) =>
                ApiService.getBestStars(widget.bilik.progressId, mission.order),
          ),
        ),
      ]);
      if (!mounted) return;
      final stars = results[1] as List<int>;
      setState(() {
        _progress = results[0] as List<StudentProgress>;
        _bestStars = {
          for (var index = 0; index < widget.missions.length; index++)
            widget.missions[index].order: stars[index],
        };
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool _isCompleted(int order) => _progress.any(
    (item) =>
        item.bilikId == widget.bilik.progressId &&
        item.levelId == order &&
        item.status == 'completed',
  );

  bool _isUnlocked(LearningMission mission) {
    if (mission.order == 1) return true;
    return _isCompleted(mission.order - 1);
  }

  Future<void> _openMission(LearningMission mission) async {
    if (!_isUnlocked(mission)) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: const Text(
              'Tuntaskan kasus sebelumnya untuk membuka ini.',
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        );
      return;
    }

    final completed = _isCompleted(mission.order);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => ModeSelectionSheet(
        mission: mission,
        independentUnlocked: completed && (_bestStars[mission.order] ?? 0) == 3,
        guidedCompleted: completed,
        bestStars: _bestStars[mission.order] ?? 0,
        onStartGuided: () {
          Navigator.pop(sheetContext);
          Navigator.of(context)
              .push(
                MaterialPageRoute<void>(
                  builder: (_) => Revision3GuidedVnScreen(
                    bilik: widget.bilik,
                    mission: mission,
                  ),
                ),
              )
              .then((_) => _load());
        },
        onStartIndependent: () {
          Navigator.pop(sheetContext);
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => IndependentSimulationScreen(
                bilik: widget.bilik,
                mission: mission,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final completed = widget.missions
        .where((m) => _isCompleted(m.order))
        .length;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
                  child: Row(
                    children: [
                      _RoundButton(
                        icon: Icons.arrow_back_rounded,
                        onTap: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.bilik.title,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: AppColors.ink,
                              ),
                            ),
                            Text(
                              widget.bilik.subtitle,
                              style: GoogleFonts.nunitoSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.text2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _RoundButton(
                        icon: Icons.menu_book_outlined,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const ColorDictionaryScreen(
                              showBackButton: true,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _loading
                      ? Center(child: CircularProgressIndicator(color: _brand))
                      : RefreshIndicator(
                          onRefresh: _load,
                          color: _brand,
                          child: ListView(
                            padding: const EdgeInsets.fromLTRB(18, 4, 18, 28),
                            children: [
                              Container(
                                height: 520,
                                decoration: BoxDecoration(
                                  color: widget.bilik.isSchool
                                      ? AppColors.softBlue
                                      : AppColors.softPurple,
                                  borderRadius: BorderRadius.circular(26),
                                  border: Border.all(color: AppColors.line),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x120F172A),
                                      blurRadius: 22,
                                      offset: Offset(0, 9),
                                    ),
                                  ],
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    final points = <Offset>[
                                      Offset(
                                        constraints.maxWidth * 0.29,
                                        constraints.maxHeight * 0.79,
                                      ),
                                      Offset(
                                        constraints.maxWidth * 0.70,
                                        constraints.maxHeight * 0.50,
                                      ),
                                      Offset(
                                        constraints.maxWidth * 0.29,
                                        constraints.maxHeight * 0.20,
                                      ),
                                    ];
                                    return Stack(
                                      children: [
                                        Positioned.fill(
                                          child: CustomPaint(
                                            painter: _JourneyPainter(
                                              points: points,
                                              completed: completed,
                                              isSchool: widget.bilik.isSchool,
                                            ),
                                          ),
                                        ),
                                        ...List.generate(
                                          widget.missions.length,
                                          (index) {
                                            final mission =
                                                widget.missions[index];
                                            return _JourneyNode(
                                              mission: mission,
                                              center: points[index],
                                              labelOnLeft: index == 1,
                                              completed: _isCompleted(
                                                mission.order,
                                              ),
                                              unlocked: _isUnlocked(mission),
                                              stars:
                                                  _bestStars[mission.order] ??
                                                  0,
                                              brand: _brand,
                                              brandDark: widget.bilik.isSchool
                                                  ? AppColors.indigoDark
                                                  : AppColors.purpleDark,
                                              mapWidth: constraints.maxWidth,
                                              onTap: () =>
                                                  _openMission(mission),
                                            );
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 14),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppColors.line),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x120F172A),
                                      blurRadius: 10,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '$completed dari ${widget.missions.length} kasus selesai',
                                          style: GoogleFonts.nunitoSans(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w900,
                                            color: AppColors.ink,
                                          ),
                                        ),
                                        Text(
                                          'Perjalananmu',
                                          style: GoogleFonts.nunitoSans(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.text2,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(99),
                                      child: LinearProgressIndicator(
                                        minHeight: 8,
                                        value: widget.missions.isEmpty
                                            ? 0
                                            : completed /
                                                  widget.missions.length,
                                        backgroundColor: const Color(
                                          0xFFE9ECF4,
                                        ),
                                        valueColor: AlwaysStoppedAnimation(
                                          _brand,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(17),
        side: const BorderSide(color: AppColors.line),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: SizedBox(
          width: 45,
          height: 45,
          child: Icon(icon, size: 20, color: AppColors.ink),
        ),
      ),
    );
  }
}

class _JourneyNode extends StatelessWidget {
  final LearningMission mission;
  final Offset center;
  final bool labelOnLeft;
  final bool completed;
  final bool unlocked;
  final int stars;
  final Color brand;
  final Color brandDark;
  final double mapWidth;
  final VoidCallback onTap;

  const _JourneyNode({
    required this.mission,
    required this.center,
    required this.labelOnLeft,
    required this.completed,
    required this.unlocked,
    required this.stars,
    required this.brand,
    required this.brandDark,
    required this.mapWidth,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const nodeSize = 64.0;
    const labelWidth = 132.0;
    final rawLeft = labelOnLeft
        ? center.dx - nodeSize / 2 - labelWidth - 11
        : center.dx + nodeSize / 2 + 11;
    final labelLeft = rawLeft.clamp(10.0, mapWidth - labelWidth - 10);

    // Gaya desain: node "chunky" dengan bottom-shadow solid warna gelap,
    // bukan ring putih + drop shadow lembut.
    final Color fill = completed
        ? AppColors.success
        : unlocked
        ? brand
        : const Color(0xFFEEF0F5);
    final Color bottomShadow = completed
        ? const Color(0xFF147A54)
        : unlocked
        ? brandDark
        : const Color(0xFFCDD2DE);

    return Stack(
      children: [
        Positioned(
          left: center.dx - nodeSize / 2,
          top: center.dy - nodeSize / 2,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              width: nodeSize,
              height: nodeSize,
              decoration: BoxDecoration(
                color: fill,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: bottomShadow, offset: const Offset(0, 6)),
                ],
              ),
              child: Icon(
                completed
                    ? Icons.check_rounded
                    : unlocked
                    ? Icons.chat_bubble_outline_rounded
                    : Icons.lock_rounded,
                color: unlocked || completed
                    ? Colors.white
                    : const Color(0xFF69738F),
                size: 26,
              ),
            ),
          ),
        ),
        Positioned(
          left: labelLeft,
          top: center.dy - 34,
          width: labelWidth,
          child: GestureDetector(
            onTap: onTap,
            child: Column(
              crossAxisAlignment: labelOnLeft
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  'Kasus ${mission.order}',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: AppColors.muted,
                  ),
                ),
                Text(
                  mission.shortTitle,
                  textAlign: labelOnLeft ? TextAlign.right : TextAlign.left,
                  maxLines: 2,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    height: 1.18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                Text.rich(
                  TextSpan(
                    text: completed
                        ? 'Selesai'
                        : unlocked
                        ? 'Siap dimainkan'
                        : 'Selesaikan kasus sebelumnya',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: completed
                          ? AppColors.success
                          : unlocked
                          ? brand
                          : AppColors.muted,
                    ),
                    children: [
                      if (completed && stars > 0)
                        TextSpan(
                          text: ' ${'★' * stars}',
                          style: const TextStyle(
                            fontSize: 9,
                            color: Color(0xFFFFD36A),
                          ),
                        ),
                    ],
                  ),
                  maxLines: 2,
                  textAlign: labelOnLeft ? TextAlign.right : TextAlign.left,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _JourneyPainter extends CustomPainter {
  final List<Offset> points;
  final int completed;
  final bool isSchool;

  const _JourneyPainter({
    required this.points,
    required this.completed,
    required this.isSchool,
  });

  /// Gambar path dengan pola putus-putus (untuk segmen terkunci).
  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const dash = 6.0;
    const gap = 12.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dash),
          paint,
        );
        distance += dash + gap;
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()..style = PaintingStyle.fill;

    if (isSchool) {
      // Dunia sekolah: gedung + pohon + matahari + sticky note (low-opacity).
      fill.color = const Color(0xFF3445AC).withValues(alpha: 0.14);
      final bx = size.width - 100;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(bx, 62, 75, 70),
          const Radius.circular(5),
        ),
        fill,
      );
      final roof = Path()
        ..moveTo(bx, 62)
        ..lineTo(bx + 75, 62)
        ..lineTo(bx + 37, 30)
        ..close();
      canvas.drawPath(
        roof,
        fill..color = AppColors.indigo.withValues(alpha: 0.14),
      );
      fill.color = Colors.white.withValues(alpha: 0.5);
      for (var i = 0; i < 3; i++) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(bx + 10 + i * 20, 82, 13, 13),
            const Radius.circular(2),
          ),
          fill,
        );
      }
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(bx + 24, 107, 22, 24),
          const Radius.circular(3),
        ),
        fill,
      );
      // Matahari
      canvas.drawCircle(
        const Offset(40, 34),
        14,
        fill..color = const Color(0xFFFFD36A).withValues(alpha: 0.22),
      );
      // Pohon kiri bawah
      canvas.drawCircle(
        Offset(34, size.height - 62),
        22,
        fill..color = AppColors.success.withValues(alpha: 0.18),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(30, size.height - 44, 10, 18),
          const Radius.circular(5),
        ),
        fill..color = const Color(0xFF1B7A4E).withValues(alpha: 0.18),
      );
      // Sticky note miring
      canvas.save();
      canvas.translate(size.width - 60, size.height * 0.52);
      canvas.rotate(0.14);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-18, -18, 36, 36),
          const Radius.circular(5),
        ),
        fill..color = const Color(0xFFFFD36A).withValues(alpha: 0.2),
      );
      canvas.restore();
    } else {
      // Dunia profesional: gedung kantor + kopi + kalender (low-opacity).
      fill.color = AppColors.purple.withValues(alpha: 0.15);
      final bx = size.width - 96;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(bx, 34, 72, 118),
          const Radius.circular(6),
        ),
        fill,
      );
      fill.color = Colors.white.withValues(alpha: 0.55);
      for (var row = 0; row < 5; row++) {
        for (var col = 0; col < 3; col++) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(bx + 8 + col * 19, 44 + row * 18, 12, 11),
              const Radius.circular(2),
            ),
            fill,
          );
        }
      }
      // Cangkir kopi kiri
      fill.color = AppColors.danger.withValues(alpha: 0.18);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(24, size.height * 0.42, 28, 34),
          const Radius.circular(6),
        ),
        fill,
      );
      final handle = Path()
        ..moveTo(52, size.height * 0.42 + 10)
        ..quadraticBezierTo(
          60,
          size.height * 0.42 + 10,
          60,
          size.height * 0.42 + 18,
        )
        ..quadraticBezierTo(
          60,
          size.height * 0.42 + 26,
          52,
          size.height * 0.42 + 26,
        );
      canvas.drawPath(
        handle,
        Paint()
          ..color = AppColors.danger.withValues(alpha: 0.18)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5,
      );
      // Kalender kiri bawah
      fill.color = AppColors.purple.withValues(alpha: 0.14);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(26, size.height - 70, 44, 44),
          const Radius.circular(7),
        ),
        fill,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(26, size.height - 70, 44, 14),
          const Radius.circular(7),
        ),
        fill..color = AppColors.purpleDark.withValues(alpha: 0.14),
      );
    }

    // Jalur: dasar netral; selesai = hijau solid; terkunci = putus-putus.
    final base = Paint()
      ..color = const Color(0xFFE4E7EF)
      ..strokeWidth = 17
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final done = Paint()
      ..color = const Color(0xFF6FD1A7)
      ..strokeWidth = 17
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final locked = Paint()
      ..color = (isSchool ? const Color(0xFFCDD6FF) : const Color(0xFFD8CCFA))
      ..strokeWidth = 17
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (var index = 0; index < points.length - 1; index++) {
      final start = points[index];
      final end = points[index + 1];
      final bend = index.isEven ? size.width * 0.72 : size.width * 0.28;
      final path = Path()..moveTo(start.dx, start.dy);
      path.cubicTo(bend, start.dy - 58, bend, end.dy + 58, end.dx, end.dy);
      canvas.drawPath(path, base);
      if (index < completed) {
        canvas.drawPath(path, done);
      } else {
        _drawDashedPath(canvas, path, locked);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _JourneyPainter oldDelegate) =>
      oldDelegate.completed != completed || oldDelegate.isSchool != isSchool;
}
