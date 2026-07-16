import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wicara_application_1/core/theme/app_colors.dart';
import 'package:wicara_application_1/core/utils/spok_analyzer.dart';
import 'package:wicara_application_1/features/guided_mode/widgets/feedback_panel.dart';
import 'package:wicara_application_1/features/guided_mode/widgets/spok_legend.dart';
import 'package:wicara_application_1/features/guided_mode/widgets/word_card.dart';
import 'package:wicara_application_1/models/bilik.dart';
import 'package:wicara_application_1/services/api_service.dart';

class GuidedCardModeScreen extends StatefulWidget {
  final Bilik bilik;
  final BilikLevel level;

  const GuidedCardModeScreen({
    super.key,
    required this.bilik,
    required this.level,
  });

  @override
  State<GuidedCardModeScreen> createState() => _GuidedCardModeScreenState();
}

class _GuidedCardModeScreenState extends State<GuidedCardModeScreen> {
  late List<String> _available;
  final List<String> _answer = [];
  CardAnalysis? _analysis;
  bool _saving = false;

  Color get _brand =>
      widget.bilik.id == 'akademik' ? AppColors.indigo : AppColors.purple;

  @override
  void initState() {
    super.initState();
    _reset();
  }

  void _reset() {
    _available = List<String>.from(widget.level.tokens)
      ..shuffle(Random(widget.level.id * 37 + widget.bilik.id.length));
    _answer.clear();
    _analysis = null;
  }

  String _roleFor(String token) => widget.level.tokenRoles[token] ?? 'k';

  void _addToken(String token) {
    if (_analysis?.isCorrect == true) return;
    setState(() {
      _available.remove(token);
      _answer.add(token);
      _analysis = null;
    });
  }

  void _removeToken(int index) {
    if (_analysis?.isCorrect == true) return;
    setState(() {
      _available.add(_answer.removeAt(index));
      _analysis = null;
    });
  }

  bool _hasErrorAt(int index) {
    final analysis = _analysis;
    if (analysis == null || analysis.isCorrect) return false;
    final result = analysis.cards
        .where((item) => item.studentIndex == index)
        .firstOrNull;
    return result != null && !result.isCorrect;
  }

  Future<void> _checkAnswer() async {
    final analysis = analyzeCardErrors(_answer, widget.level.tokens);
    setState(() {
      _analysis = analysis;
    });

    final mismatches = analysis.cards
        .where((card) => !card.isCorrect)
        .map((card) => card.studentIndex)
        .toList(growable: false);
    final score = (100 * (1 - analysis.errorRate)).clamp(0, 100).toDouble();
    await ApiService.logAttempt(
      analysis.isCorrect,
      mismatches,
      bilikId: widget.bilik.id,
      levelId: widget.level.id,
      score: score,
      wer: analysis.errorRate,
      stars: analysis.isCorrect ? 3 : 0,
    );

    if (!analysis.isCorrect) return;
    setState(() => _saving = true);
    await ApiService.updateProgress(
      widget.bilik.id,
      widget.level.id,
      'completed',
    );
    if (mounted) setState(() => _saving = false);
  }

  void _showHint() {
    var index = 0;
    while (index < _answer.length &&
        index < widget.level.tokens.length &&
        _answer[index] == widget.level.tokens[index]) {
      index++;
    }
    final hintIndex = index.clamp(0, widget.level.tokens.length - 1);
    final token = widget.level.tokens[hintIndex];
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Petunjuk: kartu ke-${hintIndex + 1} adalah “$token”.'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final correct = _analysis?.isCorrect == true;
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mode Terpandu',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'Susun kartu menjadi kalimat sopan',
              style: GoogleFonts.inter(fontSize: 10, color: Colors.white70),
            ),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.line),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              width: 92,
                              height: 92,
                              color: const Color(0xFFEEF3FF),
                              child: Image.asset(
                                widget.level.comic.imagePath,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Icon(
                                  widget.bilik.id == 'akademik'
                                      ? Icons.school_rounded
                                      : Icons.business_center_rounded,
                                  color: _brand,
                                  size: 42,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 13),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Soal Kasus ${widget.level.id}',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: _brand,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  widget.level.prompt,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    height: 1.45,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.ink,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    const SpokLegend(),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Kalimatmu',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                          ),
                        ),
                        Text(
                          '${_answer.length}/${widget.level.tokens.length} kartu',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      constraints: const BoxConstraints(minHeight: 126),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _analysis != null && !correct
                              ? AppColors.danger.withValues(alpha: 0.5)
                              : AppColors.line,
                          width: 1.5,
                        ),
                      ),
                      child: _answer.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.touch_app_rounded,
                                    color: Color(0xFF98A2B3),
                                  ),
                                  const SizedBox(height: 7),
                                  Text(
                                    'Ketuk kartu di bawah untuk menyusun jawaban.',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: AppColors.muted,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Align(
                              alignment: Alignment.topLeft,
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 9,
                                children: List.generate(_answer.length, (
                                  index,
                                ) {
                                  final token = _answer[index];
                                  return WordCard(
                                    word: token,
                                    role: _roleFor(token),
                                    hasError: _hasErrorAt(index),
                                    selected: true,
                                    onTap: () => _removeToken(index),
                                  );
                                }),
                              ),
                            ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Kartu tersedia',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Wrap(
                      spacing: 8,
                      runSpacing: 9,
                      children: _available
                          .map(
                            (token) => WordCard(
                              word: token,
                              role: _roleFor(token),
                              onTap: () => _addToken(token),
                            ),
                          )
                          .toList(growable: false),
                    ),
                    if (_analysis != null) ...[
                      const SizedBox(height: 18),
                      FeedbackPanel(
                        correct: correct,
                        totalError: _analysis!.totalError,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(
                18,
                12,
                18,
                MediaQuery.paddingOf(context).bottom + 12,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.line)),
              ),
              child: Row(
                children: [
                  IconButton.filledTonal(
                    tooltip: 'Ulangi',
                    onPressed: () => setState(_reset),
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    tooltip: 'Petunjuk',
                    onPressed: _showHint,
                    icon: const Icon(Icons.lightbulb_outline_rounded),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _saving
                          ? null
                          : correct
                          ? () => Navigator.pop(context, true)
                          : _answer.isEmpty
                          ? null
                          : _checkAnswer,
                      icon: _saving
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Icon(
                              correct
                                  ? Icons.map_outlined
                                  : Icons.check_circle_outline_rounded,
                            ),
                      label: Text(correct ? 'Kembali ke Peta' : 'Cek Jawaban'),
                      style: FilledButton.styleFrom(
                        backgroundColor: correct ? AppColors.success : _brand,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        textStyle: GoogleFonts.inter(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
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
