import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wicara_application_1/core/theme/app_colors.dart';
import 'package:wicara_application_1/data/repositories/revision3_content_repository.dart';
import 'package:wicara_application_1/features/case_map/screens/case_map_screen.dart';
import 'package:wicara_application_1/features/home/widgets/bilik_card.dart';
import 'package:wicara_application_1/features/shared/widgets/fun_ui_components.dart';
import 'package:wicara_application_1/features/shared/widgets/wicara_illustration_icon.dart';
import 'package:wicara_application_1/models/bilik.dart';
import 'package:wicara_application_1/models/revision3_content.dart';
import 'package:wicara_application_1/screens/focus_screen.dart';
import 'package:wicara_application_1/services/api_service.dart';
import 'package:wicara_application_1/services/session_service.dart';
import 'package:wicara_application_1/widgets/wika_mascot.dart';

class BilikSelectionScreen extends StatefulWidget {
  const BilikSelectionScreen({super.key});

  @override
  State<BilikSelectionScreen> createState() => _BilikSelectionScreenState();
}

class _BilikSelectionScreenState extends State<BilikSelectionScreen> {
  Revision3Content? _content;
  List<StudentProgress> _progress = const [];
  String _studentId = 'Siswa WICARA';
  bool _loading = true;
  bool _offline = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _loadError = null;
      });
    }
    try {
      final results = await Future.wait([
        Revision3ContentRepository.load(),
        ApiService.fetchProgress(),
        SessionService.getStudentId(),
      ]);
      if (!mounted) return;
      setState(() {
        _content = results[0] as Revision3Content;
        _progress = results[1] as List<StudentProgress>;
        _studentId = results[2] as String? ?? 'Siswa WICARA';
        _offline = ApiService.lastProgressUsedCache;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _loadError =
              'Progress belum berhasil dimuat. Kami akan mencoba lagi.';
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  int _completedFor(LearningBilik bilik) => _progress
      .where(
        (item) =>
            item.bilikId == bilik.progressId && item.status == 'completed',
      )
      .length;

  Future<void> _openBilik(LearningBilik bilik) async {
    final content = _content;
    if (content == null) return;
    final before = _progress.where((item) => item.status == 'completed').length;
    await Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 260),
        pageBuilder: (context, animation, secondaryAnimation) => CaseMapScreen(
          bilik: bilik,
          missions: Revision3ContentRepository.missionsFor(content, bilik.id),
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween(
                  begin: const Offset(0.04, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
      ),
    );
    await _load();
    if (!mounted) return;
    final after = _progress.where((item) => item.status == 'completed').length;
    if (after > before) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Progress berhasil disimpan.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  LearningMission? _nextMissionFor(LearningBilik bilik) {
    final content = _content;
    if (content == null) return null;
    final completedLevels = _progress
        .where(
          (item) =>
              item.bilikId == bilik.progressId && item.status == 'completed',
        )
        .map((item) => item.levelId)
        .toSet();
    for (final mission in Revision3ContentRepository.missionsFor(
      content,
      bilik.id,
    )) {
      if (!completedLevels.contains(mission.order)) return mission;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final totalCompleted = _progress
        .where((item) => item.status == 'completed')
        .length;
    final biliks = _content?.biliks ?? const <LearningBilik>[];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: RefreshIndicator(
            onRefresh: _load,
            color: AppColors.indigo,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _Hero(
                    studentId: _studentId,
                    completed: totalCompleted,
                    total: 6,
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 54, 20, 126),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Row(
                        children: [
                          Expanded(
                            child: _LevelCard(
                              level: 1 + (totalCompleted ~/ 3),
                              xp: totalCompleted * 50,
                            ),
                          ),
                          const SizedBox(width: 10),
                          _FocusButton(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const FocusScreen(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      if (_loadError != null) ...[
                        StatusBanner(
                          kind: StatusBannerKind.error,
                          message: _loadError!,
                          onRetry: _load,
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (_offline) ...[
                        const StatusBanner(
                          kind: StatusBannerKind.offline,
                          message:
                              'Kamu sedang offline. Progress tetap tersimpan di perangkat.',
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (!_loading && biliks.isNotEmpty) ...[
                        _DailyMissionCard(
                          bilik: biliks.firstWhere(
                            (bilik) => _nextMissionFor(bilik) != null,
                            orElse: () => biliks.first,
                          ),
                          mission: _nextMissionFor(
                            biliks.firstWhere(
                              (bilik) => _nextMissionFor(bilik) != null,
                              orElse: () => biliks.first,
                            ),
                          ),
                          onTap: () {
                            final bilik = biliks.firstWhere(
                              (item) => _nextMissionFor(item) != null,
                              orElse: () => biliks.first,
                            );
                            _openBilik(bilik);
                          },
                        ),
                        const SizedBox(height: 25),
                      ],
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pilih Bilik Belajar',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.ink,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _loading
                                      ? 'Memuat progresmu...'
                                      : '${(6 - totalCompleted).clamp(0, 6)} misi siap dimainkan',
                                  style: GoogleFonts.nunitoSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.text2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.softPurple,
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text(
                              'Misi',
                              style: GoogleFonts.nunitoSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: AppColors.purple,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      if (_loading)
                        ...List.generate(
                          2,
                          (index) => const Padding(
                            padding: EdgeInsets.only(bottom: 16),
                            child: SkeletonCard(height: 260),
                          ),
                        )
                      else if (biliks.isEmpty)
                        FriendlyEmptyState(
                          title: 'Bilik belum tersedia',
                          message:
                              'Tarik ke bawah untuk mencoba memuat bilik belajar lagi.',
                          illustration: WicaraIllustrationType.school,
                          action: FilledButton.icon(
                            onPressed: _load,
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Muat Ulang'),
                          ),
                        )
                      else
                        ...biliks.expand(
                          (bilik) => [
                            BilikCard(
                              bilik: bilik,
                              completed: _completedFor(bilik),
                              total: 3,
                              nextMission: _nextMissionFor(bilik)?.title,
                              onTap: () => _openBilik(bilik),
                            ),
                            const SizedBox(height: 17),
                          ],
                        ),
                    ]),
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

class _DailyMissionCard extends StatelessWidget {
  final LearningBilik bilik;
  final LearningMission? mission;
  final VoidCallback onTap;

  const _DailyMissionCard({
    required this.bilik,
    required this.mission,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = bilik.isSchool ? AppColors.indigo : AppColors.purple;
    final currentMission = mission;
    return PressableScale(
      onTap: onTap,
      semanticLabel: currentMission == null
          ? 'Lihat kembali misi'
          : 'Mulai ${currentMission.title}',
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: AppColors.softYellow,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.warning.withValues(alpha: 0.28)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0FA66A00),
              blurRadius: 16,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                WicaraIllustrationIcon(
                  type: bilik.isSchool
                      ? WicaraIllustrationType.school
                      : WicaraIllustrationType.work,
                  size: 56,
                  accent: accent,
                  background: Colors.white,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Misi Hari Ini',
                        style: GoogleFonts.nunitoSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF8B6500),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        currentMission?.title ?? 'Semua misi sudah selesai',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          height: 1.22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 13),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _MissionMeta(icon: Icons.place_outlined, label: bilik.title),
                const _MissionMeta(
                  icon: Icons.schedule_rounded,
                  label: 'sekitar 3 menit',
                ),
                _MissionMeta(
                  icon: Icons.workspace_premium_outlined,
                  label: '+${currentMission?.rewardXp ?? 0} XP',
                ),
              ],
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: Text(
                currentMission == null ? 'Lihat Petualangan' : 'Mulai Misi',
              ),
              style: FilledButton.styleFrom(
                backgroundColor: accent,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: GoogleFonts.nunitoSans(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MissionMeta extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MissionMeta({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white70,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.text2),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.nunitoSans(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: AppColors.text2,
            ),
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  final String studentId;
  final int completed;
  final int total;

  const _Hero({
    required this.studentId,
    required this.completed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final headline = completed == 0
        ? 'Hari ini mau\nberlatih di mana?'
        : completed >= total
        ? 'Kerja bagus!\nLatihanmu lengkap.'
        : 'Yuk, lanjutkan\npetualanganmu!';
    final encouragement = completed == 0
        ? 'Ayo mulai misi pertamamu.'
        : completed >= total
        ? 'Semua misi hari ini sudah selesai.'
        : 'Satu langkah lagi membuatmu makin mahir.';
    return Container(
      padding: EdgeInsets.fromLTRB(20, top + 20, 13, 42),
      decoration: const BoxDecoration(
        color: AppColors.indigo,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -64,
            top: -75,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white12),
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const WicaraIllustrationIcon(
                            type: WicaraIllustrationType.subject,
                            size: 18,
                            accent: Colors.white,
                            showBackground: false,
                          ),
                          const SizedBox(width: 7),
                          Flexible(
                            child: Text(
                              'Halo, $studentId',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.nunitoSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      headline,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 27,
                        height: 1.18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 13),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const WicaraIllustrationIcon(
                            type: WicaraIllustrationType.target,
                            size: 24,
                            accent: Color(0xFFFFD36A),
                            showBackground: false,
                          ),
                          const SizedBox(width: 7),
                          Flexible(
                            child: Text(
                              encouragement,
                              style: GoogleFonts.nunitoSans(
                                fontSize: 12,
                                height: 1.4,
                                fontWeight: FontWeight.w700,
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ...List.generate(
                          total,
                          (index) => Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: index < completed
                                      ? const Color(0xFFFFD36A)
                                      : Colors.white.withValues(alpha: 0.16),
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  index < completed ? '✓' : '${index + 1}',
                                  style: GoogleFonts.nunitoSans(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    color: index < completed
                                        ? const Color(0xFF5C3C00)
                                        : Colors.white54,
                                  ),
                                ),
                              ),
                              if (index < total - 1)
                                Container(
                                  width: 7,
                                  height: 2,
                                  color: const Color(0x66FFD36A),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            '$completed misi selesai',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.nunitoSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Transform.translate(
                offset: const Offset(0, 58),
                child: const WikaMascot(
                  mood: WikaMood.welcome,
                  size: 100,
                  animated: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final int level;
  final int xp;

  const _LevelCard({required this.level, required this.xp});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.line),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120F172A),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.purple,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              'L$level',
              style: GoogleFonts.nunitoSans(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    minHeight: 5,
                    value: (xp % 150) / 150,
                    backgroundColor: const Color(0xFFE8EBF4),
                    valueColor: const AlwaysStoppedAnimation(AppColors.indigo),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '$xp XP',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 10,
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

class _FocusButton extends StatelessWidget {
  final VoidCallback onTap;

  const _FocusButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7E1),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE5C56D)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.co_present_rounded,
                color: AppColors.warning,
                size: 18,
              ),
              const SizedBox(width: 7),
              Text(
                'Fokus',
                style: GoogleFonts.nunitoSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF6A4C00),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
