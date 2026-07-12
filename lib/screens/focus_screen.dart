import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wicara_application_1/widgets/wika_mascot.dart';

class FocusScreen extends StatelessWidget {
  const FocusScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> words = [
      {'text': 'SAYA', 'label': 'Subjek · S', 'color': const Color(0xFFEAF2FF), 'border': const Color(0xFF4D91FF), 'textClr': const Color(0xFF163E8C)},
      {'text': 'IZIN TIDAK MASUK', 'label': 'Predikat · P', 'color': const Color(0xFFFFECEF), 'border': const Color(0xFFD9485F), 'textClr': const Color(0xFF8B2235)},
      {'text': 'SEKOLAH', 'label': 'Objek · O', 'color': const Color(0xFFE8F8F1), 'border': const Color(0xFF1F9D70), 'textClr': const Color(0xFF145B42)},
      {'text': 'HARI INI', 'label': 'Keterangan · K', 'color': const Color(0xFFFFF4D6), 'border': const Color(0xFFE5A91D), 'textClr': const Color(0xFF6A4C00)},
      {'text': 'KARENA SAKIT', 'label': 'Pelengkap', 'color': const Color(0xFFF1EAFE), 'border': const Color(0xFF7C3AED), 'textClr': const Color(0xFF4C1D95)},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF8),
      body: Stack(
        children: [
          // Whiteboard background with grid lines
          Positioned.fill(
            child: GridPaper(
              color: const Color(0xFFE4E7EC).withOpacity(0.5),
              divisions: 1,
              subdivisions: 1,
              interval: 28,
              child: Container(),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                // Header logo & text
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const WikaMascot(
                      mood: WikaMood.hint,
                      size: 42,
                      animated: false,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'WICARA · POHON KALIMAT',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2.0,
                        color: const Color(0xFFC4CBDA),
                      ),
                    ),
                  ],
                ),
                const Spacer(),

                // Magnetic word cards list
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Wrap(
                    spacing: 12.0,
                    runSpacing: 16.0,
                    alignment: WrapAlignment.center,
                    children: words.map((w) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: w['color'] as Color,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: w['border'] as Color, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF24304A).withOpacity(0.08),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              w['text'] as String,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: w['textClr'] as Color,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              w['label'] as String,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: (w['textClr'] as Color).withOpacity(0.65),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 48),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Text(
                    'Saya izin tidak masuk sekolah hari ini karena sakit.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF475467),
                    ),
                  ),
                ),
                const Spacer(),

                // Exit controls
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.96),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE4E7EC)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close_rounded, color: Color(0xFF475467)),
                          label: Text(
                            'Keluar',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF475467),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE7F4FF),
                            foregroundColor: const Color(0xFF4263EB),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.edit_note_rounded),
                          label: Text(
                            'Ganti kalimat',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w800,
                            ),
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
    );
  }
}
