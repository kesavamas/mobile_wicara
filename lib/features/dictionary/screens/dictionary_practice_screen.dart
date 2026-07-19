import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wicara_application_1/core/theme/app_colors.dart';
import 'package:wicara_application_1/features/dictionary/models/dictionary_word.dart';
import 'package:wicara_application_1/features/dictionary/repositories/dictionary_learning_repository.dart';
import 'package:wicara_application_1/features/shared/widgets/wicara_illustration_icon.dart';

class DictionaryPracticeScreen extends StatefulWidget {
  final DictionaryWord word;

  const DictionaryPracticeScreen({super.key, required this.word});

  @override
  State<DictionaryPracticeScreen> createState() =>
      _DictionaryPracticeScreenState();
}

class _DictionaryPracticeScreenState extends State<DictionaryPracticeScreen> {
  final _repository = DictionaryLearningRepository();
  int _questionIndex = 0;
  int _correctAnswers = 0;
  String? _selectedAnswer;
  bool _answerChecked = false;
  bool _saving = false;
  bool _finished = false;
  DictionaryWordProgress? _result;

  DictionaryWord get word => widget.word;
  String get _correctAnswer =>
      _questionIndex == 0 ? word.role.label : word.word;

  List<String> get _answers => _questionIndex == 0
      ? DictionaryRole.values.map((role) => role.label).toList()
      : word.clozeOptions;

  void _selectAnswer(String answer) {
    if (_answerChecked) return;
    setState(() => _selectedAnswer = answer);
  }

  void _checkAnswer() {
    if (_selectedAnswer == null || _answerChecked) return;
    final correct = _selectedAnswer == _correctAnswer;
    setState(() {
      _answerChecked = true;
      if (correct) _correctAnswers += 1;
    });
  }

  Future<void> _continue() async {
    if (!_answerChecked) return;
    if (_questionIndex == 0) {
      setState(() {
        _questionIndex = 1;
        _selectedAnswer = null;
        _answerChecked = false;
      });
      return;
    }

    setState(() => _saving = true);
    final result = await _repository.recordPractice(
      wordId: word.id,
      correctAnswers: _correctAnswers,
      totalQuestions: 2,
    );
    if (!mounted) return;
    setState(() {
      _result = result;
      _saving = false;
      _finished = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final roleStyle = _roleStyle(word.role);
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FF),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: SafeArea(
            child: _finished
                ? _buildResult(roleStyle)
                : _buildQuestion(roleStyle),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestion(_RoleStyle roleStyle) {
    final isCorrect = _selectedAnswer == _correctAnswer;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 20, 0),
          child: Row(
            children: [
              IconButton(
                tooltip: 'Kembali',
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: (_questionIndex + 1) / 2,
                    minHeight: 9,
                    backgroundColor: const Color(0xFFE3E7F5),
                    color: AppColors.indigo,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${_questionIndex + 1}/2',
                style: GoogleFonts.nunitoSans(
                  fontWeight: FontWeight.w900,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    WicaraIllustrationIcon(
                      type: roleStyle.illustration,
                      size: 58,
                      accent: roleStyle.accent,
                      background: roleStyle.soft,
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Latihan Kata',
                            style: GoogleFonts.nunitoSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: AppColors.indigo,
                            ),
                          ),
                          Text(
                            word.word,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 25,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 26),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.line),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0D1F2858),
                        blurRadius: 18,
                        offset: Offset(0, 7),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _questionIndex == 0
                            ? 'Apa fungsi kata ini?'
                            : 'Lengkapi kalimat berikut',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _questionIndex == 0
                            ? 'Pilih peran kata “${word.word}” dalam susunan kalimat.'
                            : word.clozeSentence,
                        style: GoogleFonts.nunitoSans(
                          fontSize: 14,
                          height: 1.45,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                for (final answer in _answers) ...[
                  _AnswerOption(
                    label: answer,
                    selected: _selectedAnswer == answer,
                    checked: _answerChecked,
                    correct: answer == _correctAnswer,
                    onTap: () => _selectAnswer(answer),
                  ),
                  const SizedBox(height: 9),
                ],
                if (_answerChecked) ...[
                  const SizedBox(height: 7),
                  _FeedbackPanel(
                    correct: isCorrect,
                    correctAnswer: _correctAnswer,
                    roleColor: roleStyle.accent,
                  ),
                ],
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
          child: FilledButton.icon(
            onPressed: _saving
                ? null
                : _answerChecked
                ? _continue
                : _selectedAnswer == null
                ? null
                : _checkAnswer,
            icon: _saving
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    _answerChecked
                        ? Icons.arrow_forward_rounded
                        : Icons.check_rounded,
                  ),
            label: Text(
              _saving
                  ? 'Menyimpan'
                  : _answerChecked
                  ? _questionIndex == 0
                        ? 'Lanjut'
                        : 'Lihat Hasil'
                  : 'Periksa Jawaban',
            ),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
              backgroundColor: AppColors.indigo,
              disabledBackgroundColor: const Color(0xFFDDE2F2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              textStyle: GoogleFonts.nunitoSans(
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResult(_RoleStyle roleStyle) {
    final result = _result ?? const DictionaryWordProgress();
    final perfect = result.lastScore == 100;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              tooltip: 'Kembali ke Kamus',
              onPressed: () => Navigator.pop(context, true),
              icon: const Icon(Icons.close_rounded),
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: WicaraIllustrationIcon(
              type: perfect
                  ? WicaraIllustrationType.achievement
                  : WicaraIllustrationType.practice,
              size: 112,
              accent: perfect ? AppColors.warning : roleStyle.accent,
              background: perfect ? AppColors.softYellow : roleStyle.soft,
            ),
          ),
          const SizedBox(height: 22),
          Text(
            perfect ? 'Kata Berhasil Dikuasai' : 'Latihan Tersimpan',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            perfect
                ? 'Kamu memahami fungsi dan penggunaan kata “${word.word}”.'
                : 'Kamu sudah berlatih. Ulangi sekali lagi untuk memperkuat pemahamanmu.',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunitoSans(
              fontSize: 13,
              height: 1.45,
              fontWeight: FontWeight.w700,
              color: AppColors.text2,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.line),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _ResultStat(
                    value: '${result.lastScore}',
                    label: 'Nilai latihan',
                    color: AppColors.indigo,
                  ),
                ),
                Container(width: 1, height: 42, color: AppColors.line),
                Expanded(
                  child: _ResultStat(
                    value: result.mastery.label,
                    label: 'Status kata',
                    color: roleStyle.accent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.menu_book_rounded),
            label: const Text('Kembali ke Kamus'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
              backgroundColor: AppColors.indigo,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnswerOption extends StatelessWidget {
  final String label;
  final bool selected;
  final bool checked;
  final bool correct;
  final VoidCallback onTap;

  const _AnswerOption({
    required this.label,
    required this.selected,
    required this.checked,
    required this.correct,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final showCorrect = checked && correct;
    final showIncorrect = checked && selected && !correct;
    final borderColor = showCorrect
        ? AppColors.success
        : showIncorrect
        ? AppColors.danger
        : selected
        ? AppColors.indigo
        : AppColors.line;
    final background = showCorrect
        ? AppColors.softMint
        : showIncorrect
        ? AppColors.softCoral
        : selected
        ? AppColors.softBlue
        : Colors.white;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: checked ? null : onTap,
          borderRadius: BorderRadius.circular(18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            constraints: const BoxConstraints(minHeight: 54),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: borderColor, width: selected ? 2 : 1),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.nunitoSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: AppColors.ink,
                    ),
                  ),
                ),
                if (showCorrect)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.success,
                  )
                else if (showIncorrect)
                  const Icon(Icons.info_rounded, color: AppColors.danger)
                else
                  Icon(
                    selected
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                    color: selected ? AppColors.indigo : AppColors.muted,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeedbackPanel extends StatelessWidget {
  final bool correct;
  final String correctAnswer;
  final Color roleColor;

  const _FeedbackPanel({
    required this.correct,
    required this.correctAnswer,
    required this.roleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: correct ? AppColors.softMint : AppColors.softYellow,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            correct ? Icons.check_circle_rounded : Icons.lightbulb_rounded,
            color: correct ? AppColors.success : AppColors.adverbInk,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              correct
                  ? 'Tepat. Kamu sudah mengenali kata ini.'
                  : 'Hampir tepat. Jawaban yang sesuai adalah “$correctAnswer”.',
              style: GoogleFonts.nunitoSans(
                fontSize: 12,
                height: 1.4,
                fontWeight: FontWeight.w800,
                color: roleColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultStat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _ResultStat({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.nunitoSans(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: AppColors.muted,
          ),
        ),
      ],
    );
  }
}

class _RoleStyle {
  final Color accent;
  final Color soft;
  final WicaraIllustrationType illustration;

  const _RoleStyle(this.accent, this.soft, this.illustration);
}

_RoleStyle _roleStyle(DictionaryRole role) => switch (role) {
  DictionaryRole.subject => const _RoleStyle(
    Color(0xFF3D73DB),
    Color(0xFFEAF2FF),
    WicaraIllustrationType.subject,
  ),
  DictionaryRole.predicate => const _RoleStyle(
    Color(0xFFD94865),
    Color(0xFFFFECEF),
    WicaraIllustrationType.predicate,
  ),
  DictionaryRole.object => const _RoleStyle(
    Color(0xFFC28A00),
    Color(0xFFFFF4CC),
    WicaraIllustrationType.object,
  ),
  DictionaryRole.adverb => const _RoleStyle(
    Color(0xFF19845F),
    Color(0xFFE8F8F1),
    WicaraIllustrationType.adverb,
  ),
  DictionaryRole.complement => const _RoleStyle(
    Color(0xFF6C4FD3),
    Color(0xFFF1EDFF),
    WicaraIllustrationType.practice,
  ),
};
