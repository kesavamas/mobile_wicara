import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'package:wicara_application_1/models/bilik.dart';
import 'package:wicara_application_1/services/api_service.dart';
import 'package:wicara_application_1/widgets/wika_mascot.dart';

class GuidedVnScreen extends StatefulWidget {
  final Bilik bilik;
  final BilikLevel level;

  const GuidedVnScreen({
    Key? key,
    required this.bilik,
    required this.level,
  }) : super(key: key);

  @override
  State<GuidedVnScreen> createState() => _GuidedVnScreenState();
}

class _GuidedVnScreenState extends State<GuidedVnScreen> {
  late ConfettiController _confettiController;
  late List<String> _pool;
  final List<String> _arranged = [];
  
  int _step = 0; // 0: Intro panel, 1: Conversation, 2: Assembly puzzle, 3: Completed popup
  int _attemptsCount = 0;
  bool _isSaving = false;
  bool _gotCorrect = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _initTokens();
  }

  void _initTokens() {
    _pool = List<String>.from(widget.level.tokens)..shuffle();
    _arranged.clear();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Color _parseColor(String hex) {
    var value = hex.replaceAll('#', '');
    if (value.length == 6) value = 'FF$value';
    return Color(int.parse(value, radix: 16));
  }

  String _getSpokRole(String token) {
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

    // Check individual words fallback
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

  bool _checkIsCorrect() {
    String clean(String s) {
      return s.replaceAll(RegExp(r'[^\w\s]'), '').toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
    }
    final arrangedText = clean(_arranged.join(' '));
    final correctText = clean(widget.level.explanation.replaceFirst('Susunan formal: ', ''));
    return arrangedText == correctText;
  }

  List<int> _calculateMismatches() {
    if (_checkIsCorrect()) return [];
    final cleanCorrect = widget.level.explanation
        .replaceFirst('Susunan formal: ', '')
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .toLowerCase()
        .split(' ');
    final cleanArranged = _arranged
        .map((w) => w.replaceAll(RegExp(r'[^\w\s]'), '').toLowerCase())
        .toList();

    List<int> mismatches = [];
    if (cleanCorrect.isNotEmpty && cleanCorrect[0] != '') {
      if (cleanArranged.isEmpty || cleanArranged[0] != cleanCorrect[0]) {
        mismatches.add(0);
      }
    }
    if (cleanCorrect.length > 1 && cleanCorrect[1] != '') {
      final pWord = cleanCorrect[1];
      final idx = cleanArranged.indexOf(pWord);
      if (idx == -1 || idx != 1) {
        mismatches.add(1);
      }
    }
    return mismatches.isEmpty ? [1] : mismatches;
  }

  Future<void> _handleSubmit() async {
    if (_isSaving) return;

    final isCorrect = _checkIsCorrect();
    final mismatches = _calculateMismatches();

    setState(() {
      _attemptsCount++;
    });

    if (isCorrect) {
      setState(() {
        _isSaving = true;
        _gotCorrect = true;
      });

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

      setState(() {
        _isSaving = false;
        _step = 3; // Step 3: Success Completion View
      });
    } else {
      if (_attemptsCount == 1) {
        await ApiService.logAttempt(
          false,
          mismatches,
          bilikId: widget.bilik.id,
          levelId: widget.level.id,
          score: 30.0,
          wer: null,
          stars: 2,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Jawaban salah. Coba susun kembali kalimatnya!'),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
      } else if (_attemptsCount == 2) {
        await ApiService.logAttempt(
          false,
          mismatches,
          bilikId: widget.bilik.id,
          levelId: widget.level.id,
          score: 15.0,
          wer: null,
          stars: 1,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Jawaban masih salah. Perhatikan bayangan warna penunjuk peran SPOK pada kartu!'),
            backgroundColor: Color(0xFFF59E0B),
          ),
        );
      } else {
        setState(() {
          _isSaving = true;
          _gotCorrect = false;
        });

        await ApiService.logAttempt(
          false,
          mismatches,
          bilikId: widget.bilik.id,
          levelId: widget.level.id,
          score: 0.0,
          wer: 1.0,
          stars: 0,
        );

        await ApiService.updateProgress(widget.bilik.id, widget.level.id, 'completed');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Percobaan ketiga salah. Jawaban yang benar kini ditampilkan.'),
            backgroundColor: Color(0xFF334155),
          ),
        );

        setState(() {
          _isSaving = false;
          _step = 3;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color brandColor = _parseColor(widget.bilik.color);

    return Scaffold(
      backgroundColor: const Color(0xFFEEF3FF),
      appBar: AppBar(
        title: Text(
          'Mode Terpandu',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: _buildStarsIndicator(),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background decorations
          Positioned(
            left: -40,
            top: 100,
            child: Opacity(
              opacity: 0.1,
              child: Container(
                width: 140,
                height: 140,
                decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: _buildBodyByStep(brandColor),
                  ),
                ),

                if (_step == 2)
                  _buildPuzzleFooter(brandColor),
              ],
            ),
          ),

          // Confetti overlay on completion
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarsIndicator() {
    int activeStars = (3 - _attemptsCount).clamp(0, 3);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) => Icon(
        Icons.star_rounded,
        color: index < activeStars ? const Color(0xFFFFD36A) : const Color(0xFFDDE2F0),
        size: 20,
      )),
    );
  }

  Widget _buildBodyByStep(Color brandColor) {
    if (_step == 0) {
      // Intro / Narration Panel
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFFD4DCFF)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                const WikaMascot(mood: WikaMood.welcome, size: 88),
                const SizedBox(height: 20),
                Text(
                  'Kasus Baru Terbuka',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF24304A),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.level.comic.narration,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF5D6785),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _step = 1;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Mulai Cerita',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } else if (_step == 1) {
      // Comic dialog bubble
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Center(
              child: Image.asset(
                'assets/logo.png', // Fallback logo or comic illustration
                width: 100,
                errorBuilder: (context, error, stackTrace) => const WikaMascot(
                  mood: WikaMood.hint,
                  size: 96,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Speech bubble
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFDCE2F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.forum_rounded, color: Color(0xFF4C5FD7), size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'DIALOG TERBUKA',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF4C5FD7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  widget.level.comic.speechBubble ?? 'Bantu susun kalimat formal untuk menyelesaikan misi!',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2858),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _step = 2;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4C5FD7),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Susun Kalimat',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.tune_rounded, size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } else if (_step == 2) {
      // Puzzle Screen
      final isReady = _arranged.length >= widget.level.tokens.length;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Objective
          Text(
            'Susun kalimat yang formal dan tepat:',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1F2858),
            ),
          ),
          const SizedBox(height: 12),

          // Sentence Assembly Board
          Container(
            padding: const EdgeInsets.all(16),
            constraints: const BoxConstraints(minHeight: 120),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isReady ? const Color(0xFF6FD1A7) : const Color(0xFFC7D5FF),
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Papan Susunan',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF8A6200),
                      ),
                    ),
                    if (isReady)
                      const Icon(Icons.check_circle_rounded, color: Color(0xFF1F9D70), size: 18),
                  ],
                ),
                const SizedBox(height: 12),
                _arranged.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: Text(
                            'Ketuk kartu kata di bawah',
                            style: GoogleFonts.inter(
                              color: const Color(0xFFC4CBDA),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                    : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _arranged.map((word) => _buildWordCard(word, true)).toList(),
                      ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Word chip pool
          Text(
            'KARTU KATA',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF98A2B3),
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _pool.map((word) => _buildWordCard(word, false)).toList(),
          ),
        ],
      );
    } else {
      // Completed / Success Screen (Step 3)
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _gotCorrect ? const Color(0xFFECFDF5) : const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: _gotCorrect ? const Color(0xFFA7F3D0) : const Color(0xFFBFDBFE),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                _buildStarsIndicator(),
                const SizedBox(height: 16),
                Text(
                  _gotCorrect ? 'Luar Biasa!' : 'Kasus Diselesaikan',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: _gotCorrect ? const Color(0xFF065F46) : const Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _gotCorrect
                      ? 'Kamu berhasil menyusun kalimat formal secara sempurna.'
                      : 'Kunci jawaban telah diungkap. Pelajari polanya untuk latihan berikutnya.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: _gotCorrect ? const Color(0xFF047857) : const Color(0xFF1E40AF),
                  ),
                ),
                const SizedBox(height: 24),

                // Correct answer reveal
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SUSUNAN YANG BENAR',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Colors.grey,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.level.explanation,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1F2858),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Kembali ke Peta Bilik',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
  }

  Widget _buildPuzzleFooter(Color brandColor) {
    final isReady = _arranged.length >= widget.level.tokens.length;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed: isReady ? _handleSubmit : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4C5FD7),
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFFEEF3FF),
              disabledForegroundColor: const Color(0xFF8490AA),
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Periksa Jawaban',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWordCard(String word, bool isPlaced) {
    final role = _getSpokRole(word);
    
    // Color mapping
    Color bgColor = Colors.white;
    Color borderClr = const Color(0xFFC4CBDF);
    Color textClr = const Color(0xFF1F2858);
    String label = '';

    if (_attemptsCount >= 2 || isPlaced) {
      switch (role) {
        case 'S':
          bgColor = const Color(0xFFEAF2FF);
          borderClr = const Color(0xFF4D91FF);
          textClr = const Color(0xFF163E8C);
          label = 'S';
          break;
        case 'P':
          bgColor = const Color(0xFFFFECEF);
          borderClr = const Color(0xFFD9485F);
          textClr = const Color(0xFF8B2235);
          label = 'P';
          break;
        case 'O':
          bgColor = const Color(0xFFE8F8F1);
          borderClr = const Color(0xFF1F9D70);
          textClr = const Color(0xFF145B42);
          label = 'O';
          break;
        case 'K':
          bgColor = const Color(0xFFFFF4D6);
          borderClr = const Color(0xFFE5A91D);
          textClr = const Color(0xFF6A4C00);
          label = 'K';
          break;
      }
    }

    return GestureDetector(
      onTap: () {
        if (_step != 2) return;
        setState(() {
          if (isPlaced) {
            _arranged.remove(word);
            _pool.add(word);
          } else {
            _pool.remove(word);
            _arranged.add(word);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderClr, width: 2),
          boxShadow: [
            BoxShadow(
              color: borderClr.withOpacity(0.12),
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (label.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: borderClr,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              word,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: textClr,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
