import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wicara_application_1/models/bilik.dart';
import 'package:wicara_application_1/services/api_service.dart';
import 'package:wicara_application_1/services/session_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _studentId = '';
  Map<String, String> _avatar = {'emoji': 'face', 'color': '#3B82F6'};
  List<StudentProgress> _progress = [];
  List<Bilik> _biliks = [];
  Map<String, int> _levelCounts = {};
  bool _isLoading = true;

  final List<Map<String, dynamic>> _badges = [
    { 'name': 'Berani Mencoba', 'icon': Icons.local_florist_rounded, 'earned': true, 'desc': 'Menyelesaikan misi pertama', 'bg': Color(0xFFEAF8F1), 'border': Color(0xFF1F9D70), 'color': Color(0xFF1F9D70) },
    { 'name': 'Penyusun Kata', 'icon': Icons.history_edu_rounded, 'earned': true, 'desc': 'Menyusun 5 kalimat', 'bg': Color(0xFFFFF9E6), 'border': Color(0xFFFFD36A), 'color': Color(0xFFE5A91D) },
    { 'name': 'Pesan Sudah Jelas', 'icon': Icons.comment_rounded, 'earned': false, 'desc': 'Skor formalitas 80%+', 'bg': Color(0xFFF9FAFB), 'border': Color(0xFFE4E7EC), 'color': Color(0xFF98A2B3) },
    { 'name': 'Komunikasi Siap', 'icon': Icons.rocket_launch_rounded, 'earned': false, 'desc': 'Selesaikan Bilik Profesional', 'bg': Color(0xFFF9FAFB), 'border': Color(0xFFE4E7EC), 'color': Color(0xFF98A2B3) },
    { 'name': 'Penjelajah Sekolah', 'icon': Icons.school_rounded, 'earned': false, 'desc': 'Semua misi Bilik Sekolah', 'bg': Color(0xFFF9FAFB), 'border': Color(0xFFE4E7EC), 'color': Color(0xFF98A2B3) },
    { 'name': 'Siap Magang', 'icon': Icons.work_rounded, 'earned': false, 'desc': 'Semua misi Bilik Profesional', 'bg': Color(0xFFF9FAFB), 'border': Color(0xFFE4E7EC), 'color': Color(0xFF98A2B3) },
  ];

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      final avatarData = await SessionService.getAvatar();
      final id = await SessionService.getStudentId();
      if (avatarData != null) _avatar = avatarData;
      _studentId = id ?? '';

      final String bilikContent = await rootBundle.loadString('assets/data/bilik.json');
      final List decodedBiliks = jsonDecode(bilikContent);
      _biliks = decodedBiliks.map((x) => Bilik.fromJson(x)).toList();

      final String levelContent = await rootBundle.loadString('assets/data/bilik-levels.json');
      final Map<String, dynamic> decodedLevels = jsonDecode(levelContent);
      _levelCounts = decodedLevels.map(
        (key, value) => MapEntry(key, value is List ? value.length : 0),
      );

      _progress = await ApiService.fetchProgress();
    } catch (e) {
      debugPrint('Error loading profile: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Color _parseColor(String hex) {
    var value = hex.replaceAll('#', '');
    if (value.length == 6) value = 'FF$value';
    return Color(int.parse(value, radix: 16));
  }

  int _getCompletedCount(String bilikId) {
    return _progress.where((p) => p.bilikId == bilikId && p.status == 'completed').length;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final totalCompleted = _biliks.fold(0, (sum, b) => sum + _getCompletedCount(b.id));
    final level = (totalCompleted / 3).floor() + 1;
    final xp = totalCompleted * 50;
    final int nextLevelXp = level * 150;
    final double progressPct = (xp / nextLevelXp).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              color: const Color(0xFF4C5FD7),
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.14),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
                            ),
                            child: const Center(
                              child: Icon(Icons.person_rounded, size: 30, color: Colors.white),
                            ),
                          ),
                          Positioned(
                            bottom: -6,
                            right: -6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6C4FD3),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'L$level',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Profil belajar',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white70,
                              ),
                            ),
                            Text(
                              _studentId,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.local_fire_department_rounded, color: Color(0xFFFFD36A), size: 12),
                                  const SizedBox(width: 4),
                                  Text(
                                    '2 hari aktif',
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // XP Gauge Bar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Level $level · $xp / $nextLevelXp XP',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            '${(progressPct * 100).round()}%',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          minHeight: 8,
                          value: progressPct,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFD36A)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content Body
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Badges Sticker grid
                  Text(
                    'Koleksi Lencana',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF24304A),
                    ),
                  ),
                  Text(
                    'Tampilkan seperti sticker yang bisa dikoleksi',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF667085),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: _badges.length,
                    itemBuilder: (context, index) {
                      final badge = _badges[index];
                      final earned = badge['earned'] as bool;                      final badgeBg = earned ? (badge['bg'] as Color) : const Color(0xFFF7F8FC);
                      final badgeBorder = earned ? (badge['border'] as Color) : const Color(0xFFDDE2F0);
                      final badgeIconColor = earned ? (badge['color'] as Color) : const Color(0xFF98A2B3);

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: badgeBorder,
                            width: earned ? 1.5 : 1,
                          ),
                          boxShadow: earned
                              ? [
                                  BoxShadow(
                                    color: (badge['border'] as Color).withOpacity(0.12),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              badge['icon'] as IconData,
                              size: 30,
                              color: badgeIconColor,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              badge['name'] as String,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: earned ? const Color(0xFF24304A) : const Color(0xFF98A2B3),
                              ),
                            ),
                            const SizedBox(height: 6),
                            if (earned)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDDF8EA),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFF1B7A4E).withOpacity(0.15)),
                                ),
                                child: Text(
                                  '✓ Diperoleh',
                                  style: GoogleFonts.inter(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF1B7A4E),
                                  ),
                                ),
                              )
                            else
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                child: Text(
                                  badge['desc'] as String,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF98A2B3),
                                    height: 1.25,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 28),

                  // Room Progress indicators list
                  Text(
                    'Progress Bilik',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF24304A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._biliks.map((bilik) {
                    final completed = _getCompletedCount(bilik.id);
                    final total = _levelCounts[bilik.id] ?? 0;
                    final pct = total == 0 ? 0.0 : completed / total;
                    final brandColor = _parseColor(bilik.color);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE4E7EC)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    bilik.id == 'akademik' ? Icons.school_rounded : Icons.business_center_rounded,
                                    color: brandColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    bilik.title,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF1F2858),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '$completed / $total',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w800,
                                  color: brandColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              minHeight: 6,
                              value: pct,
                              backgroundColor: const Color(0xFFE2E8F0),
                              valueColor: AlwaysStoppedAnimation<Color>(brandColor),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
