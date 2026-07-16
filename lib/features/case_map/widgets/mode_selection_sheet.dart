import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wicara_application_1/core/theme/app_colors.dart';
import 'package:wicara_application_1/models/revision3_content.dart';
import 'package:wicara_application_1/widgets/wika_mascot.dart';

class ModeSelectionSheet extends StatelessWidget {
  final LearningMission mission;
  final bool independentUnlocked;
  final bool guidedCompleted;
  final int bestStars;
  final VoidCallback onStartGuided;
  final VoidCallback onStartIndependent;

  const ModeSelectionSheet({
    super.key,
    required this.mission,
    required this.independentUnlocked,
    required this.guidedCompleted,
    required this.bestStars,
    required this.onStartGuided,
    required this.onStartIndependent,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFD0D5DD),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'KASUS ${mission.order}',
                        style: GoogleFonts.nunitoSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: AppColors.indigo,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mission.title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 21,
                          height: 1.18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
                const WikaMascot(
                  mood: WikaMood.hint,
                  size: 58,
                  animated: false,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.line),
              ),
              child: Text(
                mission.description,
                style: GoogleFonts.nunitoSans(
                  fontSize: 13,
                  height: 1.48,
                  color: AppColors.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 14),
            _ModeCard(
              icon: Icons.open_with_rounded,
              title: 'Mode Terpandu',
              subtitle: 'Susun Kartu Kata',
              description:
                  'Ikuti cerita dan susun ${mission.guided.rounds.length} bagian pesan dengan kartu kata.',
              color: AppColors.indigo,
              dark: AppColors.indigoDark,
              softColor: AppColors.softBlue,
              borderColor: const Color(0xFFC4CBDF),
              badge: 'Direkomendasikan',
              xpLabel: '+${mission.rewardXp} XP',
              buttonLabel: 'Mulai Mode Terpandu',
              onPressed: onStartGuided,
            ),
            const SizedBox(height: 12),
            _ModeCard(
              icon: independentUnlocked
                  ? Icons.edit_note_rounded
                  : Icons.lock_rounded,
              title: 'Mode Mandiri',
              subtitle: mission.independent.kind == 'email'
                  ? 'Simulasi Email'
                  : 'Tulis Pesanmu Sendiri',
              description: independentUnlocked
                  ? 'Tulis pesanmu sendiri dan dapatkan petunjuk formalitas.'
                  : guidedCompleted
                  ? 'Raih 3 bintang sempurna di Mode Terpandu untuk membuka ini. Bintang terbaikmu: $bestStars.'
                  : 'Dapatkan 3 bintang di Mode Terpandu untuk membuka mode ini.',
              color: independentUnlocked
                  ? AppColors.purple
                  : const Color(0xFF98A2B3),
              dark: independentUnlocked
                  ? AppColors.purpleDark
                  : const Color(0xFF98A2B3),
              softColor: independentUnlocked
                  ? AppColors.softPurple
                  : const Color(0xFFF7F8FC),
              borderColor: independentUnlocked
                  ? const Color(0xFFD8CCFA)
                  : AppColors.line,
              badge: independentUnlocked ? 'Terbuka' : 'Terkunci',
              starCount: independentUnlocked ? 3 : bestStars,
              buttonLabel: independentUnlocked
                  ? 'Mulai Mode Mandiri'
                  : 'Terkunci',
              onPressed: independentUnlocked ? onStartIndependent : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String description;
  final Color color;
  final Color dark;
  final Color softColor;
  final Color borderColor;
  final String badge;
  final String? xpLabel;
  final int? starCount;
  final String buttonLabel;
  final VoidCallback? onPressed;

  const _ModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.color,
    required this.dark,
    required this.softColor,
    required this.borderColor,
    required this.badge,
    this.xpLabel,
    this.starCount,
    required this.buttonLabel,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: softColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 23),
              ),
              const SizedBox(width: 12),
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
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: enabled
                                  ? AppColors.ink
                                  : const Color(0xFF69738F),
                            ),
                          ),
                        ),
                        if (xpLabel != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(99),
                              border: Border.all(
                                color: const Color(0xFFE5A91D),
                              ),
                            ),
                            child: Text(
                              xpLabel!,
                              style: GoogleFonts.nunitoSans(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF6A4C00),
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                        ],
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: enabled ? color : const Color(0xFFE9ECF4),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(
                            badge,
                            style: GoogleFonts.nunitoSans(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: enabled ? Colors.white : color,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Baris 3 bintang: tujuan visual unlock Mode Mandiri (desain Figma)
          if (starCount != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Icon(
                    index < starCount!
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 21,
                    color: index < starCount!
                        ? const Color(0xFFFFD36A)
                        : const Color(0xFFDDE2F0),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          Text(
            description,
            textAlign: starCount != null ? TextAlign.center : TextAlign.start,
            style: GoogleFonts.nunitoSans(
              fontSize: 12,
              height: 1.4,
              fontWeight: FontWeight.w600,
              color: AppColors.text2,
            ),
          ),
          const SizedBox(height: 13),
          SizedBox(
            height: 49,
            child: FilledButton.icon(
              onPressed: onPressed,
              icon: Icon(
                enabled ? Icons.play_arrow_rounded : Icons.lock_rounded,
              ),
              label: Text(buttonLabel),
              style: FilledButton.styleFrom(
                backgroundColor: color,
                disabledBackgroundColor: const Color(0xFFE4E7EF),
                disabledForegroundColor: const Color(0xFF8490AA),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: GoogleFonts.nunitoSans(
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
                shadowColor: enabled ? dark : Colors.transparent,
                elevation: enabled ? 4 : 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
