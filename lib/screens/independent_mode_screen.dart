import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wicara_application_1/models/bilik.dart';
import 'package:wicara_application_1/widgets/wika_mascot.dart';
import 'package:wicara_application_1/screens/revision_screen.dart';
import 'package:wicara_application_1/services/api_service.dart';

class IndependentModeScreen extends StatefulWidget {
  final Bilik bilik;
  final BilikLevel level;

  const IndependentModeScreen({
    Key? key,
    required this.bilik,
    required this.level,
  }) : super(key: key);

  @override
  State<IndependentModeScreen> createState() => _IndependentModeScreenState();
}

class _IndependentModeScreenState extends State<IndependentModeScreen> {
  late HighlightingTextController _textController;
  bool _checked = false;
  int _charCount = 0;
  bool _isLoadingFeedback = false;
  int _apiScore = 0;
  String _improvedSentence = '';
  List<String> _apiSuggestions = [];
  Map<String, dynamic> _spokAnalysis = {};
  Map<String, Color> _wordHighlights = {};

  @override
  void initState() {
    super.initState();
    _wordHighlights = _getHighlightMap();
    _textController = HighlightingTextController(text: '', wordHighlights: _wordHighlights);
    _charCount = 0;
    _textController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {
      _charCount = _textController.text.length;
      _checked = false;
      _wordHighlights = _getHighlightMap();
      _textController.wordHighlights = _wordHighlights;
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Color _parseColor(String hex) {
    var value = hex.replaceAll('#', '');
    if (value.length == 6) value = 'FF$value';
    return Color(int.parse(value, radix: 16));
  }

  String _getInstructionText() {
    if (widget.bilik.id == 'akademik') {
      if (widget.level.id == 1) {
        return 'Tulis satu kalimat untuk memberi tahu Bapak Wali Kelas bahwa kamu sakit dan tidak dapat masuk sekolah.';
      }
      if (widget.level.id == 2) {
        return 'Tulis satu kalimat balasan untuk memberi tahu dosen bahwa kamu akan mengumpulkan tugas besok.';
      }
    }
    return 'Tulis satu kalimat pembuka di email untuk mendaftar program magang di Perusahaan X.';
  }

  Map<String, Color> _getHighlightMap() {
    final Map<String, Color> map = {};
    final spok = widget.level.spokAnswer;
    
    // Subjek (Blue)
    if (spok.s.isNotEmpty) {
      final List<String> list = spok.s.split(' ') + ['saya', 'aku', 'gw', 'gua', 'kami', 'kita'];
      for (var word in list) {
        final clean = word.replaceAll(RegExp(r'[^\w]'), '').toLowerCase().trim();
        if (clean.isNotEmpty) {
          map[clean] = const Color(0xFF3B82F6);
        }
      }
    }
    
    // Predikat (Red)
    if (spok.p.isNotEmpty) {
      final List<String> list = spok.p.split(' ') + [
        'mengumpulkan', 'ngumpulin', 'mengerjakan', 'ngerjain', 'kirim', 'mengirim',
        'tidak', 'masuk', 'hadir', 'periksa', 'turun', 'kehilangan', 'bertanya'
      ];
      for (var word in list) {
        final clean = word.replaceAll(RegExp(r'[^\w]'), '').toLowerCase().trim();
        if (clean.isNotEmpty) {
          map[clean] = const Color(0xFFEF4444);
        }
      }
    }
    
    // Objek (Orange)
    if (spok.o.isNotEmpty) {
      final List<String> list = spok.o.split(' ') + ['tugas', 'email', 'terima', 'kasih', 'dompet', 'baju', 'ktp'];
      for (var word in list) {
        final clean = word.replaceAll(RegExp(r'[^\w]'), '').toLowerCase().trim();
        if (clean.isNotEmpty) {
          map[clean] = const Color(0xFFF59E0B);
        }
      }
    }
    
    // Keterangan (Green)
    if (spok.k.isNotEmpty) {
      final List<String> list = spok.k.split(' ') + ['besok', 'hari', 'ini', 'malam', 'sakit', 'karena', 'gara-gara', 'kemarin', 'lalu'];
      for (var word in list) {
        final clean = word.replaceAll(RegExp(r'[^\w]'), '').toLowerCase().trim();
        if (clean.isNotEmpty) {
          map[clean] = const Color(0xFF10B981);
        }
      }
    }
    
    return map;
  }

  String _getSoftHintText() {
    if (widget.level.id == 2 && widget.bilik.id == 'akademik') {
      return "Pesan sudah bagus! Coba gunakan kata ganti 'Saya' (Warna Biru), ganti 'ngumpulin' dengan 'mengumpulkan' (Warna Merah), dan letakkan keterangan waktu 'besok' (Warna Hijau) di akhir kalimat.";
    }
    if (widget.level.id == 1 && widget.bilik.id == 'akademik') {
      return "Pesan sudah bagus! Coba gunakan kata ganti 'Saya' (Warna Biru), ganti 'nggak masuk' dengan 'tidak hadir' (Warna Merah), dan letakkan keterangan 'karena sakit' (Warna Hijau) di akhir kalimat.";
    }
    return "Coba pastikan kalimat diawali Subjek (Biru), diikuti Predikat (Merah), Objek (Oranye), dan Keterangan (Hijau) di bagian akhir.";
  }

  int _calculateFormalityScore(String rawText) {
    final text = rawText.toLowerCase();
    int score = 30; // base score

    bool hasInformal = false;
    if (text.contains('aku') || text.contains('gw') || text.contains('gua') || text.contains('lu') || text.contains('kamu')) {
      hasInformal = true;
    }
    if (text.contains('ngumpulin') || text.contains('nggak') || text.contains('gak') || text.contains('gara-gara')) {
      hasInformal = true;
    }

    final spok = widget.level.spokAnswer;
    
    // Check Subjek
    final expectedS = spok.s.toLowerCase();
    if (expectedS.isNotEmpty) {
      if (text.contains(expectedS)) {
        score += 20;
      }
    }

    // Check Predikat
    final expectedP = spok.p.toLowerCase();
    if (expectedP.isNotEmpty) {
      if (widget.level.id == 2 && widget.bilik.id == 'akademik') {
        if (text.contains('mengumpulkan')) {
          score += 25;
        }
      } else {
        if (text.contains(expectedP)) {
          score += 25;
        } else {
          final cleanP = expectedP.replaceAll('akan ', '').replaceAll('sudah ', '').replaceAll('ingin ', '');
          if (cleanP.isNotEmpty && text.contains(cleanP)) {
            score += 15;
          }
        }
      }
    }

    // Check Objek
    final expectedO = spok.o.toLowerCase();
    if (expectedO.isNotEmpty) {
      if (text.contains(expectedO)) {
        score += 15;
      }
    }

    // Check Keterangan
    final expectedK = spok.k.toLowerCase();
    if (expectedK.isNotEmpty) {
      final parts = expectedK.split(' ');
      bool kPresent = false;
      for (var part in parts) {
        if (part.length > 2 && text.contains(part)) {
          kPresent = true;
        }
      }
      if (kPresent) {
        score += 10;
      }
    }

    if (text.contains('terima kasih') || text.contains('mohon') || text.contains('tolong') || text.contains('dengan hormat')) {
      score += 10;
    }

    if (!hasInformal && score >= 70) {
      score += 20;
    }

    if (hasInformal) {
      score = score.clamp(0, 50); // Merah/Oranye sesuai requirements
    }

    return score.clamp(0, 100);
  }

  Future<void> _fetchAnalysis() async {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tulis kalimatmu terlebih dahulu!'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    setState(() {
      _isLoadingFeedback = true;
    });

    try {
      final result = await ApiService.getSentenceFeedback(
        _textController.text,
        _getInstructionText(),
      );

      if (result != null) {
        final rawScore = result['formality_score'] ?? 3;
        final maxScore = result['formality_max'] ?? 5;
        // Scale to 0-100
        final scaledScore = ((rawScore / maxScore) * 100).round();
        
        setState(() {
          _apiScore = scaledScore;
          _improvedSentence = result['improved_sentence'] ?? '';
          _apiSuggestions = List<String>.from(result['suggestions'] ?? []);
          _spokAnalysis = result['spok_analysis'] ?? {};
          _checked = true;
        });

        // Auto-complete level progress in DB if user gets a perfect score (>= 81)
        if (scaledScore >= 81) {
          await ApiService.updateProgress(widget.bilik.id, widget.level.id, 'completed');
        }
      } else {
        _runFallbackAnalysis();
      }
    } catch (_) {
      _runFallbackAnalysis();
    } finally {
      setState(() {
        _isLoadingFeedback = false;
      });
    }
  }

  void _runFallbackAnalysis() {
    final rawText = _textController.text;
    final score = _calculateFormalityScore(rawText);
    
    final spok = widget.level.spokAnswer;
    final List<String> suggestions = [];
    final inputLower = rawText.toLowerCase();

    if (widget.level.id == 2 && widget.bilik.id == 'akademik') {
      if (inputLower.contains('aku')) {
        suggestions.add("Kata 'aku' kurang formal, coba ganti dengan 'Saya'.");
      }
      if (inputLower.contains('ngumpulin')) {
        suggestions.add("Gunakan kata kerja baku 'mengumpulkan' sebagai pengganti 'ngumpulin'.");
      }
    } else {
      if (inputLower.contains('aku') || inputLower.contains('gw') || inputLower.contains('gua')) {
        suggestions.add("Gunakan kata ganti 'Saya' untuk menjaga kesopanan.");
      }
    }

    setState(() {
      _apiScore = score;
      _improvedSentence = widget.level.explanation.replaceAll("Susunan formal: ", "");
      _apiSuggestions = suggestions;
      _spokAnalysis = {
        'S': spok.s,
        'P': spok.p,
        'O': spok.o,
        'K': spok.k,
      };
      _checked = true;
    });

    if (score >= 81) {
      ApiService.updateProgress(widget.bilik.id, widget.level.id, 'completed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSchool = widget.bilik.id == 'akademik';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Top Custom Blue Header Section
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF4C5FD7),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back_rounded,
                              color: Color(0xFF4C5FD7),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            isSchool ? Icons.school_rounded : Icons.business_center_rounded,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isSchool ? 'Wali Kelas' : 'HRD Perusahaan X',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              Row(
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFFFC95A),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Simulasi Latihan',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: Colors.white.withOpacity(0.8),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),

                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'Mode Mandiri',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const WikaMascot(
                            mood: WikaMood.hint,
                            size: 40,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Wika: ',
                                    style: GoogleFonts.inter(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                  TextSpan(
                                    text: _getInstructionText(),
                                    style: GoogleFonts.inter(
                                      fontSize: 12.5,
                                      color: Colors.white,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. Body Message & Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isSchool ? 'Kepada: Bapak Wali Kelas' : 'Kepada: HRD Perusahaan X',
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF334155),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          child: Divider(color: Color(0xFFF1F5F9), height: 1),
                        ),
                        Text(
                          isSchool ? 'Subjek: Surat Izin Sakit' : 'Subjek: Permohonan Magang',
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF334155),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'TULISKAN PESANMU',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF64748B),
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _textController,
                          maxLines: 5,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            hintText: 'Tulis pesan formal Anda di sini...',
                            hintStyle: GoogleFonts.inter(
                              color: const Color(0xFF94A3B8),
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        const Divider(color: Color(0xFFF1F5F9), height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                _buildMiniToolbarButton(
                                  Icons.menu_book_rounded,
                                  const Color(0xFFE8F0FE),
                                  const Color(0xFF4C5FD7),
                                ),
                                const SizedBox(width: 8),
                                _buildMiniToolbarButton(
                                  Icons.auto_awesome_rounded,
                                  const Color(0xFFFFF7E0),
                                  const Color(0xFFFFB000),
                                ),
                              ],
                            ),
                            Text(
                              '$_charCount karakter',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (_checked) _buildFormalityMeter(),
                ],
              ),
            ),
          ),

          // 3. Footer Action Buttons
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Color(0xFFF1F5F9), width: 1.5),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: _isLoadingFeedback ? null : _fetchAnalysis,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4C5FD7),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 54),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isLoadingFeedback) ...[
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Menganalisis...',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                      ] else ...[
                        Text(
                          'Lihat Formalitas',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.auto_awesome_rounded, size: 16),
                      ],
                    ],
                  ),
                ),
                if (_checked) ...[
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RevisionScreen(
                            bilik: widget.bilik,
                            level: widget.level,
                            userInput: _textController.text,
                            formalityScore: _apiScore,
                          ),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _apiScore >= 81 ? 'Lihat Pohon Kalimat' : 'Lihat Susunan Kata',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF4C5FD7),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: Color(0xFF4C5FD7),
                          size: 14,
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
    );
  }

  Widget _buildMiniToolbarButton(IconData icon, Color bg, Color color) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }

  Widget _buildFormalityMeter() {
    final score = _apiScore;
    
    String message = '';
    Color color = const Color(0xFFEF4444); // default red
    
    if (score <= 50) {
      message = "Pesan masih butuh penyesuaian. Yuk, coba susun lagi biar lebih mudah dipahami!";
      color = const Color(0xFFF97316); // Orange
    } else if (score <= 80) {
      message = "Pesan sudah jelas! Tinggal dirapikan sedikit lagi agar lebih formal.";
      color = const Color(0xFFE5A91D); // Yellow/Gold
    } else {
      message = "Sangat Formal! Susunan kalimatmu sudah tepat! 🎉";
      color = const Color(0xFF10B981); // Green
    }
    
    final isPerfect = score >= 81;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'INDIKATOR FORMALITAS',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF475467),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 24),

          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final mascotLeft = (score / 100.0 * width) - 16;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      minHeight: 12,
                      value: score / 100.0,
                      backgroundColor: const Color(0xFFE2E8F0),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                  Positioned(
                    left: mascotLeft.clamp(0.0, width - 32),
                    top: -10,
                    child: WikaMascot(
                      mood: isPerfect ? WikaMood.celebrate : (score <= 50 ? WikaMood.retry : WikaMood.hint),
                      size: 32,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Perlu Penyesuaian',
                style: GoogleFonts.inter(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  color: score <= 50 ? const Color(0xFF24304A) : const Color(0xFF94A3B8),
                ),
              ),
              Text(
                'Sudah Jelas',
                style: GoogleFonts.inter(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  color: (score > 50 && score <= 80) ? const Color(0xFF24304A) : const Color(0xFF94A3B8),
                ),
              ),
              Text(
                'Sangat Formal',
                style: GoogleFonts.inter(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  color: score > 80 ? const Color(0xFF24304A) : const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: score <= 50
                  ? const Color(0xFFFFECEF)
                  : (score <= 80 ? const Color(0xFFFFF4D6) : const Color(0xFFE8F8F1)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: score <= 50
                        ? const Color(0xFF8B2235)
                        : (score <= 80 ? const Color(0xFF6A4C00) : const Color(0xFF145B42)),
                    height: 1.4,
                  ),
                ),
                if (!isPerfect) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PETUNJUK INKLUSIF',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF4C5FD7),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getSoftHintText(),
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            color: const Color(0xFF475569),
                            height: 1.4,
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
    );
  }
}

class HighlightingTextController extends TextEditingController {
  Map<String, Color> wordHighlights;

  HighlightingTextController({String? text, required this.wordHighlights})
      : super(text: text);

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    if (text.isEmpty) {
      return const TextSpan();
    }

    final List<TextSpan> children = [];
    final RegExp regExp = RegExp(r'(\s+)|(\w+)|([^\w\s]+)');
    final matches = regExp.allMatches(text);

    for (final match in matches) {
      final String word = match.group(0)!;
      final String wordLower = word.toLowerCase().trim();

      Color? highlightColor;
      for (final key in wordHighlights.keys) {
        if (wordLower == key.toLowerCase() ||
            wordLower.contains(key.toLowerCase())) {
          highlightColor = wordHighlights[key];
          break;
        }
      }

      if (highlightColor != null) {
        children.add(
          TextSpan(
            text: word,
            style: style?.copyWith(
              color: highlightColor,
              fontWeight: FontWeight.bold,
              backgroundColor: highlightColor.withOpacity(0.12),
              decoration: TextDecoration.underline,
              decorationColor: highlightColor,
            ),
          ),
        );
      } else {
        children.add(TextSpan(text: word, style: style));
      }
    }

    return TextSpan(children: children, style: style);
  }
}
