import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wicara_application_1/core/theme/app_colors.dart';
import 'package:wicara_application_1/data/repositories/local_content_repository.dart';
import 'package:wicara_application_1/models/bilik.dart';
import 'package:wicara_application_1/services/api_service.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _content = const LocalContentRepository();
  List<Bilik> _biliks = const [];
  List<StudentProgress> _progress = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);
    final biliks = await _content.getBiliks();
    final progress = await ApiService.fetchProgress();
    if (!mounted) return;
    setState(() {
      _biliks = biliks;
      _progress = progress;
      _loading = false;
    });
  }

  int _completedFor(String id) => _progress
      .where((item) => item.bilikId == id && item.status == 'completed')
      .length;

  @override
  Widget build(BuildContext context) {
    final completed = _progress
        .where((item) => item.status == 'completed')
        .length
        .clamp(0, 6);
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: RefreshIndicator(
        onRefresh: _load,
        color: AppColors.indigo,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            18,
            MediaQuery.paddingOf(context).top + 20,
            18,
            118,
          ),
          children: [
            Text(
              'Raport Belajar',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 25,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Lihat perkembangan latihan komunikasi formalmu.',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.muted),
            ),
            const SizedBox(height: 20),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 120),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.indigo),
                ),
              )
            else ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.navy,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    SizedBox.square(
                      dimension: 82,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: completed / 6,
                            strokeWidth: 9,
                            backgroundColor: Colors.white12,
                            color: const Color(0xFFFFD36A),
                          ),
                          Text(
                            '$completed/6',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            completed == 0
                                ? 'Petualangan dimulai'
                                : 'Teruskan langkah baikmu',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '$completed kasus selesai · ${completed * 50} XP terkumpul',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              height: 1.45,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      icon: Icons.view_carousel_rounded,
                      value: '${(completed + 2).clamp(2, 6)}',
                      label: 'Mode terpandu terbuka',
                      color: AppColors.indigo,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: _MetricCard(
                      icon: Icons.lock_clock_rounded,
                      value: 'Preview',
                      label: 'Mode mandiri',
                      color: AppColors.purple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Text(
                'Progress per bilik',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 11),
              ..._biliks.map((bilik) {
                final done = _completedFor(bilik.id).clamp(0, 3);
                final brand = bilik.id == 'akademik'
                    ? AppColors.indigo
                    : AppColors.purple;
                return Container(
                  margin: const EdgeInsets.only(bottom: 11),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            bilik.id == 'akademik'
                                ? Icons.school_rounded
                                : Icons.business_center_rounded,
                            color: brand,
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Text(
                              bilik.title,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                          Text(
                            '$done/3',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: brand,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 11),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          minHeight: 7,
                          value: done / 3,
                          backgroundColor: const Color(0xFFE9ECF4),
                          valueColor: AlwaysStoppedAnimation(brand),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.insights_rounded,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Yang perlu dilatih',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: AppColors.ink,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Urutan kata · ringkasan sementara dari latihan kartu lokal.',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              height: 1.45,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _MetricCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 132),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 25),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              height: 1.3,
              color: AppColors.muted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
