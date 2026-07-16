import 'dart:async';
import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wicara_application_1/core/theme/app_colors.dart';
import 'package:wicara_application_1/core/utils/adaptive_scaffolding.dart';
import 'package:wicara_application_1/core/utils/card_arrangement.dart';
import 'package:wicara_application_1/features/guided_mode/widgets/revision3_scene.dart';
import 'package:wicara_application_1/models/revision3_content.dart';
import 'package:wicara_application_1/services/api_service.dart';
import 'package:wicara_application_1/widgets/wika_mascot.dart';

class Revision3GuidedVnScreen extends StatefulWidget {
  final LearningBilik bilik;
  final LearningMission mission;

  const Revision3GuidedVnScreen({
    super.key,
    required this.bilik,
    required this.mission,
  });

  @override
  State<Revision3GuidedVnScreen> createState() =>
      _Revision3GuidedVnScreenState();
}

class _Revision3GuidedVnScreenState extends State<Revision3GuidedVnScreen>
    with SingleTickerProviderStateMixin {
  late final List<_SceneStep> _sequence;
  late final ConfettiController _confetti;
  late final AnimationController _glow;
  int _screen = 0;
  int _frameIndex = 0;
  int _sequenceIndex = 0;
  int _dialogIndex = 0;
  int _roundWrongAttempts = 0;
  int _worstAttemptNumber = 1;
  bool _roundCorrect = false;
  bool _saving = false;
  bool _animatingGuidance = false;
  bool _checking = false;
  String? _feedback;
  ScaffoldLevel _activeScaffold = ScaffoldLevel.p1Visual;
  List<int> _lastErrorPositions = const [];
  DateTime _roundStartedAt = DateTime.now();
  List<_CardEntry> _pool = [];
  final List<_CardEntry> _answer = [];

  LearningMission get mission => widget.mission;
  GuidedContent get guided => mission.guided;
  Color get brand =>
      widget.bilik.isSchool ? AppColors.indigo : AppColors.purple;
  Color get brandDark =>
      widget.bilik.isSchool ? AppColors.indigoDark : AppColors.purpleDark;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
    _glow = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1150),
    )..repeat(reverse: true);
    _sequence = _buildSequence();
  }

  @override
  void dispose() {
    _confetti.dispose();
    _glow.dispose();
    super.dispose();
  }

  List<_SceneStep> _buildSequence() {
    final sequence = <_SceneStep>[_SceneStep.dialog(guided.opening)];
    for (var index = 0; index < guided.rounds.length; index++) {
      sequence.add(_SceneStep.round(index));
      if (index < guided.rounds.length - 1) {
        sequence.add(_SceneStep.dialog(guided.responses[index]));
      }
    }
    sequence.add(_SceneStep.dialog(guided.ending));
    return sequence;
  }

  _SceneStep get _currentStep => _sequence[_sequenceIndex];

  void _startStory() {
    setState(() {
      _screen = guided.frames.isEmpty ? 2 : 1;
      _frameIndex = 0;
    });
    if (_screen == 2) _prepareStep();
  }

  void _advanceFrame() {
    if (_frameIndex < guided.frames.length - 1) {
      setState(() => _frameIndex++);
      return;
    }
    setState(() => _screen = 2);
    _prepareStep();
  }

  void _prepareStep() {
    _dialogIndex = 0;
    _feedback = null;
    _roundCorrect = false;
    _roundWrongAttempts = 0;
    _activeScaffold = ScaffoldLevel.p1Visual;
    _lastErrorPositions = const [];
    _animatingGuidance = false;
    _checking = false;
    _roundStartedAt = DateTime.now();
    _answer.clear();
    final roundIndex = _currentStep.roundIndex;
    if (roundIndex != null) {
      final round = guided.rounds[roundIndex];
      _pool = List.generate(
        round.cards.length,
        (index) => _CardEntry(index, round.cards[index]),
      )..shuffle(Random(mission.order * 97 + roundIndex * 31));
    }
    if (mounted) setState(() {});
  }

  void _advanceDialog() {
    final dialogs = _currentStep.dialogs ?? const <DialogLine>[];
    if (_dialogIndex < dialogs.length - 1) {
      setState(() => _dialogIndex++);
      return;
    }
    _advanceSequence();
  }

  void _advanceSequence() {
    if (_sequenceIndex < _sequence.length - 1) {
      setState(() => _sequenceIndex++);
      _prepareStep();
      return;
    }
    _finishRun();
  }

  void _selectCard(_CardEntry entry) {
    if (_roundCorrect || _animatingGuidance || _checking) return;
    final roundIndex = _currentStep.roundIndex;
    if (roundIndex == null ||
        !_isEntryEnabled(entry, guided.rounds[roundIndex])) {
      return;
    }
    final round = guided.rounds[roundIndex];
    _placeCard(entry, _answer.length, round);
  }

  void _placeCard(_CardEntry entry, int slotIndex, GuidedRound round) {
    if (_roundCorrect || _animatingGuidance || _checking) return;
    if (!_answer.contains(entry) && !_isEntryEnabled(entry, round)) return;
    final next = arrangeCardInSlots(
      current: _answer,
      card: entry,
      slotIndex: slotIndex,
      capacity: round.target.length,
    );
    if (next == null) return;
    setState(() {
      _pool.remove(entry);
      _answer
        ..clear()
        ..addAll(next);
      _feedback = null;
      _lastErrorPositions = const [];
    });
  }

  void _removeCard(_CardEntry entry) {
    if (_roundCorrect || _animatingGuidance || _checking) return;
    setState(() {
      _answer.remove(entry);
      _pool.add(entry);
      _feedback = null;
    });
  }

  bool _isEntryEnabled(_CardEntry entry, GuidedRound round) {
    if (_activeScaffold != ScaffoldLevel.p4Constraint ||
        _roundWrongAttempts < 3) {
      return true;
    }
    if (_answer.length >= round.target.length) return false;
    return entry.card.text == round.target[_answer.length];
  }

  void _returnCardsToPool(GuidedRound round) {
    final allCards = <_CardEntry>[..._pool, ..._answer];
    allCards.sort((a, b) {
      final aIndex = round.target.indexOf(a.card.text);
      final bIndex = round.target.indexOf(b.card.text);
      final aOrder = aIndex < 0 ? 1000 + a.id : aIndex;
      final bOrder = bIndex < 0 ? 1000 + b.id : bIndex;
      return aOrder.compareTo(bOrder);
    });
    _answer.clear();
    _pool = allCards;
  }

  Future<void> _applyScaffolding(
    GuidedRound round,
    ScaffoldLevel executedLevel,
  ) async {
    setState(() => _animatingGuidance = true);
    if (executedLevel == ScaffoldLevel.p1Visual) {
      await Future<void>.delayed(const Duration(milliseconds: 720));
    } else {
      await Future<void>.delayed(const Duration(milliseconds: 260));
    }
    if (!mounted) return;
    setState(() {
      _returnCardsToPool(round);
      _activeScaffold = scaffoldForWrongAttempt(_roundWrongAttempts + 1);
      _feedback = _activeScaffold.message;
      _animatingGuidance = false;
    });
  }

  Future<void> _checkRound() async {
    if (_checking || _animatingGuidance) return;
    final roundIndex = _currentStep.roundIndex!;
    final round = guided.rounds[roundIndex];
    if (!isCardArrangementReady(
      cardCount: _answer.length,
      capacity: round.target.length,
    )) {
      return;
    }
    final submitted = _answer.map((entry) => entry.card.text).toList();
    final analysis = analyzeGuidedAttempt(submitted, round.target);
    final attemptNumber = _roundWrongAttempts + 1;
    final durationMs = DateTime.now()
        .difference(_roundStartedAt)
        .inMilliseconds;
    setState(() => _checking = true);

    if (!analysis.isCorrect) {
      _roundWrongAttempts++;
      final executedLevel = scaffoldForWrongAttempt(_roundWrongAttempts);
      setState(() {
        _feedback = executedLevel.message;
        _roundCorrect = false;
        _lastErrorPositions = analysis.mismatchedPositions;
        _checking = false;
      });
      unawaited(
        ApiService.logAttempt(
          false,
          analysis.mismatchedPositions,
          bilikId: mission.progressBilikId,
          levelId: mission.order,
          score: (100 * (1 - analysis.cardAnalysis.errorRate)).clamp(0, 100),
          wer: analysis.cardAnalysis.errorRate,
          stars: 0,
          rawArrangement: submitted,
          errorTypes: analysis.errorTypes,
          attemptNumber: attemptNumber,
          durationMs: durationMs,
          assistanceLevel: executedLevel.code,
          persistStars: false,
        ),
      );
      await _applyScaffolding(round, executedLevel);
      return;
    }

    final earnedStars = starsForSuccessfulAttempt(attemptNumber);
    _worstAttemptNumber = max(_worstAttemptNumber, attemptNumber);
    setState(() {
      _roundCorrect = true;
      _checking = false;
      _lastErrorPositions = const [];
      _feedback = switch (earnedStars) {
        3 => 'Sempurna! Susunan pesanmu tepat sejak awal.',
        2 => 'Hebat! Kamu berhasil setelah membaca petunjuk lembut.',
        _ => 'Usaha bagus! Kamu mengikuti pola sampai susunannya tepat.',
      };
    });
    _confetti.play();
    unawaited(
      ApiService.logAttempt(
        true,
        const [],
        bilikId: mission.progressBilikId,
        levelId: mission.order,
        score: 100,
        wer: 0,
        stars: earnedStars,
        rawArrangement: submitted,
        attemptNumber: attemptNumber,
        durationMs: durationMs,
        assistanceLevel: _activeScaffold.code,
        persistStars: false,
      ),
    );
  }

  int get _stars => starsForSuccessfulAttempt(_worstAttemptNumber);

  void _showHint() {
    final round = guided.rounds[_currentStep.roundIndex!];
    setState(() {
      _feedback = round.hintText;
    });
  }

  Future<void> _finishRun() async {
    if (_saving) return;
    setState(() => _saving = true);
    await ApiService.updateProgress(
      mission.progressBilikId,
      mission.order,
      'completed',
    );
    await ApiService.logAttempt(
      true,
      const [],
      bilikId: mission.progressBilikId,
      levelId: mission.order,
      score: 100,
      wer: 0,
      stars: _stars,
      attemptNumber: _worstAttemptNumber,
      assistanceLevel: scaffoldForWrongAttempt(_worstAttemptNumber).code,
      eventType: 'guided_mission_complete',
    );
    if (!mounted) return;
    setState(() {
      _saving = false;
      _screen = 3;
    });
    _confetti.play();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) => Center(
          child: SizedBox(
            width: min(430, constraints.maxWidth),
            height: constraints.maxHeight,
            child: Stack(
              children: [
                Positioned.fill(child: _buildScreen()),
                Align(
                  alignment: Alignment.topCenter,
                  child: ConfettiWidget(
                    confettiController: _confetti,
                    blastDirectionality: BlastDirectionality.explosive,
                    emissionFrequency: 0.05,
                    numberOfParticles: 20,
                    colors: const [
                      AppColors.indigo,
                      AppColors.purple,
                      Color(0xFFFFD36A),
                      AppColors.success,
                      AppColors.danger,
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

  Widget _buildScreen() {
    return switch (_screen) {
      0 => _IntroScreen(mission: mission, brand: brand, onStart: _startStory),
      1 => _ContextScreen(
        mission: mission,
        frame: guided.frames[_frameIndex],
        frameIndex: _frameIndex,
        totalFrames: guided.frames.length,
        brand: brand,
        onBack: () => setState(() {
          if (_frameIndex > 0) {
            _frameIndex--;
          } else {
            _screen = 0;
          }
        }),
        onNext: _advanceFrame,
      ),
      2 => _currentStep.roundIndex == null ? _buildDialog() : _buildRound(),
      _ => _ResultScreen(
        mission: mission,
        stars: _stars,
        onDone: () => Navigator.pop(context, true),
      ),
    };
  }

  Widget _sceneImage({
    double height = 220,
    String expression = 'neutral',
    bool showOther = false,
  }) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Revision3Scene(
        mission: mission,
        studentExpression: expression,
        showOther: showOther,
      ),
    );
  }

  Widget _buildDialog() {
    final dialogs = _currentStep.dialogs!;
    if (dialogs.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _advanceSequence());
      return const SizedBox.shrink();
    }
    final line = dialogs[_dialogIndex];
    final speaker = switch (line.who) {
      'wika' => 'Wika',
      'other' => mission.otherName,
      _ => mission.studentName,
    };
    final color = switch (line.who) {
      'wika' => AppColors.purple,
      'other' => brand,
      _ => AppColors.success,
    };

    return SafeArea(
      child: Column(
        children: [
          Stack(
            children: [
              _sceneImage(
                height: 315,
                expression: line.who == 'student' ? 'thinking' : 'neutral',
                showOther: dialogs.any((dialog) => dialog.who == 'other'),
              ),
              Positioned(
                left: 14,
                top: 12,
                child: _OverlayButton(
                  icon: Icons.close_rounded,
                  onTap: () => Navigator.pop(context),
                ),
              ),
              Positioned(
                left: 14,
                right: 14,
                bottom: 13,
                child: Row(
                  children: [
                    _ProgressPill(
                      current: _completedRounds,
                      total: guided.rounds.length,
                    ),
                    const Spacer(),
                    Text(
                      '${_dialogIndex + 1}/${dialogs.length}',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x1F1F2858),
                    blurRadius: 28,
                    offset: Offset(0, -8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      if (line.who == 'wika')
                        const Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: WikaMascot(
                            mood: WikaMood.hint,
                            size: 42,
                            animated: false,
                          ),
                        ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          speaker,
                          style: GoogleFonts.nunitoSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    line.text,
                    style: GoogleFonts.nunitoSans(
                      fontSize: 18,
                      height: 1.48,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  const Spacer(),
                  _ChunkyButton(
                    color: brand,
                    shadow: brandDark,
                    icon: Icons.arrow_forward_rounded,
                    label:
                        _sequenceIndex == _sequence.length - 1 &&
                            _dialogIndex == dialogs.length - 1
                        ? 'Lihat Hasil'
                        : 'Lanjut',
                    onTap: _advanceDialog,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  int get _completedRounds => _sequence
      .take(_sequenceIndex)
      .where((step) => step.roundIndex != null)
      .length;

  bool _canPlaceCard(_CardEntry entry, int slotIndex, GuidedRound round) {
    if (_roundCorrect || _animatingGuidance || _checking) return false;
    if (slotIndex < 0 || slotIndex >= round.target.length) return false;
    if (_answer.contains(entry)) return true;
    if (_answer.length >= round.target.length) return false;
    return _isEntryEnabled(entry, round);
  }

  Widget _buildAnswerSlots(GuidedRound round) {
    final firstOpenSlot = _answer.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (_answer.isEmpty) ...[
          Icon(
            Icons.pan_tool_alt_rounded,
            size: 24,
            color: AppColors.warning.withValues(alpha: 0.55),
          ),
          const SizedBox(height: 5),
          Text(
            'Tarik kartu ke sini',
            style: GoogleFonts.nunitoSans(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.warning,
            ),
          ),
          const SizedBox(height: 10),
        ],
        Wrap(
          spacing: 7,
          runSpacing: 8,
          children: List.generate(round.target.length, (index) {
            final entry = index < _answer.length ? _answer[index] : null;
            final glow =
                _roundWrongAttempts >= 1 &&
                _activeScaffold == ScaffoldLevel.p2Soft &&
                index == firstOpenSlot;
            final showGhost =
                _roundWrongAttempts >= 2 &&
                _activeScaffold == ScaffoldLevel.p3Hard &&
                index == firstOpenSlot;
            final hasError =
                _animatingGuidance && _lastErrorPositions.contains(index);
            return DragTarget<_CardEntry>(
              onWillAcceptWithDetails: (details) =>
                  _canPlaceCard(details.data, index, round),
              onAcceptWithDetails: (details) =>
                  _placeCard(details.data, index, round),
              builder: (context, candidates, rejected) => AnimatedBuilder(
                animation: _glow,
                builder: (context, child) => _AnswerSlot(
                  index: index,
                  entry: entry,
                  label: index < round.slotLabels.length
                      ? round.slotLabels[index]
                      : 'Slot ${index + 1}',
                  ghostText: showGhost ? round.target[index] : null,
                  glowStrength: glow ? 0.35 + (_glow.value * 0.55) : 0,
                  highlighted: candidates.isNotEmpty,
                  hasError: hasError,
                  onTap: entry == null ? null : () => _removeCard(entry),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildPoolCard(_CardEntry entry, GuidedRound round) {
    final enabled =
        _answer.length < round.target.length && _isEntryEnabled(entry, round);
    final card = _WordCard(
      entry: entry,
      enabled: enabled,
      onTap: enabled ? () => _selectCard(entry) : null,
    );
    if (!enabled) return card;
    return LongPressDraggable<_CardEntry>(
      data: entry,
      delay: const Duration(milliseconds: 120),
      feedback: Material(
        color: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 180),
          child: _WordCard(entry: entry, selected: true),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.28, child: card),
      child: card,
    );
  }

  Widget _buildRound() {
    final roundIndex = _currentStep.roundIndex!;
    final round = guided.rounds[roundIndex];
    final isReady = isCardArrangementReady(
      cardCount: _answer.length,
      capacity: round.target.length,
    );
    final remainingSlots = round.target.length - _answer.length;
    return SafeArea(
      child: Column(
        children: [
          Stack(
            children: [
              _sceneImage(height: 228, showOther: true),
              Positioned(
                left: 14,
                top: 12,
                child: _OverlayButton(
                  icon: Icons.close_rounded,
                  onTap: () => Navigator.pop(context),
                ),
              ),
              Positioned(
                left: 14,
                right: 14,
                bottom: 12,
                child: _ProgressPill(
                  current: roundIndex,
                  total: guided.rounds.length,
                ),
              ),
            ],
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 17, 18, 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x181F2858),
                    blurRadius: 26,
                    offset: Offset(0, -7),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: brand,
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(
                            round.title,
                            style: GoogleFonts.nunitoSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: _showHint,
                          icon: const Icon(
                            Icons.lightbulb_outline_rounded,
                            size: 17,
                          ),
                          label: const Text('Petunjuk'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.purple,
                            textStyle: GoogleFonts.nunitoSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      round.objective,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 17,
                        height: 1.28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 14),
                    CustomPaint(
                      painter: _DashedBoardPainter(
                        _roundCorrect
                            ? AppColors.success
                            : const Color(0xFFAFC8FF),
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 320),
                        constraints: const BoxConstraints(minHeight: 190),
                        padding: const EdgeInsets.fromLTRB(16, 15, 16, 17),
                        decoration: BoxDecoration(
                          color: _roundCorrect
                              ? AppColors.softMint
                              : const Color(0xFFFFFAEF),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Susun jawaban ${widget.bilik.isSchool ? 'Raka' : 'Naya'}',
                                        style: GoogleFonts.nunitoSans(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w900,
                                          color: const Color(0xFF8A6300),
                                        ),
                                      ),
                                      Text(
                                        'Tarik kartu ke papan ini, atau ketuk kartunya',
                                        style: GoogleFonts.nunitoSans(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFFB07A22),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white70,
                                    borderRadius: BorderRadius.circular(99),
                                  ),
                                  child: Text(
                                    '${_answer.length}/${round.target.length}',
                                    style: GoogleFonts.nunitoSans(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.warning,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Center(child: _buildAnswerSlots(round)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'KARTU KATA',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: AppColors.text2,
                      ),
                    ),
                    const SizedBox(height: 7),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final cardWidth = (constraints.maxWidth - 9) / 2;
                        return Wrap(
                          spacing: 9,
                          runSpacing: 10,
                          children: _pool
                              .map(
                                (entry) => SizedBox(
                                  width: entry.card.text.length > 15
                                      ? constraints.maxWidth
                                      : cardWidth,
                                  child: _buildPoolCard(entry, round),
                                ),
                              )
                              .toList(),
                        );
                      },
                    ),
                    if (_feedback != null) ...[
                      const SizedBox(height: 13),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _roundCorrect
                              ? AppColors.softMint
                              : AppColors.softYellow,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _roundCorrect
                                ? const Color(0xFF9DE1C8)
                                : const Color(0xFFF1D178),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              _roundCorrect
                                  ? Icons.check_circle_rounded
                                  : Icons.lightbulb_rounded,
                              size: 20,
                              color: _roundCorrect
                                  ? AppColors.success
                                  : AppColors.warning,
                            ),
                            const SizedBox(width: 9),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (!_roundCorrect)
                                    Text(
                                      _activeScaffold.title,
                                      style: GoogleFonts.nunitoSans(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        color: brand,
                                      ),
                                    ),
                                  Text(
                                    _feedback!,
                                    style: GoogleFonts.nunitoSans(
                                      fontSize: 12,
                                      height: 1.4,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.ink,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 15),
                    _ChunkyButton(
                      color: _roundCorrect ? AppColors.success : brand,
                      shadow: _roundCorrect
                          ? const Color(0xFF14744F)
                          : brandDark,
                      icon: _roundCorrect
                          ? Icons.arrow_forward_rounded
                          : Icons.check_rounded,
                      label: _roundCorrect
                          ? 'Lanjutkan Cerita'
                          : _animatingGuidance || _checking
                          ? 'Kembali Menyusun...'
                          : isReady
                          ? 'Cek Jawaban'
                          : 'Isi $remainingSlots slot lagi',
                      onTap: _roundCorrect
                          ? _advanceSequence
                          : _animatingGuidance || _checking
                          ? null
                          : !isReady
                          ? null
                          : _checkRound,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SceneStep {
  final List<DialogLine>? dialogs;
  final int? roundIndex;

  const _SceneStep._({this.dialogs, this.roundIndex});

  factory _SceneStep.dialog(List<DialogLine> dialogs) =>
      _SceneStep._(dialogs: dialogs);
  factory _SceneStep.round(int index) => _SceneStep._(roundIndex: index);
}

class _CardEntry {
  final int id;
  final LearningWordCard card;

  const _CardEntry(this.id, this.card);
}

class _IntroScreen extends StatelessWidget {
  final LearningMission mission;
  final Color brand;
  final VoidCallback onStart;

  const _IntroScreen({
    required this.mission,
    required this.brand,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final dark = mission.isSchool ? AppColors.indigoDark : AppColors.purpleDark;
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            flex: 5,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Revision3Scene(
                  mission: mission,
                  frame: 0,
                  studentExpression: mission.id == 'sekolah-1'
                      ? 'sick'
                      : 'thinking',
                ),
                Positioned(
                  left: 20,
                  top: 48,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(99),
                      boxShadow: const [
                        BoxShadow(color: Color(0x14000000), blurRadius: 8),
                      ],
                    ),
                    child: Text(
                      '🎮 Mode Terpandu',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: AppColors.indigo,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 20,
                  right: 20,
                  top: 96,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: brand,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          'Kasus ${mission.order}',
                          style: GoogleFonts.nunitoSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 7),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.86),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          mission.isSchool
                              ? 'Bilik Sekolah'
                              : 'Bilik Profesional',
                          style: GoogleFonts.nunitoSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x1F1F2858),
                    blurRadius: 28,
                    offset: Offset(0, -8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    mission.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      height: 1.2,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Bantu ${mission.studentName} menyampaikan pesannya dengan jelas dan sopan.',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 12,
                      height: 1.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text2,
                    ),
                  ),
                  const SizedBox(height: 13),
                  ...mission.objectives.asMap().entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 7),
                      child: Row(
                        children: [
                          Container(
                            width: 23,
                            height: 23,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: AppColors.softBlue,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${entry.key + 1}',
                              style: GoogleFonts.nunitoSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: AppColors.indigo,
                              ),
                            ),
                          ),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Text(
                              entry.value,
                              style: GoogleFonts.nunitoSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.text2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  _ChunkyButton(
                    color: brand,
                    shadow: dark,
                    icon: Icons.play_arrow_rounded,
                    label: 'Mulai Cerita',
                    onTap: onStart,
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Kembali ke Peta',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.muted,
                      ),
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

class _ContextScreen extends StatelessWidget {
  final LearningMission mission;
  final ContextFrame frame;
  final int frameIndex;
  final int totalFrames;
  final Color brand;
  final VoidCallback onBack;
  final VoidCallback onNext;

  const _ContextScreen({
    required this.mission,
    required this.frame,
    required this.frameIndex,
    required this.totalFrames,
    required this.brand,
    required this.onBack,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final dark = mission.isSchool ? AppColors.indigoDark : AppColors.purpleDark;
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            flex: 6,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Revision3Scene(
                  mission: mission,
                  frame: frameIndex,
                  studentExpression: frame.expression,
                ),
                Positioned(
                  left: 14,
                  top: 12,
                  child: _OverlayButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: onBack,
                  ),
                ),
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 18,
                  child: Column(
                    children: [
                      Row(
                        children: List.generate(
                          totalFrames,
                          (index) => Expanded(
                            child: Container(
                              height: 5,
                              margin: EdgeInsets.only(
                                right: index == totalFrames - 1 ? 0 : 6,
                              ),
                              decoration: BoxDecoration(
                                color: index <= frameIndex
                                    ? const Color(0xFFFFD36A)
                                    : Colors.white38,
                                borderRadius: BorderRadius.circular(99),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.ink.withValues(alpha: 0.82),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          frame.caption,
                          style: GoogleFonts.nunitoSans(
                            fontSize: 15,
                            height: 1.42,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
              child: Column(
                children: [
                  Row(
                    children: [
                      const WikaMascot(
                        mood: WikaMood.point,
                        size: 54,
                        animated: false,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          frameIndex == totalFrames - 1
                              ? 'Siap membantu ${mission.studentName}?'
                              : 'Perhatikan situasinya, ya.',
                          style: GoogleFonts.nunitoSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  _ChunkyButton(
                    color: brand,
                    shadow: dark,
                    icon: Icons.arrow_forward_rounded,
                    label: frameIndex == totalFrames - 1
                        ? 'Mulai Percakapan'
                        : 'Lanjut',
                    onTap: onNext,
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

class _ResultScreen extends StatelessWidget {
  final LearningMission mission;
  final int stars;
  final VoidCallback onDone;

  const _ResultScreen({
    required this.mission,
    required this.stars,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 36, 20, 28),
        child: Column(
          children: [
            const WikaMascot(
              mood: WikaMood.celebrate,
              size: 92,
              animated: true,
            ),
            const SizedBox(height: 14),
            Text(
              'Misi Selesai!',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 27,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              'Pesanmu sudah sopan, jelas, dan rapi.',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunitoSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.text2,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Icon(
                    Icons.star_rounded,
                    size: 43,
                    color: index < stars
                        ? const Color(0xFFFFD36A)
                        : const Color(0xFFDDE2F0),
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.softMint,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '+${mission.rewardXp} XP',
                style: GoogleFonts.nunitoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: AppColors.success,
                ),
              ),
            ),
            const SizedBox(height: 22),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.softBlue,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFC4CBDF)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PESAN LENGKAP',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: AppColors.indigo,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    mission.guided.fullMessage,
                    style: GoogleFonts.nunitoSans(
                      fontSize: 13,
                      height: 1.48,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 13),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: stars == 3
                    ? AppColors.softPurple
                    : const Color(0xFFF7F8FC),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: stars == 3 ? const Color(0xFFD8CCFA) : AppColors.line,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    stars == 3
                        ? Icons.lock_open_rounded
                        : Icons.lock_outline_rounded,
                    color: stars == 3 ? AppColors.purple : AppColors.muted,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      stars == 3
                          ? 'Mode Mandiri untuk kasus ini telah terbuka.'
                          : 'Raih 3 bintang untuk membuka Mode Mandiri.',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            _ChunkyButton(
              color: AppColors.indigo,
              shadow: AppColors.indigoDark,
              icon: Icons.map_rounded,
              label: 'Kembali ke Peta Kasus',
              onTap: onDone,
            ),
          ],
        ),
      ),
    );
  }
}

class _AnswerSlot extends StatelessWidget {
  final int index;
  final _CardEntry? entry;
  final String label;
  final String? ghostText;
  final double glowStrength;
  final bool highlighted;
  final bool hasError;
  final VoidCallback? onTap;

  const _AnswerSlot({
    required this.index,
    required this.entry,
    required this.label,
    required this.ghostText,
    required this.glowStrength,
    required this.highlighted,
    required this.hasError,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = hasError
        ? AppColors.danger
        : highlighted || glowStrength > 0
        ? const Color(0xFF73A7FF)
        : const Color(0xFFB9C2D8);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      width: 108,
      constraints: const BoxConstraints(minHeight: 70),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: glowStrength > 0
            ? const Color(0xFFEAF2FF).withValues(alpha: 0.55)
            : Colors.transparent,
        boxShadow: glowStrength > 0
            ? [
                BoxShadow(
                  color: const Color(
                    0xFF73A7FF,
                  ).withValues(alpha: glowStrength),
                  blurRadius: 18,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: CustomPaint(
        painter: _DashedSlotPainter(borderColor),
        child: Padding(
          padding: const EdgeInsets.all(7),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                switchInCurve: Curves.easeOutBack,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween<double>(
                      begin: 0.86,
                      end: 1,
                    ).animate(animation),
                    child: child,
                  ),
                ),
                child: entry != null
                    ? KeyedSubtree(
                        key: ValueKey('answer-${entry!.id}-$index'),
                        child: LongPressDraggable<_CardEntry>(
                          data: entry,
                          delay: const Duration(milliseconds: 120),
                          feedback: Material(
                            color: Colors.transparent,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 180),
                              child: _WordCard(entry: entry!, selected: true),
                            ),
                          ),
                          childWhenDragging: Opacity(
                            opacity: 0.24,
                            child: _WordCard(
                              entry: entry!,
                              selected: true,
                              compact: true,
                            ),
                          ),
                          child: SizedBox(
                            width: 90,
                            child: _WordCard(
                              entry: entry!,
                              selected: true,
                              compact: true,
                              onTap: onTap,
                            ),
                          ),
                        ),
                      )
                    : ghostText != null
                    ? Opacity(
                        key: ValueKey('ghost-$index-$ghostText'),
                        opacity: 0.36,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.subject,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFF4D91FF),
                              width: 2,
                            ),
                          ),
                          child: Text(
                            ghostText!,
                            textAlign: TextAlign.center,
                            softWrap: true,
                            style: GoogleFonts.nunitoSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: AppColors.subjectInk,
                            ),
                          ),
                        ),
                      )
                    : Icon(
                        key: ValueKey('empty-$index'),
                        Icons.add_rounded,
                        size: 17,
                        color: borderColor.withValues(alpha: 0.7),
                      ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 2,
                textAlign: TextAlign.center,
                softWrap: true,
                style: GoogleFonts.nunitoSans(
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedSlotPainter extends CustomPainter {
  final Color color;

  const _DashedSlotPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(14)),
      );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, min(distance + 6, metric.length)),
          paint,
        );
        distance += 10;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedSlotPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _DashedBoardPainter extends CustomPainter {
  final Color color;

  const _DashedBoardPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(24)),
      );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, min(distance + 7, metric.length)),
          paint,
        );
        distance += 11;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBoardPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _WordCard extends StatelessWidget {
  final _CardEntry entry;
  final bool selected;
  final bool enabled;
  final bool compact;
  final VoidCallback? onTap;

  const _WordCard({
    required this.entry,
    this.selected = false,
    this.enabled = true,
    this.compact = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = _cardPalette(entry.card.kind);
    final label = _kindLabel(entry.card.kind);
    final labelChip = Container(
      constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: enabled ? palette.border : const Color(0xFF475467),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: GoogleFonts.nunitoSans(
          fontSize: compact ? 8 : 9,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
    );
    final word = Text(
      entry.card.text,
      textAlign: compact ? TextAlign.center : TextAlign.start,
      softWrap: true,
      style: GoogleFonts.nunitoSans(
        fontSize: compact ? 11 : 13,
        height: 1.15,
        fontWeight: FontWeight.w900,
        color: enabled ? palette.text : AppColors.muted,
      ),
    );
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 240),
      opacity: enabled ? 1 : 0.38,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(17),
          child: Ink(
            padding: compact
                ? const EdgeInsets.fromLTRB(6, 7, 6, 7)
                : const EdgeInsets.fromLTRB(9, 10, 8, 10),
            decoration: BoxDecoration(
              color: enabled ? palette.background : const Color(0xFFE4E7EE),
              borderRadius: BorderRadius.circular(17),
              border: Border.all(
                color: enabled ? palette.border : AppColors.muted,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: enabled
                      ? palette.border.withValues(alpha: selected ? 0.38 : 0.28)
                      : AppColors.muted.withValues(alpha: 0.18),
                  blurRadius: 0,
                  offset: const Offset(0, 5),
                ),
                const BoxShadow(
                  color: Color(0x0A0F172A),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: compact
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [labelChip, const SizedBox(height: 5), word],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      labelChip,
                      const SizedBox(width: 7),
                      Expanded(child: word),
                      const SizedBox(width: 5),
                      Icon(
                        Icons.drag_indicator_rounded,
                        size: 18,
                        color: enabled
                            ? palette.text.withValues(alpha: 0.42)
                            : AppColors.muted.withValues(alpha: 0.35),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _CardPalette {
  final Color background;
  final Color border;
  final Color text;

  const _CardPalette(this.background, this.border, this.text);
}

_CardPalette _cardPalette(String kind) {
  return switch (kind) {
    's' || 'salam' || 'hormat' => const _CardPalette(
      AppColors.subject,
      Color(0xFF4D91FF),
      AppColors.subjectInk,
    ),
    'p' => const _CardPalette(
      AppColors.predicate,
      AppColors.danger,
      AppColors.predicateInk,
    ),
    'o' => const _CardPalette(
      AppColors.object,
      AppColors.success,
      AppColors.objectInk,
    ),
    'k' || 'waktu' => const _CardPalette(
      AppColors.adverb,
      AppColors.warning,
      AppColors.adverbInk,
    ),
    'pel' || 'sapaan' => const _CardPalette(
      AppColors.complement,
      Color(0xFF7C3AED),
      AppColors.complementInk,
    ),
    _ => const _CardPalette(Colors.white, Color(0xFFC4CBDF), AppColors.ink),
  };
}

String _kindLabel(String kind) {
  return switch (kind) {
    's' => 'S',
    'p' => 'P',
    'o' => 'O',
    'k' => 'K',
    'pel' => 'Pel',
    'salam' => 'Salam',
    'waktu' => 'Waktu',
    'sapaan' => 'Sapaan',
    'hormat' => 'Hormat',
    _ => '?',
  };
}

class _ProgressPill extends StatelessWidget {
  final int current;
  final int total;

  const _ProgressPill({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.ink.withValues(alpha: 0.48),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${current.clamp(0, total)}/$total ronde',
            style: GoogleFonts.nunitoSans(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          ...List.generate(
            total,
            (index) => Container(
              width: 7,
              height: 7,
              margin: const EdgeInsets.only(left: 3),
              decoration: BoxDecoration(
                color: index < current
                    ? const Color(0xFFFFD36A)
                    : Colors.white38,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OverlayButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _OverlayButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, size: 20, color: AppColors.ink),
        ),
      ),
    );
  }
}

class _ChunkyButton extends StatelessWidget {
  final Color color;
  final Color shadow;
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ChunkyButton({
    required this.color,
    required this.shadow,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Container(
      height: 56,
      decoration: enabled
          ? BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: shadow, offset: const Offset(0, 6))],
            )
          : BoxDecoration(
              color: const Color(0xFFDDE2F0),
              borderRadius: BorderRadius.circular(20),
            ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: GoogleFonts.nunitoSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: enabled ? Colors.white : AppColors.muted,
                ),
              ),
              const SizedBox(width: 7),
              Icon(
                icon,
                size: 19,
                color: enabled ? Colors.white : AppColors.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
