import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wicara_application_1/models/bilik.dart';
import 'package:wicara_application_1/services/api_service.dart';
import 'package:wicara_application_1/widgets/wika_mascot.dart';

class PuzzleStepData {
  final String prompt;
  final List<String> tokens;
  final String target;
  final Map<String, String> roles;

  PuzzleStepData({
    required this.prompt,
    required this.tokens,
    required this.target,
    required this.roles,
  });
}

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
  
  int _step = 0; // 0: Cover Screen, 1: Narration Slides, 2: Dialogue, 3: Puzzle assembly, 4: Completed popup
  int _storySlideIndex = 0;
  int _dialogueLineIndex = 0;
  int _attemptsCount = 0;
  bool _isSaving = false;
  bool _gotCorrect = false;

  List<PuzzleStepData> _stepsData = [];
  int _puzzleStep = 1;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _initStepsData();
    _initTokens();
  }

  void _initStepsData() {
    _stepsData = [];
    _puzzleStep = 1;
    
    if (widget.bilik.id == 'akademik' && widget.level.id == 1) {
      _stepsData = [
        PuzzleStepData(
          prompt: "Buka pesan dengan salam yang sopan kepada wali kelas.",
          tokens: ["Selamat", "pagi", "Bapak", "Wali", "Kelas."],
          target: "Selamat pagi Bapak Wali Kelas.",
          roles: {
            "Selamat": "Salam",
            "pagi": "Salam",
            "Bapak": "Salam",
            "Wali": "Salam",
            "Kelas.": "Salam",
          },
        ),
        PuzzleStepData(
          prompt: "Sampaikan alasanmu tidak bisa hadir ke sekolah.",
          tokens: ["Saya", "izin tidak masuk", "sekolah", "hari ini", "karena sakit."],
          target: "Saya izin tidak masuk sekolah hari ini karena sakit.",
          roles: {
            "Saya": "S",
            "izin tidak masuk": "P",
            "sekolah": "O",
            "hari ini": "K",
            "karena sakit.": "K",
          },
        ),
        PuzzleStepData(
          prompt: "Akhiri pesanmu dengan ucapan terima kasih.",
          tokens: ["Terima", "kasih", "atas", "perhatian", "Bapak."],
          target: "Terima kasih atas perhatian Bapak.",
          roles: {
            "Terima": "Penutup",
            "kasih": "Penutup",
            "atas": "Penutup",
            "perhatian": "Penutup",
            "Bapak.": "Penutup",
          },
        ),
      ];
    } else if (widget.bilik.id == 'profesional' && widget.level.id == 1) {
      _stepsData = [
        PuzzleStepData(
          prompt: "Buka email dengan sapaan yang formal kepada pihak HRD.",
          tokens: ["Yth.", "Bapak/Ibu", "HRD."],
          target: "Yth. Bapak/Ibu HRD.",
          roles: {
            "Yth.": "Salam",
            "Bapak/Ibu": "Salam",
            "HRD.": "Salam",
          },
        ),
        PuzzleStepData(
          prompt: "Tulis kalimat inti untuk mendaftar program magang.",
          tokens: ["Saya", "mengajukan diri", "untuk mengikuti program magang", "di perusahaan Bapak."],
          target: "Saya mengajukan diri untuk mengikuti program magang di perusahaan Bapak.",
          roles: {
            "Saya": "S",
            "mengajukan diri": "P",
            "untuk mengikuti program magang": "O",
            "di perusahaan Bapak.": "K",
          },
        ),
        PuzzleStepData(
          prompt: "Berikan kalimat penutup yang profesional.",
          tokens: ["Atas", "perhatian", "Bapak,", "saya ucapkan", "terima", "kasih."],
          target: "Atas perhatian Bapak, saya ucapkan terima kasih.",
          roles: {
            "Atas": "Penutup",
            "perhatian": "Penutup",
            "Bapak,": "Penutup",
            "saya ucapkan": "Penutup",
            "terima": "Penutup",
            "kasih.": "Penutup",
          },
        ),
      ];
    } else {
      _stepsData = [
        PuzzleStepData(
          prompt: widget.level.title,
          tokens: widget.level.tokens,
          target: widget.level.explanation.replaceFirst("Susunan formal: ", ""),
          roles: {
            for (var t in widget.level.tokens) t: _getSpokRoleFallback(t),
          },
        )
      ];
    }
  }

  String _getSpokRoleFallback(String token) {
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
    return '';
  }

  void _initTokens() {
    if (_stepsData.isEmpty) {
      _pool = List<String>.from(widget.level.tokens)..shuffle();
      _arranged.clear();
      for (int i = 0; i < widget.level.tokens.length; i++) {
        _arranged.add('');
      }
      return;
    }
    final stepData = _stepsData[_puzzleStep - 1];
    _pool = List<String>.from(stepData.tokens)..shuffle();
    _arranged.clear();
    for (int i = 0; i < stepData.tokens.length; i++) {
      _arranged.add('');
    }
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
    if (_stepsData.isEmpty) return '';
    final step = _stepsData[_puzzleStep - 1];
    return step.roles[token] ?? step.roles[token.trim()] ?? '';
  }

  bool _checkIsCorrect() {
    String clean(String s) {
      return s.replaceAll(RegExp(r'[^\w\s]'), '').toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
    }
    final arrangedText = clean(_arranged.join(' '));
    final correctSentence = _stepsData.isNotEmpty 
        ? _stepsData[_puzzleStep - 1].target
        : widget.level.explanation.replaceFirst('Susunan formal: ', '');
    final correctText = clean(correctSentence);
    return arrangedText == correctText;
  }

  List<int> _calculateMismatches() {
    if (_checkIsCorrect()) return [];
    final correctSentence = _stepsData.isNotEmpty 
        ? _stepsData[_puzzleStep - 1].target
        : widget.level.explanation.replaceFirst('Susunan formal: ', '');
    final cleanCorrect = correctSentence
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .toLowerCase()
        .split(' ');
    final List<int> mismatches = [];
    for (int i = 0; i < _arranged.length; i++) {
      if (_arranged[i].isEmpty) continue;
      final cleanWord = _arranged[i].replaceAll(RegExp(r'[^\w\s]'), '').toLowerCase().trim();
      bool found = false;
      for (int j = 0; j < cleanCorrect.length; j++) {
        if (cleanCorrect[j] == cleanWord) {
          if (i != j) {
            mismatches.add(i);
          }
          found = true;
          break;
        }
      }
      if (!found) {
        mismatches.add(i);
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
      if (_stepsData.isNotEmpty && _puzzleStep < _stepsData.length) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Langkah $_puzzleStep Berhasil! Mari susun langkah berikutnya.'),
            backgroundColor: const Color(0xFF10B981),
            duration: const Duration(seconds: 2),
          ),
        );
        setState(() {
          _puzzleStep++;
          _attemptsCount = 0;
          _initTokens();
        });
        return;
      }

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
        _step = 4; // Step 4: Success Completion View
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
          _step = 4;
        });
      }
    }
  }



  List<String> _getNarrationSlides() {
    if (widget.bilik.id == 'akademik') {
      if (widget.level.id == 1) {
        return [
          'Pagi ini, Raka merasa demam.',
          'Raka perlu memberi tahu wali kelas bahwa ia tidak dapat masuk sekolah.',
          'Bantu Raka menyusun pesannya.'
        ];
      } else if (widget.level.id == 2) {
        return [
          'Bapak Wali Kelas membalas pesan Raka.',
          'Raka perlu merespons untuk mengumpulkan tugas tepat waktu.',
          'Bantu Raka menyusun pesannya.'
        ];
      }
    }
    final text = widget.level.comic.narration;
    final parts = text.split('.').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    if (parts.length >= 2) {
      return parts.map((p) => '$p.').toList();
    }
    return [text, 'Bantu susun pesan formal untuk menyelesaikan misi!'];
  }

  List<String> _getDialogueLines() {
    if (widget.bilik.id == 'akademik') {
      if (widget.level.id == 1) {
        return [
          "Aku harus menghubungi Bapak Wali Kelas. Sebaiknya aku mulai dari mana?",
          "Aku perlu menyusun kalimat formal agar wali kelas memahami alasan ketidakhadiranku.",
          "Mari kita mulai dengan menyusun kalimat pertama!"
        ];
      } else if (widget.level.id == 2) {
        return [
          "Bapak Wali Kelas mengingatkan tentang pengumpulan tugas minggu ini.",
          "Bagaimana ya cara memberi tahu beliau dengan sopan bahwa saya akan mengumpulkan tugas besok?",
          "Mari kita susun kalimat balasannya!"
        ];
      }
    }
    return [
      widget.level.comic.speechBubble ?? "Mari kita bantu menyusun pesan formal ini.",
      "Pastikan urutan SPOK tersusun dengan benar agar kalimat mudah dipahami.",
      "Susun kalimat sekarang!"
    ];
  }

  String _getDialogueImagePath() {
    final currentPath = widget.level.comic.imagePath;
    if (currentPath.contains('step-1')) return currentPath.replaceAll('step-1', 'step-2');
    if (currentPath.contains('step-2')) return currentPath.replaceAll('step-2', 'step-3');
    if (currentPath.contains('step-3')) return currentPath.replaceAll('step-3', 'step-4');
    if (currentPath.contains('step-4')) return currentPath.replaceAll('step-4', 'step-5');
    if (currentPath.contains('step-5')) return currentPath.replaceAll('step-5', 'step-6');
    return currentPath;
  }

  @override
  Widget build(BuildContext context) {
    final Color brandColor = _parseColor(widget.bilik.color);

    PreferredSizeWidget? buildDynamicAppBar() {
      if (_step == 3) {
        return AppBar(
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
        );
      }
      return null;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFEEF3FF),
      appBar: buildDynamicAppBar(),
      body: Stack(
        children: [
          if (_step <= 2) ...[
            Positioned.fill(
              child: Image.asset(
                _step == 2 ? 'assets${_getDialogueImagePath()}' : 'assets${widget.level.comic.imagePath}',
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.0),
                      Colors.black.withOpacity(0.2),
                      Colors.black.withOpacity(0.85),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ],
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _step <= 2
                      ? _buildStoryOverlay(brandColor)
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(20.0),
                          child: _buildBodyByStep(brandColor),
                        ),
                ),
                if (_step == 3)
                  _buildPuzzleFooter(brandColor),
              ],
            ),
          ),
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

  Widget _buildStoryOverlay(Color brandColor) {
    if (_step == 0) {
      final isSchool = widget.bilik.id == 'akademik';
      return Column(
        children: [
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.videogame_asset_rounded, color: Color(0xFF4C5FD7), size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'Mode Terpandu',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF4C5FD7),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4C5FD7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Kasus ${widget.level.id}',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    isSchool ? 'Bilik Sekolah' : 'Bilik Profesional',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF5D6785),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.level.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1F2858),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Bantu Raka menyampaikan pesannya dengan jelas dan sopan.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF5D6785),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                _buildChecklistItem(1, 'Memberi salam'),
                const SizedBox(height: 8),
                _buildChecklistItem(2, 'Menyampaikan izin'),
                const SizedBox(height: 8),
                _buildChecklistItem(3, 'Menjelaskan alasan'),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _step = 1;
                      _storySlideIndex = 0;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4C5FD7),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Mulai Cerita',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_forward_rounded, size: 16),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Kembali ke Peta',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF8490AA),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } else if (_step == 1) {
      final slides = _getNarrationSlides();
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: List.generate(slides.length, (idx) {
                    final isCurrent = idx == _storySlideIndex;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 6,
                      width: isCurrent ? 24 : 8,
                      decoration: BoxDecoration(
                        color: isCurrent ? Colors.white : Colors.white.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _step = 3;
                    });
                  },
                  child: Row(
                    children: [
                      Text(
                        'Lewat',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.skip_next_rounded, color: Colors.white, size: 14),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1F2858).withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                slides[_storySlideIndex],
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  height: 1.45,
                ),
              ),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (_storySlideIndex < slides.length - 1) {
                        _storySlideIndex++;
                      } else {
                        _step = 2;
                        _dialogueLineIndex = 0;
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4C5FD7),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _storySlideIndex < slides.length - 1 ? 'Lanjut' : 'Mulai Percakapan',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_forward_rounded, size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      final dialogueLines = _getDialogueLines();
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _step = 1;
                      _storySlideIndex = _getNarrationSlides().length - 1;
                    });
                  },
                ),
                Row(
                  children: List.generate(dialogueLines.length, (idx) {
                    final isCurrent = idx == _dialogueLineIndex;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: isCurrent ? const Color(0xFF4C5FD7) : Colors.white.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                ),
                _buildStarsIndicator(),
              ],
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF4C5FD7),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Raka',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF4C5FD7),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${_dialogueLineIndex + 1} / ${dialogueLines.length}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF98A2B3),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  dialogueLines[_dialogueLineIndex],
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2858),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (_dialogueLineIndex < dialogueLines.length - 1) {
                        _dialogueLineIndex++;
                      } else {
                        _step = 3;
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4C5FD7),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _dialogueLineIndex < dialogueLines.length - 1 ? 'Ketuk untuk lanjut' : 'Mulai Susun Kalimat',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_forward_rounded, size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
  }

  Widget _buildChecklistItem(int num, String text) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            color: Color(0xFFEEF3FF),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$num',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF4C5FD7),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F2858),
          ),
        ),
      ],
    );
  }

  Widget _buildStarsIndicator() {
    int activeStars = _gotCorrect
        ? (4 - _attemptsCount).clamp(1, 3)
        : (3 - _attemptsCount).clamp(0, 3);
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
    if (_step == 3) {
      final isReady = _arranged.every((word) => word.isNotEmpty);
      final chain = _getSpokChain();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF3FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _stepsData.isNotEmpty ? 'Langkah $_puzzleStep dari ${_stepsData.length}' : 'Percakapan ${widget.level.id} dari 6',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF4C5FD7),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1EAFE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.help_outline_rounded, color: Color(0xFF7C3AED), size: 12),
                    const SizedBox(width: 4),
                    Text(
                      'Petunjuk',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF7C3AED),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Text(
            _getLevelPrompt(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),

          if (chain.isNotEmpty) ...[
            Row(
              children: List.generate(chain.length, (idx) {
                Color itemClr = const Color(0xFF4C5FD7);
                Color bgClr = const Color(0xFFEAF2FF);
                if (idx == 1) {
                  itemClr = const Color(0xFFD9485F);
                  bgClr = const Color(0xFFFFECEF);
                } else if (idx == 2) {
                  itemClr = const Color(0xFF1F9D70);
                  bgClr = const Color(0xFFE8F8F1);
                } else if (idx >= 3) {
                  itemClr = const Color(0xFFE5A91D);
                  bgClr = const Color(0xFFFFF4D6);
                }
                return Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: bgClr,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: itemClr.withOpacity(0.5)),
                      ),
                      child: Text(
                        chain[idx],
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: itemClr,
                        ),
                      ),
                    ),
                    if (idx < chain.length - 1) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_rounded, color: Color(0xFF98A2B3), size: 10),
                      const SizedBox(width: 4),
                    ],
                  ],
                );
              }),
            ),
            const SizedBox(height: 20),
          ],

          DragTarget<String>(
            onWillAccept: (data) => data != null,
            onAcceptWithDetails: (details) {
              final word = details.data;
              final emptyIdx = _arranged.indexOf('');
              if (emptyIdx != -1 && _pool.contains(word)) {
                setState(() {
                  _pool.remove(word);
                  _arranged[emptyIdx] = word;
                });
              }
            },
            builder: (context, candidateData, rejectedData) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBF0),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: candidateData.isNotEmpty ? const Color(0xFF4C5FD7) : const Color(0xFFFFEFA7),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Susun jawaban ${widget.bilik.id == 'akademik' ? 'Raka' : 'Naya'}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF8A6200),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ketuk kartu untuk menyusun',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: const Color(0xFFC8A261),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Column(
                      children: [
                        const Icon(
                          Icons.touch_app_rounded,
                          color: Color(0xFFFFD56B),
                          size: 32,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tarik kartu ke sini',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: const Color(0xFFC8A261),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 8,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: List.generate(_arranged.length, (index) {
                        final word = _arranged[index];
                        if (word.isNotEmpty) {
                          return Draggable<String>(
                            data: word,
                            feedback: Material(
                              color: Colors.transparent,
                              child: _buildWordCard(word, true, isDragging: true),
                            ),
                            childWhenDragging: Opacity(
                              opacity: 0.35,
                              child: _buildEmptySlot(),
                            ),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _arranged[index] = '';
                                  _pool.add(word);
                                });
                              },
                              child: _buildWordCard(word, true),
                            ),
                          );
                        } else {
                          return DragTarget<String>(
                            onWillAccept: (data) => data != null,
                            onAcceptWithDetails: (details) {
                              final dragWord = details.data;
                              setState(() {
                                if (_pool.contains(dragWord)) {
                                  _pool.remove(dragWord);
                                  _arranged[index] = dragWord;
                                } else {
                                  final oldIdx = _arranged.indexOf(dragWord);
                                  if (oldIdx != -1) {
                                    _arranged[oldIdx] = '';
                                  }
                                  _arranged[index] = dragWord;
                                }
                              });
                            },
                            builder: (context, candidateData, rejectedData) {
                              return _buildEmptySlot(isHighlight: candidateData.isNotEmpty);
                            },
                          );
                        }
                      }),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),

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
            runSpacing: 12,
            children: _pool.map((word) {
              return Draggable<String>(
                data: word,
                feedback: Material(
                  color: Colors.transparent,
                  child: _buildWordCard(word, false, isDragging: true),
                ),
                childWhenDragging: Opacity(
                  opacity: 0.35,
                  child: _buildWordCard(word, false),
                ),
                child: GestureDetector(
                  onTap: () {
                    final emptyIdx = _arranged.indexOf('');
                    if (emptyIdx != -1) {
                      setState(() {
                        _pool.remove(word);
                        _arranged[emptyIdx] = word;
                      });
                    }
                  },
                  child: _buildWordCard(word, false),
                ),
              );
            }).toList(),
          ),
        ],
      );
    } else {
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
                        _getCompletedExplanation(),
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
    final isReady = _arranged.every((word) => word.isNotEmpty);
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
                  isReady ? 'Periksa Jawaban' : 'Susun semua kartunya',
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

  String _getLevelPrompt() {
    if (_stepsData.isNotEmpty) {
      return _stepsData[_puzzleStep - 1].prompt;
    }
    return widget.level.title;
  }

  List<String> _getSpokChain() {
    final List<String> chain = [];
    final spok = widget.level.spokAnswer;
    if (spok.s.isNotEmpty) chain.add('Siapa?');
    if (spok.p.isNotEmpty) chain.add('Melakukan apa?');
    if (spok.o.isNotEmpty) {
      if (spok.o.toLowerCase().contains('tugas')) {
        chain.add('Tugas apa?');
      } else if (spok.o.toLowerCase().contains('terima kasih')) {
        chain.add('Ucapan apa?');
      } else {
        chain.add('Apa?');
      }
    }
    if (spok.k.isNotEmpty) {
      if (spok.k.toLowerCase().contains('sakit')) {
        chain.add('Mengapa?');
      } else if (spok.k.toLowerCase().contains('besok') || spok.k.toLowerCase().contains('malam')) {
        chain.add('Kapan?');
      } else {
        chain.add('Keterangan?');
      }
    }
    return chain;
  }

  Widget _buildEmptySlot({bool isHighlight = false}) {
    return Container(
      width: 76,
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: isHighlight ? const Color(0xFFF0F4FF) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHighlight ? const Color(0xFF4C5FD7) : const Color(0xFFE2E8F0),
          width: 2,
        ),
      ),
    );
  }

  Widget _buildWordCard(String word, bool isPlaced, {bool isDragging = false}) {
    final role = _getSpokRole(word);
    final showHint = _attemptsCount >= 2;
    
    Color bgColor = Colors.white;
    Color borderClr = const Color(0xFFE2E8F0);
    Color textClr = const Color(0xFF1F2858);
    Color tagClr = Colors.transparent;

    if (showHint) {
      switch (role) {
        case 'S':
          bgColor = const Color(0xFFEAF2FF);
          borderClr = const Color(0xFF4D91FF);
          textClr = const Color(0xFF163E8C);
          tagClr = const Color(0xFF4D91FF);
          break;
        case 'P':
          bgColor = const Color(0xFFFFECEF);
          borderClr = const Color(0xFFD9485F);
          textClr = const Color(0xFF8B2235);
          tagClr = const Color(0xFFD9485F);
          break;
        case 'O':
          bgColor = const Color(0xFFE8F8F1);
          borderClr = const Color(0xFF1F9D70);
          textClr = const Color(0xFF145B42);
          tagClr = const Color(0xFF1F9D70);
          break;
        case 'K':
          bgColor = const Color(0xFFFFF4D6);
          borderClr = const Color(0xFFE5A91D);
          textClr = const Color(0xFF6A4C00);
          tagClr = const Color(0xFFE5A91D);
          break;
        case 'Pel':
          bgColor = const Color(0xFFF1EAFE);
          borderClr = const Color(0xFF7C3AED);
          textClr = const Color(0xFF4C1D95);
          tagClr = const Color(0xFF7C3AED);
          break;
        case 'Salam':
        case 'Penutup':
          bgColor = const Color(0xFFF1F5F9);
          borderClr = const Color(0xFFCBD5E1);
          textClr = const Color(0xFF475569);
          tagClr = const Color(0xFF94A3B8);
          break;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderClr, width: 2),
        boxShadow: isDragging
            ? [
                BoxShadow(
                  color: borderClr.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 8),
                )
              ]
            : [
                BoxShadow(
                  color: borderClr.withOpacity(0.12),
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showHint && tagClr != Colors.transparent) ...[
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: tagClr,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Text(
            word,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: textClr,
            ),
          ),
          if (!isPlaced) ...[
            const SizedBox(width: 8),
            const Icon(
              Icons.drag_indicator_rounded,
              size: 14,
              color: Color(0xFF98A2B3),
            ),
          ],
        ],
      ),
    );
  }

  String _getCompletedExplanation() {
    if (widget.bilik.id == 'akademik' && widget.level.id == 1) {
      return "Selamat pagi Bapak Wali Kelas.\nSaya izin tidak masuk sekolah hari ini karena sakit.\nTerima kasih atas perhatian Bapak.";
    }
    if (widget.bilik.id == 'profesional' && widget.level.id == 1) {
      return "Yth. Bapak/Ibu HRD.\nSaya mengajukan diri untuk mengikuti program magang di perusahaan Bapak.\nAtas perhatian Bapak, saya ucapkan terima kasih.";
    }
    return widget.level.explanation;
  }
}
