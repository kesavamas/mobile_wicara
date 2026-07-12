import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RevisionScreen extends StatelessWidget {
  const RevisionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          'Lihat Perubahan Pesan',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Bandingkan susunan ini untuk melihat peran setiap kata.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF667085),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),

            // Before Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F8FC),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFE4E7EC)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pesan Awal',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1F2858),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F4FA),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Sebelum',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF667085),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildWordBadge('Saya', 'S', const Color(0xFFEAF2FF), const Color(0xFF4D91FF), const Color(0xFF163E8C)),
                      _buildWordBadge('tidak masuk', 'P', const Color(0xFFFFECEF), const Color(0xFFD9485F), const Color(0xFF8B2235)),
                      _buildWordBadge('hari ini', 'K', const Color(0xFFFFF4D6), const Color(0xFFE5A91D), const Color(0xFF6A4C00)),
                      _buildWordBadge('sakit', 'Pel', const Color(0xFFF1EAFE), const Color(0xFF7C3AED), const Color(0xFF4C1D95)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // After Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFDDF8EA).withOpacity(0.4),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFDDF8EA)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Setelah Dirapikan',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1F2858),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDDF8EA),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Sesudah',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1B7A4E),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildWordBadge('Saya', 'S', const Color(0xFFEAF2FF), const Color(0xFF4D91FF), const Color(0xFF163E8C)),
                      _buildWordBadge('izin tidak masuk', 'P', const Color(0xFFFFECEF), const Color(0xFFD9485F), const Color(0xFF8B2235)),
                      _buildWordBadge('sekolah', 'O', const Color(0xFFE8F8F1), const Color(0xFF1F9D70), const Color(0xFF145B42)),
                      _buildWordBadge('hari ini', 'K', const Color(0xFFFFF4D6), const Color(0xFFE5A91D), const Color(0xFF6A4C00)),
                      _buildWordBadge('karena sakit', 'Pel', const Color(0xFFF1EAFE), const Color(0xFF7C3AED), const Color(0xFF4C1D95)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Color legend card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFE7F4FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Keterangan warna',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF2943A6),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildLegendBadge('S — Subjek', const Color(0xFFEAF2FF), const Color(0xFF4D91FF), const Color(0xFF163E8C)),
                      _buildLegendBadge('P — Predikat', const Color(0xFFFFECEF), const Color(0xFFD9485F), const Color(0xFF8B2235)),
                      _buildLegendBadge('O — Objek', const Color(0xFFE8F8F1), const Color(0xFF1F9D70), const Color(0xFF145B42)),
                      _buildLegendBadge('K — Keterangan', const Color(0xFFFFF4D6), const Color(0xFFE5A91D), const Color(0xFF6A4C00)),
                      _buildLegendBadge('Pel — Pelengkap', const Color(0xFFF1EAFE), const Color(0xFF7C3AED), const Color(0xFF4C1D95)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),

            ElevatedButton(
              onPressed: () {
                // Navigate back to map / dashboard
                Navigator.pop(context); // pop revision
                Navigator.pop(context); // pop independent mode
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
                    'Gunakan Susunan Ini',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.check_rounded, size: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWordBadge(String word, String role, Color bg, Color border, Color textClr) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: border, shape: BoxShape.circle),
            child: Text(
              role,
              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white),
            ),
          ),
          const SizedBox(width: 6),
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
    );
  }

  Widget _buildLegendBadge(String label, Color bg, Color border, Color textClr) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border, width: 1.5),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: textClr,
        ),
      ),
    );
  }
}
