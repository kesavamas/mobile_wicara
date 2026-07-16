import 'dart:async';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wicara_application_1/core/theme/app_colors.dart';
import 'package:wicara_application_1/core/utils/formal_text_analyzer.dart';
import 'package:wicara_application_1/features/independent_mode/widgets/independent_mission_visual.dart';
import 'package:wicara_application_1/models/revision3_content.dart';
import 'package:wicara_application_1/services/api_service.dart';
import 'package:wicara_application_1/widgets/wika_mascot.dart';

class IndependentSimulationScreen extends StatefulWidget {
  final LearningBilik bilik;
  final LearningMission mission;

  const IndependentSimulationScreen({
    super.key,
    required this.bilik,
    required this.mission,
  });

  @override
  State<IndependentSimulationScreen> createState() =>
      _IndependentSimulationScreenState();
}

class _IndependentSimulationScreenState
    extends State<IndependentSimulationScreen> {
  final _controller = TextEditingController();
  late final ConfettiController _confetti;
  final DateTime _startedAt = DateTime.now();
  FormalTextAnalysis? _analysis;
  bool _checking = false;

  Color get _brand =>
      widget.bilik.isSchool ? AppColors.indigo : AppColors.purple;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _controller.dispose();
    _confetti.dispose();
    super.dispose();
  }

  void _evaluate() {
    final input = _controller.text.trim();
    if (input.length < 10 || _checking) return;
    setState(() => _checking = true);
    final analysis = analyzeFormalText(input, widget.mission);
    setState(() {
      _analysis = analysis;
      _checking = false;
    });
    if (analysis.isFullyFormal) _confetti.play();
    unawaited(
      ApiService.logAttempt(
        analysis.isFullyFormal,
        [
          for (var index = 0; index < analysis.tokens.length; index++)
            if (analysis.tokens[index].misplaced) index,
        ],
        bilikId: widget.mission.progressBilikId,
        levelId: widget.mission.order,
        score: analysis.score.toDouble(),
        wer: 1 - analysis.meterValue,
        stars: 0,
        rawArrangement: analysis.tokens.map((token) => token.text).toList(),
        errorTypes: analysis.tokens
            .where((token) => token.misplaced)
            .map((token) => 'permutation_${token.role.toLowerCase()}')
            .toList(),
        durationMs: DateTime.now().difference(_startedAt).inMilliseconds,
        assistanceLevel: 'INDEPENDENT_FORMALITY_METER',
        eventType: 'independent_formality_check',
        persistStars: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mission = widget.mission;
    final isEmail = mission.independent.kind == 'email';
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: Stack(
            children: [
              SafeArea(
                child: Column(
                  children: [
                    _Header(
                      mission: mission,
                      brand: _brand,
                      onBack: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(18, 16, 18, 118),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            IndependentMissionVisual(
                              mission: mission,
                              brand: _brand,
                            ),
                            const SizedBox(height: 15),
                            _ScenarioPrompt(mission: mission, brand: _brand),
                            if (isEmail &&
                                mission.independent.emailSubject != null) ...[
                              const SizedBox(height: 12),
                              _EmailSubject(
                                subject: mission.independent.emailSubject!,
                              ),
                            ],
                            const SizedBox(height: 12),
                            _MessageComposer(
                              controller: _controller,
                              placeholder: mission.independent.placeholder,
                              isEmail: isEmail,
                              contactName: mission.otherName,
                              brand: _brand,
                              onChanged: () => setState(() => _analysis = null),
                            ),
                            if (_analysis != null) ...[
                              const SizedBox(height: 16),
                              if (_analysis!.isFullyFormal) ...[
                                IndependentCharacterResult(
                                  mission: mission,
                                  brand: _brand,
                                ),
                                const SizedBox(height: 14),
                              ],
                              _FormalityResult(analysis: _analysis!),
                              const SizedBox(height: 14),
                              _ColorGuidance(analysis: _analysis!),
                              if (_analysis!.isFullyFormal) ...[
                                const SizedBox(height: 16),
                                SentenceTree(chunks: _analysis!.chunks),
                              ],
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 18,
                right: 18,
                bottom: 18 + MediaQuery.paddingOf(context).bottom,
                child: _EvaluateButton(
                  brand: _brand,
                  enabled: _controller.text.trim().length >= 10 && !_checking,
                  checking: _checking,
                  perfect: _analysis?.isFullyFormal ?? false,
                  onTap: _evaluate,
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confetti,
                  blastDirectionality: BlastDirectionality.explosive,
                  numberOfParticles: 24,
                  colors: const [
                    AppColors.indigo,
                    AppColors.success,
                    Color(0xFFFFD36A),
                    AppColors.purple,
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

class _Header extends StatelessWidget {
  final LearningMission mission;
  final Color brand;
  final VoidCallback onBack;

  const _Header({
    required this.mission,
    required this.brand,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.fromLTRB(16, 11, 18, 17),
      decoration: BoxDecoration(
        color: brand,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -52,
            top: -74,
            child: Container(
              width: 145,
              height: 145,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24),
              ),
            ),
          ),
          Row(
            children: [
              IconButton.filled(
                onPressed: onBack,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.ink,
                ),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mission.otherName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Mode Mandiri - ${mission.title}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  'Mandiri',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScenarioPrompt extends StatelessWidget {
  final LearningMission mission;
  final Color brand;

  const _ScenarioPrompt({required this.mission, required this.brand});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Color.lerp(brand, Colors.white, 0.91),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: brand.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const WikaMascot(
                  mood: WikaMood.hint,
                  size: 42,
                  animated: false,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TANTANGANMU',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: brand,
                      ),
                    ),
                    Text(
                      mission.title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        height: 1.2,
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
          Text(
            mission.independent.instruction,
            style: GoogleFonts.nunitoSans(
              fontSize: 14,
              height: 1.5,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          if (mission.objectives.isNotEmpty) ...[
            const SizedBox(height: 14),
            ...mission.objectives.indexed.map(
              (item) => Padding(
                padding: EdgeInsets.only(
                  bottom: item.$1 == mission.objectives.length - 1 ? 0 : 7,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: brand.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        '${item.$1 + 1}',
                        style: GoogleFonts.nunitoSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: brand,
                        ),
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        item.$2,
                        style: GoogleFonts.nunitoSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmailSubject extends StatelessWidget {
  final String subject;

  const _EmailSubject({required this.subject});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.alternate_email_rounded,
            size: 18,
            color: AppColors.purple,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Subjek: $subject',
              style: GoogleFonts.nunitoSans(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageComposer extends StatelessWidget {
  final TextEditingController controller;
  final String placeholder;
  final bool isEmail;
  final String contactName;
  final Color brand;
  final VoidCallback onChanged;

  const _MessageComposer({
    required this.controller,
    required this.placeholder,
    required this.isEmail,
    required this.contactName,
    required this.brand,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: brand.withValues(alpha: 0.28), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x100F172A),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Color.lerp(brand, Colors.white, 0.88),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isEmail
                      ? Icons.alternate_email_rounded
                      : Icons.chat_bubble_outline_rounded,
                  size: 18,
                  color: brand,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEmail ? 'TULIS EMAILMU' : 'TULISKAN PESANMU',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: brand,
                      ),
                    ),
                    Text(
                      'Untuk $contactName',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.softMint,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  'Maks. 600',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 20, color: AppColors.line),
          Expanded(
            child: TextField(
              controller: controller,
              maxLength: 600,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              onChanged: (_) => onChanged(),
              decoration: InputDecoration(
                hintText: placeholder,
                hintStyle: GoogleFonts.nunitoSans(
                  color: const Color(0xFFA8B0C5),
                  fontWeight: FontWeight.w700,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.only(top: 8),
              ),
              style: GoogleFonts.nunitoSans(
                fontSize: 14,
                height: 1.5,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormalityResult extends StatelessWidget {
  final FormalTextAnalysis analysis;

  const _FormalityResult({required this.analysis});

  Color get color => switch (analysis.score) {
    <= 50 => const Color(0xFFF07A45),
    <= 80 => const Color(0xFFB6B92E),
    _ => AppColors.success,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                analysis.isFullyFormal
                    ? Icons.verified_rounded
                    : Icons.tune_rounded,
                color: color,
              ),
              const SizedBox(width: 8),
              Text(
                'Indikator Formalitas',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: analysis.meterValue,
              minHeight: 13,
              backgroundColor: const Color(0xFFE8EAF1),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: 9),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _MeterLabel('Perlu dirapikan', active: analysis.score <= 50),
              _MeterLabel(
                'Hampir formal',
                active: analysis.score > 50 && analysis.score <= 80,
              ),
              _MeterLabel('Sangat formal', active: analysis.score > 80),
            ],
          ),
          const SizedBox(height: 13),
          Text(
            analysis.feedback,
            style: GoogleFonts.nunitoSans(
              fontSize: 13,
              height: 1.45,
              fontWeight: FontWeight.w900,
              color: AppColors.ink,
            ),
          ),
          if (!analysis.isFullyFormal) ...[
            const SizedBox(height: 8),
            Text(
              analysis.hint,
              style: GoogleFonts.nunitoSans(
                fontSize: 12,
                height: 1.45,
                fontWeight: FontWeight.w700,
                color: AppColors.text2,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MeterLabel extends StatelessWidget {
  final String text;
  final bool active;

  const _MeterLabel(this.text, {required this.active});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.nunitoSans(
          fontSize: 8,
          fontWeight: FontWeight.w900,
          color: active ? AppColors.ink : AppColors.muted,
        ),
      ),
    );
  }
}

class _ColorGuidance extends StatelessWidget {
  final FormalTextAnalysis analysis;

  const _ColorGuidance({required this.analysis});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFFCFCFE),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PANDUAN WARNA PESANMU',
            style: GoogleFonts.nunitoSans(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: AppColors.text2,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 7,
            children: analysis.tokens.map((token) {
              final palette = _rolePalette(token.role);
              return AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: palette.$1,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: token.misplaced ? palette.$2 : Colors.transparent,
                    width: token.misplaced ? 2 : 1,
                  ),
                  boxShadow: token.misplaced
                      ? [
                          BoxShadow(
                            color: palette.$2.withValues(alpha: 0.25),
                            blurRadius: 10,
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  token.text,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: palette.$2,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class SentenceTree extends StatelessWidget {
  final List<SentenceChunk> chunks;

  const SentenceTree({super.key, required this.chunks});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF9DE1C8)),
      ),
      child: Column(
        children: [
          Text(
            'Pohon Kalimat',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 9),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              color: AppColors.ink,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Kalimat Formal',
              style: GoogleFonts.nunitoSans(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
          Container(width: 2, height: 18, color: AppColors.line),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 9,
            children: chunks.map((chunk) {
              final palette = _rolePalette(chunk.role);
              return Container(
                constraints: const BoxConstraints(minWidth: 82, maxWidth: 150),
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: palette.$1,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: palette.$2.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      chunk.role,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        color: palette.$2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      chunk.text,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _EvaluateButton extends StatelessWidget {
  final Color brand;
  final bool enabled;
  final bool checking;
  final bool perfect;
  final VoidCallback onTap;

  const _EvaluateButton({
    required this.brand,
    required this.enabled,
    required this.checking,
    required this.perfect,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x241F2858),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: FilledButton.icon(
        onPressed: enabled ? onTap : null,
        icon: Icon(
          perfect ? Icons.verified_rounded : Icons.auto_awesome_rounded,
        ),
        label: Text(
          checking
              ? 'Merapikan pesan...'
              : perfect
              ? 'Periksa Lagi'
              : 'Lihat Formalitas',
        ),
        style: FilledButton.styleFrom(
          backgroundColor: perfect ? AppColors.success : brand,
          disabledBackgroundColor: const Color(0xFFD9DFED),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: GoogleFonts.nunitoSans(
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

(Color, Color) _rolePalette(String role) => switch (role) {
  'Subjek' => (AppColors.subject, AppColors.subjectInk),
  'Predikat' => (AppColors.predicate, AppColors.predicateInk),
  'Objek' => (AppColors.object, AppColors.objectInk),
  'Keterangan' => (AppColors.adverb, AppColors.adverbInk),
  'Pembuka' => (AppColors.complement, AppColors.complementInk),
  _ => (const Color(0xFFF1F3F8), AppColors.text2),
};
