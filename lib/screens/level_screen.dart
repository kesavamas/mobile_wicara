import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'package:wicara_application_1/models/bilik.dart';
import 'package:wicara_application_1/services/api_service.dart';
import 'package:wicara_application_1/widgets/spok_badge.dart';

class LevelScreen extends StatefulWidget {
  final BilikLevel level;
  final Bilik bilik;

  const LevelScreen({
    Key? key,
    required this.level,
    required this.bilik,
  }) : super(key: key);

  @override
  _LevelScreenState createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {
  late List<String> _pool;
  final List<String> _arranged = [];
  bool _done = false;
  bool _isSaving = false;
  late ConfettiController _confettiController;
  int _attemptsCount = 0;
  bool _gotCorrect = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _initTokens();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _initTokens() {
    // Shuffle the tokens
    _pool = List<String>.from(widget.level.tokens)..shuffle(Random());
    _arranged.clear();
  }

  void _moveToArranged(String word) {
    if (_done) return;
    setState(() {
      _pool.remove(word);
      _arranged.add(word);
    });
  }

  void _moveToPool(String word) {
    if (_done) return;
    setState(() {
      _arranged.remove(word);
      _pool.add(word);
    });
  }

  Widget _buildStarsRow(int mistakesCount, {double size = 32.0}) {
    int filledStars = (3 - mistakesCount).clamp(0, 3);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        if (index < filledStars) {
          return Icon(
            Icons.star_rounded,
            color: const Color(0xFFF59E0B), // Amber 500
            size: size,
          );
        } else {
          return Icon(
            Icons.star_border_rounded,
            color: const Color(0xFFD1D5DB), // Gray 300
            size: size,
          );
        }
      }),
    );
  }

  double _calculateWordErrorRate(List<String> arranged, String correctText) {
    List<String> cleanWords(String s) {
      return s.replaceAll(RegExp(r'[^\w\s]'), '').toLowerCase().split(' ').where((w) => w.isNotEmpty).toList();
    }

    final cleanArranged = arranged.expand((chunk) => cleanWords(chunk)).toList();
    final cleanCorrect = cleanWords(correctText);

    if (cleanCorrect.isEmpty) {
      return cleanArranged.isEmpty ? 0.0 : 1.0;
    }

    int n = cleanCorrect.length;
    int m = cleanArranged.length;

    List<List<int>> dp = List.generate(n + 1, (_) => List.filled(m + 1, 0));

    for (int i = 0; i <= n; i++) {
      dp[i][0] = i;
    }
    for (int j = 0; j <= m; j++) {
      dp[0][j] = j;
    }

    for (int i = 1; i <= n; i++) {
      for (int j = 1; j <= m; j++) {
        if (cleanCorrect[i - 1] == cleanArranged[j - 1]) {
          dp[i][j] = dp[i - 1][j - 1];
        } else {
          dp[i][j] = 1 + [
            dp[i - 1][j], // deletion
            dp[i][j - 1], // insertion
            dp[i - 1][j - 1] // substitution
          ].reduce(min);
        }
      }
    }

    return dp[n][m] / n;
  }

  String _getSpokRoleForToken(String token) {
    String clean(String s) {
      return s.replaceAll(RegExp(r'[^\w\s]'), '').toLowerCase().trim();
    }

    final cleanToken = clean(token);
    if (cleanToken.isEmpty) return '';

    final spok = widget.level.spokAnswer;
    if (clean(spok.s).contains(cleanToken)) return 'S';
    if (clean(spok.p).contains(cleanToken)) return 'P';
    if (clean(spok.o).contains(cleanToken)) return 'O';
    if (clean(spok.k).contains(cleanToken)) return 'K';

    // Word fallback
    final tokenWords = cleanToken.split(' ');
    for (final word in tokenWords) {
      if (word.isEmpty) continue;
      if (clean(spok.s).split(' ').contains(word)) return 'S';
      if (clean(spok.p).split(' ').contains(word)) return 'P';
      if (clean(spok.o).split(' ').contains(word)) return 'O';
      if (clean(spok.k).split(' ').contains(word)) return 'K';
    }

    return '';
  }

  Widget _buildWordChip(String word, {required bool isArranged, required VoidCallback onPressed}) {
    final Color brandColor = _parseColor(widget.bilik.color);
    Color? shadowColor;
    Color? borderColor;
    Color textColor = isArranged ? Colors.white : const Color(0xFF334155);
    Color bgColor = isArranged ? brandColor : Colors.white;

    if (_attemptsCount >= 2) {
      final role = _getSpokRoleForToken(word);
      switch (role.toUpperCase()) {
        case 'S':
          shadowColor = const Color(0xFF3B82F6).withOpacity(0.4);
          borderColor = const Color(0xFF3B82F6);
          break;
        case 'P':
          shadowColor = const Color(0xFFEF4444).withOpacity(0.4);
          borderColor = const Color(0xFFEF4444);
          break;
        case 'O':
          shadowColor = const Color(0xFF10B981).withOpacity(0.4);
          borderColor = const Color(0xFF10B981);
          break;
        case 'K':
          shadowColor = const Color(0xFFF59E0B).withOpacity(0.4);
          borderColor = const Color(0xFFF59E0B);
          break;
      }
    }

    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor ?? (isArranged ? brandColor : const Color(0xFFE2E8F0)),
            width: borderColor != null ? 2.0 : 1.0,
          ),
          boxShadow: shadowColor != null
              ? [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 8,
                    spreadRadius: 2,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Text(
          word,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: textColor,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // Check correctness of the arranged sentence
  bool _checkIsCorrect() {
    // Clean string helper (remove punctuation, lower case, strip whitespace)
    String cleanString(String s) {
      return s.replaceAll(RegExp(r'[^\w\s]'), '').toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
    }

    final arrangedText = cleanString(_arranged.join(' '));
    final correctText = cleanString(widget.level.explanation.replaceFirst('Susunan formal: ', ''));

    return arrangedText == correctText;
  }

  // Calculate mismatched positions (SPOK index: S=0, P=1, O=2, K=3)
  List<int> _calculateMismatchedPositions() {
    if (_checkIsCorrect()) return [];

    // Simple heuristic: compare arranged words with correct words
    final cleanCorrectText = widget.level.explanation
        .replaceFirst('Susunan formal: ', '')
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .toLowerCase()
        .split(' ');

    final cleanArrangedWords = _arranged
        .map((w) => w.replaceAll(RegExp(r'[^\w\s]'), '').toLowerCase())
        .toList();

    List<int> mismatches = [];

    // Check if parts of correct text are misplaced
    // S (index 0) is usually first word
    if (cleanCorrectText.isNotEmpty && cleanCorrectText[0] != '') {
      final sWord = cleanCorrectText[0];
      if (cleanArrangedWords.isEmpty || cleanArrangedWords[0] != sWord) {
        mismatches.add(0); // Subject mismatch
      }
    }

    // P (index 1) - Predicate is usually the second word
    if (cleanCorrectText.length > 1 && cleanCorrectText[1] != '') {
      final pWord = cleanCorrectText[1];
      final arrangedIdx = cleanArrangedWords.indexOf(pWord);
      if (arrangedIdx == -1 || arrangedIdx != 1) {
        mismatches.add(1); // Predicate mismatch
      }
    }

    // If we have mismatches, return them, otherwise return default [1] (Predicate mismatch) for incorrect answers
    return mismatches.isEmpty ? [1] : mismatches;
  }

  Future<void> _handleComplete() async {
    if (_isSaving) return;

    final isCorrect = _checkIsCorrect();
    final cleanCorrectText = widget.level.explanation.replaceFirst('Susunan formal: ', '');
    final wer = _calculateWordErrorRate(_arranged, cleanCorrectText);
    final mismatches = _calculateMismatchedPositions();

    setState(() {
      _attemptsCount++;
    });

    if (isCorrect) {
      setState(() {
        _isSaving = true;
        _gotCorrect = true;
      });

      // Calculate score and stars based on attempts
      double score = 100.0;
      int stars = 3;
      if (_attemptsCount == 2) {
        score = 70.0;
        stars = 2;
      } else if (_attemptsCount >= 3) {
        score = 40.0;
        stars = 1;
      }

      await ApiService.logAttempt(
        true,
        [],
        bilikId: widget.bilik.id,
        levelId: widget.level.id,
        score: score,
        wer: 0.0,
        stars: stars,
      );

      await ApiService.updateProgress(widget.bilik.id, widget.level.id, 'completed');

      _confettiController.play();

      if (mounted) {
        setState(() {
          _isSaving = false;
          _done = true;
        });
      }
    } else {
      // Incorrect answer
      if (_attemptsCount == 1) {
        // First mistake: Try again, no WER, stars = 2
        await ApiService.logAttempt(
          false,
          mismatches,
          bilikId: widget.bilik.id,
          levelId: widget.level.id,
          score: 30.0,
          wer: null,
          stars: 2,
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Jawaban salah. Coba susun kembali kalimatnya!'),
            backgroundColor: Color(0xFFEF4444),
            duration: Duration(seconds: 3),
          ),
        );
      } else if (_attemptsCount == 2) {
        // Second mistake: Shadow hints enabled, no WER, stars = 1
        await ApiService.logAttempt(
          false,
          mismatches,
          bilikId: widget.bilik.id,
          levelId: widget.level.id,
          score: 15.0,
          wer: null,
          stars: 1,
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Jawaban masih salah. Perhatikan bayangan warna penunjuk peran SPOK pada kartu!'),
            backgroundColor: Color(0xFFF59E0B),
            duration: Duration(seconds: 4),
          ),
        );
      } else {
        // Third mistake: Auto-reveal correct answer, log final WER, stars = 0
        setState(() {
          _isSaving = true;
          _gotCorrect = false;
        });

        final double score = ((1.0 - wer).clamp(0.0, 1.0) * 10.0).roundToDouble();

        await ApiService.logAttempt(
          false,
          mismatches,
          bilikId: widget.bilik.id,
          levelId: widget.level.id,
          score: score,
          wer: wer,
          stars: 0,
        );

        await ApiService.updateProgress(widget.bilik.id, widget.level.id, 'completed');

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Percobaan ketiga salah. Jawaban yang benar kini ditampilkan.'),
            backgroundColor: Color(0xFF334155),
            duration: Duration(seconds: 4),
          ),
        );

        if (mounted) {
          setState(() {
            _isSaving = false;
            _done = true;
          });
        }
      }
    }
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
    final String assetImagePath = 'assets' + widget.level.comic.imagePath;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          'Level ${widget.level.id}',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: const Color(0xFF0F172A),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: _buildStarsRow(_attemptsCount, size: 24.0),
            ),
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.level.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Completed Screen
                  if (_done) ...[
                    Center(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: _gotCorrect ? const Color(0xFFECFDF5) : const Color(0xFFEFF6FF), // Emerald 50 or Blue 50
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: _gotCorrect ? const Color(0xFFA7F3D0) : const Color(0xFFBFDBFE)),
                        ),
                        child: Column(
                          children: [
                            _buildStarsRow(_gotCorrect ? _attemptsCount : 3, size: 48.0),
                            const SizedBox(height: 16),
                            Text(
                              _gotCorrect ? 'Level Selesai!' : 'Materi Terbuka!',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: _gotCorrect ? const Color(0xFF065F46) : const Color(0xFF1E3A8A),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _gotCorrect
                                  ? 'Kerja bagus menyusun kalimat formal di level ini.'
                                  : 'Kunci jawaban telah diungkap. Pelajari polanya untuk latihan berikutnya.',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: _gotCorrect ? const Color(0xFF047857) : const Color(0xFF1E40AF),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            if (!_gotCorrect) ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFFBFDBFE)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'SUSUNAN YANG BENAR',
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        color: const Color(0xFF1E3A8A),
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Wrap(
                                      spacing: 6.0,
                                      runSpacing: 6.0,
                                      children: [
                                        if (widget.level.spokAnswer.s.isNotEmpty)
                                          SpokBadge(role: 'S', text: widget.level.spokAnswer.s),
                                        if (widget.level.spokAnswer.p.isNotEmpty)
                                          SpokBadge(role: 'P', text: widget.level.spokAnswer.p),
                                        if (widget.level.spokAnswer.o.isNotEmpty)
                                          SpokBadge(role: 'O', text: widget.level.spokAnswer.o),
                                        if (widget.level.spokAnswer.k.isNotEmpty)
                                          SpokBadge(role: 'K', text: widget.level.spokAnswer.k),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      widget.level.explanation,
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: const Color(0xFF1E40AF),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: brandColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'Kembali ke Peta Bilik',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    // Play Screen
                    
                    // Comic Panel Card
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.01),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            height: 200,
                            decoration: BoxDecoration(
                              color: brandColor.withOpacity(0.06),
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(23)),
                            ),
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(23)),
                              child: Image.asset(
                                assetImagePath,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  // Fallback if image fails to load
                                  return Center(
                                    child: Icon(Icons.image, size: 64, color: brandColor.withOpacity(0.3)),
                                  );
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.level.comic.narration,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: const Color(0xFF475569),
                                    height: 1.4,
                                  ),
                                ),
                                if (widget.level.comic.speechBubble != null) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: brandColor.withOpacity(0.05),
                                      borderRadius: const BorderRadius.only(
                                        topRight: Radius.circular(16),
                                        bottomLeft: Radius.circular(16),
                                        bottomRight: Radius.circular(16),
                                      ),
                                      border: Border.all(color: brandColor.withOpacity(0.15)),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Icon(Icons.chat_bubble_outline, size: 16, color: brandColor),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            '“${widget.level.comic.speechBubble}”',
                                            style: GoogleFonts.inter(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              fontStyle: FontStyle.italic,
                                              color: const Color(0xFF1E293B),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Arranged Area
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: brandColor.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: brandColor.withOpacity(0.2), width: 2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Susun kalimat balasanmu:',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF475569),
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          // Arrange space
                          Container(
                            constraints: const BoxConstraints(minHeight: 60),
                            width: double.infinity,
                            child: Wrap(
                              spacing: 8.0,
                              runSpacing: 8.0,
                              children: _arranged.map((word) {
                                return _buildWordChip(
                                  word,
                                  isArranged: true,
                                  onPressed: () => _moveToPool(word),
                                );
                              }).toList(),
                            ),
                          ),
                          if (_arranged.isEmpty)
                            Center(
                              child: Text(
                                'Sentuh kata di bawah untuk menyusun kalimat',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: const Color(0xFF94A3B8),
                                ),
                              ),
                            ),
                          if (_arranged.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton(
                                onPressed: _initTokens,
                                child: Text(
                                  'Ulangi susunan',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF94A3B8),
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(50, 30),
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Pool Area (Word chips to choose from)
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: _pool.map((word) {
                        return _buildWordChip(
                          word,
                          isArranged: false,
                          onPressed: () => _moveToArranged(word),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Complete & Submit button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _arranged.isEmpty || _isSaving ? null : _handleComplete,
                        icon: const Icon(Icons.arrow_forward),
                        label: Text(_isSaving ? 'Menyimpan...' : 'Selesai, Lanjut'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F172A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple
            ],
          ),
        ],
      ),
    );
  }
}
