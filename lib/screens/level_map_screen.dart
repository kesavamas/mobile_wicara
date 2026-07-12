import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wicara_application_1/models/bilik.dart';
import 'package:wicara_application_1/services/api_service.dart';
import 'package:wicara_application_1/widgets/mode_selection_modal.dart';
import 'package:wicara_application_1/screens/guided_vn_screen.dart';
import 'package:wicara_application_1/screens/independent_mode_screen.dart';

enum LevelStatus { locked, unlocked, completed }

class LevelMapScreen extends StatefulWidget {
  final Bilik bilik;
  final int totalLevels;

  const LevelMapScreen({
    Key? key,
    required this.bilik,
    required this.totalLevels,
  }) : super(key: key);

  @override
  _LevelMapScreenState createState() => _LevelMapScreenState();
}

class _LevelMapScreenState extends State<LevelMapScreen> {
  List<BilikLevel> _levels = [];
  List<StudentProgress> _progress = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLevelsAndProgress();
  }

  Future<void> _loadLevelsAndProgress() async {
    try {
      final String jsonContent = await DefaultAssetBundle.of(context)
          .loadString('assets/data/bilik-levels.json');
      final Map<String, dynamic> decoded = jsonDecode(jsonContent);
      final List levelList = decoded[widget.bilik.id] ?? [];
      
      _levels = levelList.map((x) => BilikLevel.fromJson(x)).toList();
      _progress = await ApiService.fetchProgress();
    } catch (e) {
      debugPrint('Error loading level map: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshProgress() async {
    final freshProgress = await ApiService.fetchProgress();
    if (mounted) {
      setState(() {
        _progress = freshProgress;
      });
    }
  }

  LevelStatus _getStatusFor(int levelId) {
    final isCompleted = _progress.any((p) =>
        p.bilikId == widget.bilik.id &&
        p.levelId == levelId &&
        p.status == 'completed');
    if (isCompleted) return LevelStatus.completed;

    if (levelId == 1) return LevelStatus.unlocked;

    final isPrevCompleted = _progress.any((p) =>
        p.bilikId == widget.bilik.id &&
        p.levelId == levelId - 1 &&
        p.status == 'completed');
    return isPrevCompleted ? LevelStatus.unlocked : LevelStatus.locked;
  }

  Color _parseColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }

  void _showModeModal(BilikLevel level, bool isCompleted) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ModeSelectionModal(
          bilik: widget.bilik,
          level: level,
          isCompleted: isCompleted,
          onStartGuided: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GuidedVnScreen(
                  bilik: widget.bilik,
                  level: level,
                ),
              ),
            ).then((_) => _refreshProgress());
          },
          onStartIndependent: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => IndependentModeScreen(
                  bilik: widget.bilik,
                  level: level,
                ),
              ),
            ).then((_) => _refreshProgress());
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color brandColor = _parseColor(widget.bilik.color);
    final isSchool = widget.bilik.id == 'akademik';
    final int completedCount = _progress.where((p) => p.bilikId == widget.bilik.id && p.status == 'completed').length;
    final double completionPct = widget.totalLevels == 0 ? 0.0 : completedCount / widget.totalLevels;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          widget.bilik.title,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Banner Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [brandColor, brandColor.withOpacity(0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: brandColor.withOpacity(0.2),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              widget.bilik.icon,
                              style: const TextStyle(fontSize: 26),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'BILIK LATIHAN',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white70,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.bilik.title,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.bilik.description,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.85),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Map World Container with custom background
                  Container(
                    height: 580,
                    decoration: BoxDecoration(
                      color: isSchool ? const Color(0xFFEEF3FF) : const Color(0xFFF3EFFF),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: const Color(0xFFDDE2F0)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF24304A).withOpacity(0.08),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final double w = constraints.maxWidth;
                        final double h = constraints.maxHeight;
                        final int total = _levels.length;

                        // Center of the circular node (56x56)
                        Offset getNodeCenter(int index) {
                          if (total <= 1) {
                            return Offset(w / 2, h / 2);
                          }
                          // y-spacing: 50 from top, 60 from bottom
                          double y = h - 60 - (index * (h - 110) / (total - 1));
                          double x;
                          if (index % 2 == 0) {
                            x = 24.0 + 28.0;
                          } else {
                            // Leave 210px for node + text details on the right
                            x = w - 210.0 + 28.0;
                          }
                          return Offset(x, y);
                        }

                        final points = List.generate(total, (index) => getNodeCenter(index));

                        return Stack(
                          children: [
                            // Custom Paint winding paths
                            Positioned.fill(
                              child: CustomPaint(
                                painter: _WindingPathPainter(
                                  points: points,
                                  completedCount: completedCount,
                                  brandColor: brandColor,
                                ),
                              ),
                            ),

                            // Absolute positions of level nodes
                            ...List.generate(total, (index) {
                              final level = _levels[index];
                              final status = _getStatusFor(level.id);
                              final open = status != LevelStatus.locked;
                              final completed = status == LevelStatus.completed;

                              final center = points[index];
                              final left = center.dx - 28.0;
                              final top = center.dy - 28.0;

                              return Positioned(
                                left: left,
                                top: top,
                                child: _buildMapNode(
                                  level,
                                  open,
                                  completed,
                                  brandColor,
                                ),
                              );
                            }),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Progress Bar Strip Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFDDE2F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$completedCount dari ${widget.totalLevels} kasus selesai',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF1F2858),
                              ),
                            ),
                            Text(
                              'Perjalananmu',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF5D6785),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            minHeight: 8,
                            value: completionPct,
                            backgroundColor: const Color(0xFFE8EBF4),
                            valueColor: AlwaysStoppedAnimation<Color>(brandColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildMapNode(BilikLevel level, bool open, bool completed, Color brandColor) {
    return GestureDetector(
      onTap: () {
        if (open) {
          _showModeModal(level, completed);
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: open ? brandColor : const Color(0xFFEEF0F5),
              shape: BoxShape.circle,
              border: Border.all(
                color: open ? brandColor.withOpacity(0.2) : const Color(0xFFCDD2DE),
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: open ? brandColor.withOpacity(0.3) : Colors.black12,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              open ? (completed ? Icons.check_circle_rounded : Icons.play_arrow_rounded) : Icons.lock_rounded,
              color: open ? Colors.white : const Color(0xFF8490AA),
              size: 28,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 120,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Kasus ${level.id}',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF8490AA),
                  ),
                ),
                Text(
                  level.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1F2858),
                  ),
                ),
                Text(
                  completed ? 'Selesai' : (open ? 'Siap dimainkan' : 'Terkunci'),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: completed ? const Color(0xFF1F9D70) : (open ? brandColor : const Color(0xFF8490AA)),
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

class _WindingPathPainter extends CustomPainter {
  final List<Offset> points;
  final int completedCount;
  final Color brandColor;

  _WindingPathPainter({
    required this.points,
    required this.completedCount,
    required this.brandColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final Paint bgPathPaint = Paint()
      ..color = const Color(0xFFE4E7EF)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Paint activePathPaint = Paint()
      ..color = const Color(0xFF6FD1A7)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Paint lockedPathPaint = Paint()
      ..color = const Color(0xFFCDD6FF)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw lines between nodes
    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];

      // Draw curve using quadratic or bezier
      final Path path = Path()..moveTo(p1.dx, p1.dy);

      // Compute control points for custom winding curves
      final controlX = (p1.dx + p2.dx) / 2 + (i % 2 == 0 ? 60 : -60);
      final controlY = (p1.dy + p2.dy) / 2;

      path.quadraticBezierTo(controlX, controlY, p2.dx, p2.dy);

      // Draw base
      canvas.drawPath(path, bgPathPaint);

      // Highlight active segments based on completion
      if (i < completedCount) {
        canvas.drawPath(path, activePathPaint);
      } else {
        canvas.drawPath(path, lockedPathPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
