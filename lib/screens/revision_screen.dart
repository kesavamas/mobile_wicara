import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wicara_application_1/models/bilik.dart';

class RevisionScreen extends StatefulWidget {
  final Bilik bilik;
  final BilikLevel level;
  final String userInput;
  final int formalityScore;

  const RevisionScreen({
    Key? key,
    required this.bilik,
    required this.level,
    required this.userInput,
    required this.formalityScore,
  }) : super(key: key);

  @override
  State<RevisionScreen> createState() => _RevisionScreenState();
}

class _RevisionScreenState extends State<RevisionScreen> {
  String _getCorrectedSentence() {
    final spok = widget.level.spokAnswer;
    final List<String> parts = [];
    if (spok.s.isNotEmpty) parts.add(spok.s);
    
    // Customize predikat for level 2 akademik if needed
    if (widget.level.id == 2 && widget.bilik.id == 'akademik') {
      parts.add("ingin mengumpulkan");
    } else {
      if (spok.p.isNotEmpty) parts.add(spok.p);
    }
    
    if (spok.o.isNotEmpty) parts.add(spok.o);
    if (spok.k.isNotEmpty) parts.add(spok.k);
    
    return parts.join(' ');
  }

  Map<String, List<String>> _generateFeedback() {
    final List<String> corrections = [];
    final List<String> tips = [];
    final inputLower = widget.userInput.toLowerCase();

    // Level 2 Akademik
    if (widget.level.id == 2 && widget.bilik.id == 'akademik') {
      if (inputLower.contains('aku') || !inputLower.contains('saya')) {
        corrections.add("Kata 'aku' diganti 'Saya' agar lebih formal.");
        tips.add("Gunakan 'Saya' untuk diri sendiri dalam situasi formal.");
      }
      if (inputLower.contains('ngumpulin')) {
        corrections.add("Kata 'ngumpulin' diganti 'mengumpulkan' agar sesuai kaidah bahasa baku.");
        tips.add("Perhatikan akhiran kata kerja agar baku (misal: 'ngumpulin' -> 'mengumpulkan').");
      }
      if (corrections.isEmpty) {
        corrections.add("Susunan kalimatmu sudah tepat dan formal!");
        tips.add("Gunakan 'Saya' untuk diri sendiri dalam situasi formal.");
        tips.add("Gunakan kata kerja aktif dengan imbuhan me- untuk kesan profesional.");
      }
    } 
    // Level 1 Akademik
    else if (widget.level.id == 1 && widget.bilik.id == 'akademik') {
      if (inputLower.contains('aku')) {
        corrections.add("Kata 'aku' diganti 'Saya' agar lebih formal.");
        tips.add("Gunakan 'Saya' untuk diri sendiri dalam situasi formal.");
      }
      if (inputLower.contains('nggak') || inputLower.contains('gak') || inputLower.contains('tidak masuk')) {
        corrections.add("Kata 'nggak masuk' diganti 'tidak hadir' agar lebih sopan dan resmi.");
        tips.add("Gunakan 'tidak hadir' sebagai ganti 'nggak masuk' saat berkirim pesan ke guru.");
      }
      if (inputLower.contains('gara-gara')) {
        corrections.add("Kata 'gara-gara' diganti 'karena' untuk memperjelas hubungan sebab-akibat secara formal.");
        tips.add("Gunakan konjungsi formal 'karena' dalam surat izin.");
      }
      if (corrections.isEmpty) {
        corrections.add("Susunan kalimatmu sudah tepat dan formal!");
        tips.add("Gunakan 'Saya' untuk diri sendiri dalam situasi formal.");
        tips.add("Gunakan konjungsi formal 'karena' untuk menjelaskan alasan.");
      }
    } 
    // Other cases
    else {
      if (inputLower.contains('aku') || inputLower.contains('gw') || inputLower.contains('gua')) {
        corrections.add("Kata ganti orang pertama kurang formal diganti dengan 'Saya'.");
        tips.add("Gunakan 'Saya' untuk diri sendiri dalam situasi formal.");
      }
      if (inputLower.contains('kamu') || inputLower.contains('lu')) {
        corrections.add("Kata ganti orang kedua diganti dengan sebutan hormat (Bapak/Ibu/Anda).");
        tips.add("Gunakan sebutan hormat seperti 'Bapak/Ibu' saat berinteraksi dengan atasan atau dosen.");
      }
      if (corrections.isEmpty) {
        corrections.add("Susunan kalimatmu sudah sangat baik dan sesuai kaidah SPOK.");
        tips.add("Pastikan kalimat diawali subjek yang jelas dan diakhiri dengan keterangan penjelas.");
      }
    }

    return {
      'corrections': corrections,
      'tips': tips,
    };
  }

  void _showSpokExplanation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Apa arti SPOK?',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSpokInfoItem('S', 'Subjek', 'Pelaku dalam kalimat (siapa/apa). Contoh: Saya, Ibu, Kucing.', const Color(0xFF3B82F6)),
              const Divider(height: 24, color: Color(0xFFF1F5F9)),
              _buildSpokInfoItem('P', 'Predikat', 'Tindakan atau aktivitas yang dilakukan (melakukan apa). Contoh: menulis, ingin mengumpulkan, sedang tidur.', const Color(0xFFEF4444)),
              const Divider(height: 24, color: Color(0xFFF1F5F9)),
              _buildSpokInfoItem('O', 'Objek', 'Sasaran dari tindakan (apa/siapa yang dikenai tindakan). Contoh: tugas, buku, makanan.', const Color(0xFFF59E0B)),
              const Divider(height: 24, color: Color(0xFFF1F5F9)),
              _buildSpokInfoItem('K', 'Keterangan', 'Penjelas tentang tempat, waktu, cara, atau sebab-akibat. Contoh: besok, di kelas, karena sakit.', const Color(0xFF10B981)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Mengerti',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF4C5FD7),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSpokInfoItem(String char, String title, String desc, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Center(
            child: Text(
              char,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showSpokExamples() {
    List<String> examples = [];
    if (widget.bilik.id == 'akademik') {
      examples = [
        "Saya (S) menyerahkan (P) surat izin (O) hari ini (K).",
        "Dosen (S) memeriksa (P) tugas remedial (O) kemarin (K).",
        "Kami (S) meminjam (P) alat laboratorium (O) bersama (K)."
      ];
    } else if (widget.bilik.id == 'profesional') {
      examples = [
        "Saya (S) melampirkan (P) CV terbaru (O) di email (K).",
        "HRD (S) mengirimkan (P) penawaran kerja (O) tadi pagi (K).",
        "Kami (S) akan mengadakan (P) rapat evaluasi (O) besok (K)."
      ];
    } else {
      examples = [
        "Saya (S) melapor (P) dompet hilang (O) ke petugas (K).",
        "Nina (S) menukar (P) barang rusak (O) di toko (K)."
      ];
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Contoh Kalimat SPOK',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: examples.map((ex) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF10B981), size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    ex,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: const Color(0xFF334155),
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Tutup',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF4C5FD7),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final score = widget.formalityScore;
    String scoreText = 'Cukup formal';
    Color scoreColor = const Color(0xFFF59E0B);
    if (score < 40) {
      scoreText = 'Kurang formal';
      scoreColor = const Color(0xFFEF4444);
    } else if (score >= 75) {
      scoreText = 'Sangat formal';
      scoreColor = const Color(0xFF10B981);
    }

    final feedback = _generateFeedback();
    final List<String> corrections = feedback['corrections'] ?? [];
    final List<String> tips = feedback['tips'] ?? [];

    final spok = widget.level.spokAnswer;
    final List<Widget> badges = [];
    if (spok.s.isNotEmpty) {
      badges.add(_buildTreeBadge('SUBJEK', spok.s, const Color(0xFF3B82F6)));
    }
    if (spok.p.isNotEmpty) {
      final predikatText = (widget.level.id == 2 && widget.bilik.id == 'akademik')
          ? "ingin mengumpulkan"
          : spok.p;
      badges.add(_buildTreeBadge('PREDIKAT', predikatText, const Color(0xFFEF4444)));
    }
    if (spok.o.isNotEmpty) {
      badges.add(_buildTreeBadge('OBJEK', spok.o, const Color(0xFFF59E0B)));
    }
    if (spok.k.isNotEmpty) {
      badges.add(_buildTreeBadge('KETERANGAN', spok.k, const Color(0xFF10B981)));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Custom Top Bar with Back Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A), size: 26),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    'Analisis Kalimat',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
            
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Formality Level Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'TINGKAT FORMAL KALIMATMU',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF64748B),
                            letterSpacing: 0.8,
                          ),
                        ),
                        Text(
                          '$score/100 · $scoreText',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: scoreColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        minHeight: 12,
                        value: score / 100.0,
                        backgroundColor: const Color(0xFFE2E8F0),
                        valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Tree Diagram Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F172A).withOpacity(0.03),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'POHON KALIMAT',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF64748B),
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Root Capsule (Sentence)
                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF0F172A).withOpacity(0.04),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Text(
                                _getCorrectedSentence(),
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                            ),
                          ),
                          
                          // Connecting Lines Tree structure
                          LayoutBuilder(
                            builder: (context, constraints) {
                              return CustomPaint(
                                size: Size(constraints.maxWidth, 40),
                                painter: TreeLinesPainter(numBadges: badges.length),
                              );
                            },
                          ),
                          
                          // Badges Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: badges,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Corrections Card
                    if (corrections.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF), // light indigo
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFE0E7FF), width: 1.5),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.edit_outlined,
                              color: Color(0xFF4C5FD7),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: corrections.map((corr) => Padding(
                                  padding: const EdgeInsets.only(bottom: 6.0),
                                  child: Text(
                                    corr,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF3730A3),
                                      height: 1.45,
                                    ),
                                  ),
                                )).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Tips Card
                    if (tips.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFDF5), // light yellow
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFFEF3C7), width: 1.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: tips.map((tip) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.lightbulb_outline_rounded,
                                  color: Color(0xFFD97706),
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    tip,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF92400E),
                                      height: 1.45,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )).toList(),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Quick Actions horizontal list
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          _buildQuickActionButton('Apa arti SPOK?', _showSpokExplanation),
                          const SizedBox(width: 10),
                          _buildQuickActionButton('Contoh kalimat SPOK lainnya?', _showSpokExamples),
                          const SizedBox(width: 10),
                          _buildQuickActionButton('Perbaiki kalimatku lagi?', () {
                            Navigator.pop(context);
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Navigation Bar
            _buildBottomNavBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTreeBadge(String role, String word, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              role,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 8.5,
                fontWeight: FontWeight.w900,
                color: Colors.white.withOpacity(0.8),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              word,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
        ),
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF4C5FD7),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: const Color(0xFFEEF2FF), width: 1.5)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavBarItem(0, Icons.home_outlined, 'Bilik', () {
            // Navigate back to levels map/main layout
            Navigator.pop(context); // pop revision screen
            Navigator.pop(context); // pop independent screen
          }),
          _buildNavBarItem(1, Icons.leaderboard_outlined, 'Raport', () {
            // Show alert or pop back
            Navigator.pop(context);
            Navigator.pop(context);
          }),
          _buildNavBarActiveItem(2, Icons.auto_awesome_rounded, 'Tanya AI'),
          _buildNavBarItem(3, Icons.person_outline_rounded, 'Profil', () {
            // pop back to home page
            Navigator.pop(context);
            Navigator.pop(context);
          }),
        ],
      ),
    );
  }

  Widget _buildNavBarItem(int index, IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF94A3B8), size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBarActiveItem(int index, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF), // light purple bubble
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF4C5FD7), size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF4C5FD7),
            ),
          ),
        ],
      ),
    );
  }
}

class TreeLinesPainter extends CustomPainter {
  final int numBadges;

  TreeLinesPainter({required this.numBadges});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFCBD5E1) // slate-300
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final w = size.width;
    final h = size.height;
    final midY = h / 2;

    // Draw main vertical line from root (top center) to midpoint
    canvas.drawLine(Offset(w / 2, 0), Offset(w / 2, midY), paint);

    if (numBadges > 0) {
      final List<double> xCoords = [];
      for (int i = 0; i < numBadges; i++) {
        xCoords.add((i + 0.5) * (w / numBadges));
      }

      // Draw horizontal bar connecting the branches
      canvas.drawLine(Offset(xCoords.first, midY), Offset(xCoords.last, midY), paint);

      // Draw vertical branch lines down to each badge
      for (final x in xCoords) {
        canvas.drawLine(Offset(x, midY), Offset(x, h), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
