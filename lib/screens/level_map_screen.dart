import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wicara_application_1/models/bilik.dart';
import 'package:wicara_application_1/services/api_service.dart';
import 'package:wicara_application_1/screens/level_screen.dart';

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
      // 1. Fetch levels from assets
      final String jsonContent = await DefaultAssetBundle.of(context)
          .loadString('assets/data/bilik-levels.json');
      final Map<String, dynamic> decoded = jsonDecode(jsonContent);
      final List levelList = decoded[widget.bilik.id] ?? [];
      
      _levels = levelList.map((x) => BilikLevel.fromJson(x)).toList();

      // 2. Fetch progress from API
      _progress = await ApiService.fetchProgress();
    } catch (e) {
      print('Error loading level map: $e');
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

  @override
  Widget build(BuildContext context) {
    final Color brandColor = _parseColor(widget.bilik.color);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          widget.bilik.title,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            fontSize: 18,
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
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Header Info Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [brandColor, brandColor.withOpacity(0.8)],
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
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              widget.bilik.icon,
                              style: const TextStyle(fontSize: 32),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.auto_awesome, color: Colors.white70, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    'BILIK LATIHAN',
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white70,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.bilik.title,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 20,
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

                  // Levels list
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _levels.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final level = _levels[index];
                      final status = _getStatusFor(level.id);
                      final locked = status == LevelStatus.locked;
                      final completed = status == LevelStatus.completed;

                      return InkWell(
                        onTap: locked
                            ? null
                            : () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LevelScreen(
                                      level: level,
                                      bilik: widget.bilik,
                                    ),
                                  ),
                                );
                                _refreshProgress();
                              },
                        borderRadius: BorderRadius.circular(20),
                        child: Ink(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: locked ? const Color(0xFFF1F5F9) : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: locked
                                  ? const Color(0xFFE2E8F0)
                                  : const Color(0xFFE5E7EB),
                              width: 1.5,
                            ),
                            boxShadow: locked
                                ? null
                                : [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.015),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                          ),
                          child: Row(
                            children: [
                              // Status Indicator
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: locked
                                      ? const Color(0xFFCBD5E1)
                                      : completed
                                          ? const Color(0xFF10B981) // Green 500
                                          : brandColor,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: locked
                                      ? null
                                      : [
                                          BoxShadow(
                                            color: (completed
                                                    ? const Color(0xFF10B981)
                                                    : brandColor)
                                                .withOpacity(0.2),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                ),
                                child: Center(
                                  child: Icon(
                                    completed
                                        ? Icons.check
                                        : locked
                                            ? Icons.lock
                                            : Icons.play_arrow,
                                    color: Colors.white,
                                    size: completed
                                        ? 22
                                        : locked
                                            ? 18
                                            : 22,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'LEVEL ${level.id}',
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF94A3B8),
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      level.title,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: locked
                                            ? const Color(0xFF94A3B8)
                                            : const Color(0xFF0F172A),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              if (!locked)
                                const Icon(
                                  Icons.chevron_right,
                                  color: Color(0xFF94A3B8),
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
