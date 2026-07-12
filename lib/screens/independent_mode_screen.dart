import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wicara_application_1/models/bilik.dart';
import 'package:wicara_application_1/widgets/wika_mascot.dart';
import 'package:wicara_application_1/screens/revision_screen.dart';

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
  late TextEditingController _textController;
  bool _checked = false;
  int _charCount = 0;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: '');
    _charCount = 0;
    _textController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {
      _charCount = _textController.text.length;
      _checked = false;
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
                    // Header Action Bar
                    Row(
                      children: [
                        // Back Arrow Circle Button
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
                        
                        // Capsule icon
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

                        // Title details
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

                        // Mode Mandiri Capsule
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

                    // Mascot Dialogue Card
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
                  // Recipient details (Kepada & Subjek Card)
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

                  // Large Text Area card
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

                  // Dynamic Formality Meter
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
                  onPressed: () {
                    setState(() {
                      _checked = true;
                    });
                  },
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
                  ),
                ),
                if (_checked) ...[
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RevisionScreen(),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Lihat Susunan Kata',
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
    final text = _textController.text.toLowerCase();
    int score = 30;
    if (text.contains('izin') || text.contains('magang')) score += 30;
    if (text.contains('karena') || text.contains('atas perhatian') || text.contains('kepada')) score += 30;
    score = score.clamp(0, 100);

    final level = score < 40 ? 1 : score < 70 ? 2 : 3;
    final messages = [
      'Pesanmu sudah mulai terbentuk. Yuk, rapikan sedikit lagi.',
      'Pesanmu sudah jelas! Tinggal satu langkah lagi agar lebih formal.',
      'Sangat Formal! Pesanmu sudah jelas dan tepat. Siap digunakan! 🎉'
    ];
    final labels = ['Yuk, Rapikan', 'Sudah Jelas', 'Sangat Formal'];
    final moods = [WikaMood.retry, WikaMood.hint, WikaMood.celebrate];

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

          // Journey gauge bar
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
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1F9D70)),
                    ),
                  ),
                  Positioned(
                    left: mascotLeft.clamp(0.0, width - 32),
                    top: -10,
                    child: WikaMascot(
                      mood: moods[level - 1],
                      size: 32,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),

          // Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: labels.map((l) {
              final idx = labels.indexOf(l);
              final active = idx + 1 <= level;
              return Text(
                l,
                style: GoogleFonts.inter(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  color: active ? const Color(0xFF24304A) : const Color(0xFF94A3B8),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),

          // Feedback container
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: level == 1
                  ? const Color(0xFFFFECEF)
                  : (level == 2 ? const Color(0xFFFFF4D6) : const Color(0xFFE8F8F1)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  messages[level - 1],
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: level == 1
                        ? const Color(0xFF8B2235)
                        : (level == 2 ? const Color(0xFF6A4C00) : const Color(0xFF145B42)),
                    height: 1.4,
                  ),
                ),
                if (level < 3) ...[
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
                          'PETUNJUK',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF4C5FD7),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Coba ganti kata tidak formal atau perbaiki struktur kalimat agar menjadi subjek predikat objek keterangan (SPOK).',
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
