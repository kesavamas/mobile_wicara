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
    final isSchool = widget.bilik.id == 'akademik';
    final initialText = isSchool
        ? 'Saya tidak masuk hari ini sakit.'
        : 'Saya ingin magang di perusahaan Bapak.';
    _textController = TextEditingController(text: initialText);
    _charCount = initialText.length;
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

  @override
  Widget build(BuildContext context) {
    final brandColor = _parseColor(widget.bilik.color);
    final isSchool = widget.bilik.id == 'akademik';
    final recipientName = isSchool ? 'Bapak Wali Kelas' : 'HRD Perusahaan X';

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        title: Text(
          'Mode Mandiri',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF4C5FD7),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Latihan Mandiri',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Chat Header Block
          Container(
            color: const Color(0xFF4C5FD7),
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(14),
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
                            recipientName,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '● Simulasi Latihan',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.7),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Wika Mascot bubble introduction
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      const WikaMascot(
                        mood: WikaMood.hint,
                        size: 40,
                        animated: false,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Wika: Tulis pesan formal yang ingin kamu sampaikan. Tunjukkan kesopanan komunikasimu.',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.white,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Message details or email form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!isSchool) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE4E7EC)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Kepada: HRD Perusahaan X', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold)),
                          const Divider(height: 16),
                          Text('Subjek: Permohonan Magang', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Text area container
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFDCE1EA)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'TULISKAN PESANMU',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF667085),
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _textController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF24304A),
                          ),
                        ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                _buildMiniToolbarButton(Icons.book_rounded, const Color(0xFFE7F4FF), const Color(0xFF4263EB)),
                                const SizedBox(width: 8),
                                _buildMiniToolbarButton(Icons.auto_awesome_rounded, const Color(0xFFFFF3C7), const Color(0xFF8A6200)),
                              ],
                            ),
                            Text(
                              '$_charCount karakter',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF98A2B3),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Formality Indicator (if checked)
                  if (_checked)
                    _buildFormalityMeter(),
                ],
              ),
            ),
          ),

          // Bottom check actions
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
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
                        'Lihat Formalitas',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.bolt_rounded, size: 16),
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
                            color: const Color(0xFF4263EB),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward_rounded, color: Color(0xFF4263EB), size: 14),
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
    // Basic scoring based on contains key formal words
    final text = _textController.text.toLowerCase();
    int score = 30;
    if (text.contains('izin') || text.contains('magang')) score += 30;
    if (text.contains('karena') || text.contains('atas perhatian')) score += 30;
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE4E7EC)),
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
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  minHeight: 12,
                  value: score / 100.0,
                  backgroundColor: const Color(0xFFE4E7EC),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1F9D70)),
                ),
              ),
              // Positioning mascot head dynamically
              Positioned(
                left: (score * 2.8).clamp(0.0, 270.0), // Simple math scaling
                top: -12,
                child: WikaMascot(
                  mood: moods[level - 1],
                  size: 32,
                  animated: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: labels.map((l) => Text(
              l,
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: labels.indexOf(l) + 1 <= level ? const Color(0xFF24304A) : const Color(0xFFC4CBDA),
              ),
            )).toList(),
          ),
          const SizedBox(height: 16),

          // Feedback container
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: level == 1
                  ? const Color(0xFFFFE5E1)
                  : (level == 2 ? const Color(0xFFFFF3C7) : const Color(0xFFDDF8EA)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  messages[level - 1],
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: level == 1
                        ? const Color(0xFFC0392B)
                        : (level == 2 ? const Color(0xFF8A6200) : const Color(0xFF1B7A4E)),
                  ),
                ),
                if (level < 3) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
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
                            color: const Color(0xFF4263EB),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Coba ganti kata tidak formal atau perbaiki struktur kalimat agar menjadi subjek predikat objek keterangan (SPOK).',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: const Color(0xFF667085),
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
