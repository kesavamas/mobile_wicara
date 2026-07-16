import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wicara_application_1/core/theme/app_colors.dart';
import 'package:wicara_application_1/features/shared/widgets/fun_ui_components.dart';
import 'package:wicara_application_1/features/shared/widgets/wicara_illustration_icon.dart';
import 'package:wicara_application_1/models/bilik.dart';
import 'package:wicara_application_1/screens/login_screen.dart';
import 'package:wicara_application_1/services/api_service.dart';
import 'package:wicara_application_1/services/session_service.dart';

class ProfileTabScreen extends StatefulWidget {
  final VoidCallback? onOpenBilik;
  final VoidCallback? onOpenDictionary;

  const ProfileTabScreen({super.key, this.onOpenBilik, this.onOpenDictionary});

  @override
  State<ProfileTabScreen> createState() => _ProfileTabScreenState();
}

class _ProfileTabScreenState extends State<ProfileTabScreen> {
  String _studentId = 'Siswa WICARA';
  bool _isDemo = false;
  bool _loading = true;
  bool _offline = false;
  Map<String, int> _bestStars = const {};
  Map<String, int> _completedAt = const {};
  List<StudentProgress> _progress = const [];
  int _totalStars = 0;

  static const _titles = <String, List<String>>{
    'akademik': [
      'Izin Sakit ke Wali Kelas',
      'Bertanya Jadwal Remedial',
      'Meminjam Alat ke Petugas Lab',
    ],
    'profesional': [
      'Melamar Magang',
      'Membalas Pesan HRD',
      'Izin ke Pembimbing Magang',
    ],
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);
    final studentId = await SessionService.getStudentId();
    final isDemo = await SessionService.isDemoMode();
    final progress = await ApiService.fetchProgress();
    final prefs = await SharedPreferences.getInstance();
    var stars = 0;
    final bestStars = <String, int>{};
    final completedAt = <String, int>{};
    for (final bilikId in _titles.keys) {
      for (var level = 1; level <= 3; level++) {
        final value =
            prefs.getInt('stars_${bilikId}_$level') ??
            prefs.getInt('demo_stars_${bilikId}_$level') ??
            0;
        stars += value;
        bestStars['${bilikId}_$level'] = value;
        final timestamp = prefs.getInt('completed_at_${bilikId}_$level');
        if (timestamp != null) {
          completedAt['${bilikId}_$level'] = timestamp;
        }
      }
    }
    if (!mounted) return;
    setState(() {
      _studentId = studentId ?? 'Siswa WICARA';
      _isDemo = isDemo;
      _progress = progress;
      _offline = ApiService.lastProgressUsedCache;
      _totalStars = stars;
      _bestStars = bestStars;
      _completedAt = completedAt;
      _loading = false;
    });
  }

  int _completedFor(String bilikId) => _progress
      .where((item) => item.bilikId == bilikId && item.status == 'completed')
      .length;

  int get _completed =>
      _progress.where((item) => item.status == 'completed').length;

  int get _xp =>
      _completedFor('akademik') * 50 + _completedFor('profesional') * 75;

  int get _level => 1 + (_xp ~/ 150);

  int get _unlockedMissions {
    final value = _completed + 2;
    return value > 6 ? 6 : value;
  }

  int get _accuracy => _completed == 0
      ? 0
      : ((_totalStars / (_completed * 3)) * 100).round().clamp(0, 100);

  int get _studiedBiliks =>
      _titles.keys.where((bilikId) => _completedFor(bilikId) > 0).length;

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar dari akun?'),
        content: const Text('Progres lokal tetap tersimpan di perangkat ini.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await SessionService.clearSession();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: RefreshIndicator(
            onRefresh: _load,
            color: AppColors.indigo,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 126),
              children: [
                _ProgressHeader(
                  studentId: _studentId,
                  isDemo: _isDemo,
                  level: _level,
                  xp: _xp,
                  stars: _totalStars,
                  completed: _completed,
                ),
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Column(
                      children: [
                        SkeletonCard(height: 180),
                        SizedBox(height: 12),
                        SkeletonCard(height: 220),
                      ],
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_offline) ...[
                          const StatusBanner(
                            kind: StatusBannerKind.offline,
                            message:
                                'Kamu sedang offline. Progress tetap tersimpan di perangkat.',
                          ),
                          const SizedBox(height: 16),
                        ],
                        const FunSectionHeader(
                          title: 'Koleksi Lencana',
                          subtitle: 'Pencapaian pribadimu, bukan perbandingan.',
                        ),
                        const SizedBox(height: 12),
                        GridView.count(
                          crossAxisCount: 3,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.76,
                          children: [
                            _AchievementCard(
                              name: 'Berani Mencoba',
                              earned: _completed >= 1,
                              current: _completed,
                              target: 1,
                              description:
                                  'Selesaikan misi pertamamu untuk membuka lencana ini.',
                              accent: AppColors.success,
                              illustration: WicaraIllustrationType.target,
                            ),
                            _AchievementCard(
                              name: 'Penyusun Kata',
                              earned: _totalStars >= 3,
                              current: _totalStars,
                              target: 3,
                              description:
                                  'Kumpulkan tiga bintang dari latihan kartu kata.',
                              accent: AppColors.warning,
                              illustration: WicaraIllustrationType.practice,
                            ),
                            _AchievementCard(
                              name: 'Pesan Sudah Jelas',
                              earned: _completed >= 2,
                              current: _completed,
                              target: 2,
                              description:
                                  'Selesaikan dua misi dengan pesan yang jelas.',
                              accent: AppColors.purple,
                              illustration: WicaraIllustrationType.statistics,
                            ),
                            _AchievementCard(
                              name: 'Komunikasi Siap',
                              earned: _completed >= 4,
                              current: _completed,
                              target: 4,
                              description:
                                  'Selesaikan empat misi dari perjalanan WICARA.',
                              accent: AppColors.indigo,
                              illustration: WicaraIllustrationType.progress,
                            ),
                            _AchievementCard(
                              name: 'Penjelajah Sekolah',
                              earned: _completedFor('akademik') >= 3,
                              current: _completedFor('akademik'),
                              target: 3,
                              description:
                                  'Tuntaskan seluruh misi di Bilik Sekolah.',
                              accent: AppColors.indigo,
                              illustration: WicaraIllustrationType.school,
                            ),
                            _AchievementCard(
                              name: 'Siap Magang',
                              earned: _completedFor('profesional') >= 3,
                              current: _completedFor('profesional'),
                              target: 3,
                              description:
                                  'Tuntaskan seluruh misi di Bilik Profesional.',
                              accent: AppColors.purple,
                              illustration: WicaraIllustrationType.work,
                            ),
                          ],
                        ),
                        const SizedBox(height: 26),
                        const FunSectionHeader(
                          title: 'Progress Bilik',
                          subtitle:
                              'Selesaikan satu misi untuk membuka berikutnya.',
                        ),
                        const SizedBox(height: 12),
                        _BilikProgressCard(
                          title: 'Bilik Sekolah',
                          completed: _completedFor('akademik'),
                          nextMission: _nextMission('akademik'),
                          accent: AppColors.indigo,
                          illustration: WicaraIllustrationType.school,
                          onTap: widget.onOpenBilik,
                        ),
                        const SizedBox(height: 11),
                        _BilikProgressCard(
                          title: 'Bilik Profesional',
                          completed: _completedFor('profesional'),
                          nextMission: _nextMission('profesional'),
                          accent: AppColors.purple,
                          illustration: WicaraIllustrationType.work,
                          onTap: widget.onOpenBilik,
                        ),
                        const SizedBox(height: 26),
                        _buildSummary(),
                        const SizedBox(height: 26),
                        const FunSectionHeader(
                          title: 'Jejak Misi',
                          subtitle: 'Setiap titik mewakili satu kasus latihan.',
                        ),
                        const SizedBox(height: 12),
                        _MissionJourney(completed: _completed),
                        const SizedBox(height: 26),
                        const FunSectionHeader(title: 'Insight Belajar'),
                        const SizedBox(height: 12),
                        _InsightCard(
                          title: _insightTitle(),
                          message: _insightMessage(),
                          actionLabel: _completed == 0
                              ? 'Mulai Belajar'
                              : 'Latihan Sekarang',
                          onAction: widget.onOpenBilik,
                          secondaryLabel: 'Buka Kamus',
                          onSecondary: widget.onOpenDictionary,
                        ),
                        const SizedBox(height: 26),
                        const FunSectionHeader(title: 'Riwayat Latihan'),
                        const SizedBox(height: 12),
                        if (_completed == 0)
                          const FriendlyEmptyState(
                            title: 'Belum ada progress',
                            message:
                                'Yuk mulai latihan pertamamu dari Bilik Sekolah hari ini!',
                            illustration: WicaraIllustrationType.progress,
                          )
                        else
                          ..._completedItems().map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 9),
                              child: _HistoryTile(
                                title: item.$3,
                                stars: item.$4,
                                bilik: item.$1 == 'akademik'
                                    ? 'Bilik Sekolah'
                                    : 'Bilik Profesional',
                                timeLabel: _timeLabel(
                                  _completedAt['${item.$1}_${item.$2}'],
                                ),
                                illustration: item.$1 == 'akademik'
                                    ? WicaraIllustrationType.school
                                    : WicaraIllustrationType.work,
                              ),
                            ),
                          ),
                        const SizedBox(height: 26),
                        const FunSectionHeader(
                          title: 'Profil',
                          subtitle: 'Akun dan penyimpanan progress belajarmu.',
                        ),
                        const SizedBox(height: 12),
                        _AccountPanel(studentId: _studentId, isDemo: _isDemo),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: _logout,
                          icon: const Icon(Icons.logout_rounded),
                          label: const Text('Keluar dari akun'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.danger,
                            side: const BorderSide(color: Color(0xFFF4C9D0)),
                            minimumSize: const Size.fromHeight(52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            textStyle: GoogleFonts.nunitoSans(
                              fontWeight: FontWeight.w900,
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
      ),
    );
  }

  String _nextMission(String bilikId) {
    final completed = _completedFor(bilikId);
    final titles = _titles[bilikId] ?? const <String>[];
    if (completed >= titles.length) return 'Semua kasus selesai';
    return titles[completed];
  }

  String _timeLabel(int? milliseconds) {
    if (milliseconds == null) return 'Riwayat sebelumnya';
    final completed = DateTime.fromMillisecondsSinceEpoch(milliseconds);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(completed.year, completed.month, completed.day);
    final days = today.difference(day).inDays;
    if (days <= 0) return 'Hari ini';
    if (days == 1) return 'Kemarin';
    return '$days hari lalu';
  }

  Widget _buildSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FunSectionHeader(
          title: 'Ringkasan Belajar',
          subtitle: 'Lihat hasil latihanmu dalam satu pandangan.',
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.35,
          children: [
            _InfoStatCard(
              value: '$_completed',
              label: 'Latihan selesai',
              accent: AppColors.indigo,
              illustration: WicaraIllustrationType.practice,
            ),
            _InfoStatCard(
              value: '$_totalStars',
              label: 'Bintang terkumpul',
              accent: const Color(0xFFC28A00),
              illustration: WicaraIllustrationType.achievement,
            ),
            _InfoStatCard(
              value: 'Level $_level',
              label: 'Level belajar',
              accent: AppColors.purple,
              illustration: WicaraIllustrationType.statistics,
            ),
            _InfoStatCard(
              value: '$_unlockedMissions/6',
              label: 'Misi terbuka',
              accent: AppColors.success,
              illustration: WicaraIllustrationType.target,
            ),
            _InfoStatCard(
              value: '$_accuracy%',
              label: 'Ketepatan latihan',
              accent: AppColors.danger,
              illustration: WicaraIllustrationType.statistics,
            ),
            _InfoStatCard(
              value: '$_studiedBiliks/2',
              label: 'Bilik dipelajari',
              accent: AppColors.purple,
              illustration: WicaraIllustrationType.work,
            ),
          ],
        ),
      ],
    );
  }

  String _insightTitle() {
    if (_completed == 0) return 'Petualanganmu siap dimulai';
    if (_completedFor('akademik') == 3) return 'Bilik Sekolah sudah dikuasai';
    if (_totalStars >= _completed * 2) return 'Susunan kalimatmu makin rapi';
    return 'Langkahmu terus bertambah';
  }

  String _insightMessage() {
    if (_completed == 0) {
      return 'Mulai dari satu latihan singkat. Setiap misi akan menambah jejak belajarmu.';
    }
    if (_completedFor('akademik') > _completedFor('profesional')) {
      return 'Kamu sudah kuat di situasi sekolah. Ayo lanjutkan latihan komunikasi profesional.';
    }
    if (_totalStars >= _completed * 2) {
      return 'Kamu konsisten menyusun pesan dengan baik. Pertahankan ketelitianmu.';
    }
    return 'Progress-mu terus bergerak. Ulangi latihan untuk menguatkan urutan SPOK.';
  }

  List<(String, int, String, int)> _completedItems() {
    final result = <(String, int, String, int)>[];
    for (final item in _progress.where((item) => item.status == 'completed')) {
      final titles = _titles[item.bilikId];
      if (titles == null || item.levelId < 1 || item.levelId > titles.length) {
        continue;
      }
      final stars = _bestStars['${item.bilikId}_${item.levelId}'] ?? 0;
      result.add((item.bilikId, item.levelId, titles[item.levelId - 1], stars));
    }
    return result;
  }
}

class _ProgressHeader extends StatelessWidget {
  final String studentId;
  final bool isDemo;
  final int level;
  final int xp;
  final int stars;
  final int completed;

  const _ProgressHeader({
    required this.studentId,
    required this.isDemo,
    required this.level,
    required this.xp,
    required this.stars,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    final intoLevel = xp % 150;
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.paddingOf(context).top + 24,
        20,
        30,
      ),
      decoration: const BoxDecoration(
        color: AppColors.indigo,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  const WicaraIllustrationIcon(
                    type: WicaraIllustrationType.progress,
                    size: 82,
                    accent: AppColors.indigo,
                    background: Colors.white,
                  ),
                  Positioned(
                    right: -5,
                    bottom: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.purple,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        'L$level',
                        style: GoogleFonts.nunitoSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 17),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isDemo
                          ? 'Profil belajar - Akun demo'
                          : 'Profil belajar - $studentId',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      'Petualang WICARA',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 17,
                          color: Color(0xFFFFD36A),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '$stars bintang - $completed misi selesai',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.nunitoSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Level $level - $xp XP',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
              Text(
                '$intoLevel / 150 menuju level berikutnya',
                style: GoogleFonts.nunitoSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AnimatedProgressBar(
            value: intoLevel / 150,
            color: const Color(0xFFFFD36A),
            backgroundColor: Colors.white24,
          ),
        ],
      ),
    );
  }
}

class _InfoStatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color accent;
  final WicaraIllustrationType illustration;

  const _InfoStatCard({
    required this.value,
    required this.label,
    required this.accent,
    required this.illustration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Color.lerp(accent, Colors.white, 0.92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          WicaraIllustrationIcon(
            type: illustration,
            size: 46,
            accent: accent,
            background: Colors.white,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                ),
                Text(
                  label,
                  maxLines: 2,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 9,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text2,
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

class _BilikProgressCard extends StatelessWidget {
  final String title;
  final int completed;
  final String nextMission;
  final Color accent;
  final WicaraIllustrationType illustration;
  final VoidCallback? onTap;

  const _BilikProgressCard({
    required this.title,
    required this.completed,
    required this.nextMission,
    required this.accent,
    required this.illustration,
    this.onTap,
  });

  String get _status {
    if (completed == 0) return 'Baru Mulai';
    if (completed == 1) return 'Sedang Belajar';
    if (completed == 2) return 'Hebat';
    return 'Selesai';
  }

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      semanticLabel: 'Buka $title',
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: accent.withValues(alpha: 0.14)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x091F2858),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            WicaraIllustrationIcon(
              type: illustration,
              size: 60,
              accent: accent,
              background: Color.lerp(accent, Colors.white, 0.86)!,
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Color.lerp(accent, Colors.white, 0.86),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          _status,
                          style: GoogleFonts.nunitoSans(
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            color: accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  AnimatedProgressBar(value: completed / 3, color: accent),
                  const SizedBox(height: 6),
                  Text(
                    '$completed dari 3 kasus selesai',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    completed >= 3 ? nextMission : 'Berikutnya: $nextMission',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunitoSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: accent,
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
}

class _MissionJourney extends StatefulWidget {
  final int completed;

  const _MissionJourney({required this.completed});

  @override
  State<_MissionJourney> createState() => _MissionJourneyState();
}

class _MissionJourneyState extends State<_MissionJourney>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
      lowerBound: 0.94,
      upperBound: 1.06,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 15),
      decoration: BoxDecoration(
        color: AppColors.softBlue,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 154,
            child: LayoutBuilder(
              builder: (context, constraints) {
                const positions = <Offset>[
                  Offset(0.08, 0.74),
                  Offset(0.25, 0.30),
                  Offset(0.43, 0.64),
                  Offset(0.61, 0.22),
                  Offset(0.78, 0.58),
                  Offset(0.93, 0.20),
                ];
                final points = positions
                    .map(
                      (p) => Offset(
                        p.dx * constraints.maxWidth,
                        p.dy * constraints.maxHeight,
                      ),
                    )
                    .toList();
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _JourneyPathPainter(
                          points: points,
                          completed: widget.completed,
                        ),
                      ),
                    ),
                    for (var index = 0; index < points.length; index++)
                      Positioned(
                        left: points[index].dx - 22,
                        top: points[index].dy - 22,
                        child: _JourneyNode(
                          number: index + 1,
                          done: index < widget.completed,
                          active:
                              index == widget.completed && widget.completed < 6,
                          reward: index == points.length - 1,
                          pulse: _pulse,
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          if (widget.completed > 0 && widget.completed < 6)
            const StatusBanner(
              kind: StatusBannerKind.success,
              message: 'Kasus berikutnya telah terbuka.',
            ),
        ],
      ),
    );
  }
}

class _JourneyNode extends StatelessWidget {
  final int number;
  final bool done;
  final bool active;
  final bool reward;
  final Animation<double> pulse;

  const _JourneyNode({
    required this.number,
    required this.done,
    required this.active,
    required this.reward,
    required this.pulse,
  });

  @override
  Widget build(BuildContext context) {
    final node = Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: done
            ? AppColors.success
            : active
            ? Colors.white
            : const Color(0xFFDDE2F0),
        shape: BoxShape.circle,
        border: active ? Border.all(color: AppColors.indigo, width: 3) : null,
        boxShadow: active
            ? const [BoxShadow(color: Color(0x304C5FD7), blurRadius: 12)]
            : null,
      ),
      child: done
          ? const Icon(Icons.check_rounded, color: Colors.white, size: 21)
          : active
          ? Text(
              '$number',
              style: GoogleFonts.nunitoSans(
                fontWeight: FontWeight.w900,
                color: AppColors.indigo,
              ),
            )
          : Icon(
              reward ? Icons.card_giftcard_rounded : Icons.lock_rounded,
              size: 18,
              color: AppColors.muted,
            ),
    );
    return Semantics(
      label: done
          ? 'Misi $number selesai'
          : active
          ? 'Misi $number aktif'
          : 'Misi $number terkunci',
      child: active ? ScaleTransition(scale: pulse, child: node) : node,
    );
  }
}

class _JourneyPathPainter extends CustomPainter {
  final List<Offset> points;
  final int completed;

  const _JourneyPathPainter({required this.points, required this.completed});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    Path buildPath(int end) {
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (var i = 1; i <= end; i++) {
        final previous = points[i - 1];
        final current = points[i];
        final midpoint = (previous.dx + current.dx) / 2;
        path.cubicTo(
          midpoint,
          previous.dy,
          midpoint,
          current.dy,
          current.dx,
          current.dy,
        );
      }
      return path;
    }

    canvas.drawPath(
      buildPath(points.length - 1),
      Paint()
        ..color = AppColors.line
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9
        ..strokeCap = StrokeCap.round,
    );
    if (completed <= 0) return;
    canvas.drawPath(
      buildPath(completed.clamp(1, points.length - 1)),
      Paint()
        ..color = AppColors.success.withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _JourneyPathPainter oldDelegate) =>
      oldDelegate.completed != completed || oldDelegate.points != points;
}

class _AchievementCard extends StatelessWidget {
  final String name;
  final bool earned;
  final int current;
  final int target;
  final String description;
  final Color accent;
  final WicaraIllustrationType illustration;

  const _AchievementCard({
    required this.name,
    required this.earned,
    required this.current,
    required this.target,
    required this.description,
    required this.accent,
    required this.illustration,
  });

  @override
  Widget build(BuildContext context) {
    final inProgress = !earned && current > 0;
    return PressableScale(
      onTap: () => showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          icon: WicaraIllustrationIcon(
            type: illustration,
            size: 76,
            accent: earned ? accent : AppColors.muted,
          ),
          title: Text(earned ? 'Lencana Baru Terbuka' : name),
          content: Text(
            earned
                ? 'Kamu berhasil memperoleh lencana $name.'
                : '$description\n\nProgress: ${current.clamp(0, target)} dari $target',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Mengerti'),
            ),
          ],
        ),
      ),
      semanticLabel: 'Lihat lencana $name',
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: earned ? 1 : 0.62,
        child: Container(
          padding: const EdgeInsets.fromLTRB(8, 13, 8, 12),
          decoration: BoxDecoration(
            color: earned ? AppColors.softYellow : const Color(0xFFF0F2F7),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: earned ? AppColors.warning : AppColors.line,
            ),
            boxShadow: earned
                ? const [
                    BoxShadow(
                      color: Color(0x0FA66A00),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              WicaraIllustrationIcon(
                type: illustration,
                size: 54,
                accent: earned ? accent : AppColors.muted,
                background: earned ? Colors.white70 : Colors.white,
              ),
              const SizedBox(height: 9),
              Text(
                name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.nunitoSans(
                  fontSize: 10,
                  height: 1.15,
                  fontWeight: FontWeight.w900,
                  color: earned ? AppColors.ink : AppColors.muted,
                ),
              ),
              const SizedBox(height: 7),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                decoration: BoxDecoration(
                  color: earned
                      ? AppColors.softMint
                      : inProgress
                      ? AppColors.softBlue
                      : const Color(0xFFE4E7EE),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      earned
                          ? Icons.check_rounded
                          : inProgress
                          ? Icons.timelapse_rounded
                          : Icons.lock_rounded,
                      size: 11,
                      color: earned ? AppColors.success : AppColors.muted,
                    ),
                    const SizedBox(width: 3),
                    Flexible(
                      child: Text(
                        earned
                            ? 'Diperoleh'
                            : inProgress
                            ? '$current/$target'
                            : 'Terkunci',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.nunitoSans(
                          fontSize: 7.5,
                          fontWeight: FontWeight.w900,
                          color: earned ? AppColors.success : AppColors.muted,
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

class _InsightCard extends StatelessWidget {
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback? onAction;
  final String secondaryLabel;
  final VoidCallback? onSecondary;

  const _InsightCard({
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
    required this.secondaryLabel,
    required this.onSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.softMint,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.16)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const WicaraIllustrationIcon(
            type: WicaraIllustrationType.statistics,
            size: 58,
            accent: AppColors.success,
            background: Colors.white,
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  message,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 11,
                    height: 1.4,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text2,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton(
                      onPressed: onAction,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.success,
                        minimumSize: const Size(0, 44),
                      ),
                      child: Text(actionLabel),
                    ),
                    TextButton(
                      onPressed: onSecondary,
                      style: TextButton.styleFrom(
                        minimumSize: const Size(0, 44),
                      ),
                      child: Text(secondaryLabel),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final String title;
  final String bilik;
  final String timeLabel;
  final int stars;
  final WicaraIllustrationType illustration;

  const _HistoryTile({
    required this.title,
    required this.bilik,
    required this.timeLabel,
    required this.stars,
    required this.illustration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          WicaraIllustrationIcon(
            type: illustration,
            size: 46,
            accent: illustration == WicaraIllustrationType.school
                ? AppColors.indigo
                : AppColors.purple,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '$bilik - $timeLabel',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text2,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: List.generate(
                    3,
                    (index) => Padding(
                      padding: const EdgeInsets.only(right: 3),
                      child: Icon(
                        Icons.star_rounded,
                        size: 15,
                        color: index < stars
                            ? const Color(0xFFE5A91D)
                            : const Color(0xFFDDE2F0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Detail latihan',
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              builder: (context) => SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$bilik - $stars dari 3 bintang',
                        style: GoogleFonts.nunitoSans(
                          fontWeight: FontWeight.w800,
                          color: AppColors.text2,
                        ),
                      ),
                      const SizedBox(height: 18),
                      FilledButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Tutup'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            icon: const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.indigo,
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountPanel extends StatelessWidget {
  final String studentId;
  final bool isDemo;

  const _AccountPanel({required this.studentId, required this.isDemo});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.softBlue,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.indigo.withValues(alpha: 0.14)),
      ),
      child: Row(
        children: [
          const WicaraIllustrationIcon(
            type: WicaraIllustrationType.subject,
            size: 62,
            accent: AppColors.indigo,
            background: Colors.white,
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  studentId,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isDemo
                      ? 'Akun demo - progress tersimpan di perangkat'
                      : 'Akun siswa - progress disinkronkan saat online',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 10,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text2,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            isDemo ? Icons.phone_android_rounded : Icons.sync_rounded,
            color: AppColors.indigo,
          ),
        ],
      ),
    );
  }
}
