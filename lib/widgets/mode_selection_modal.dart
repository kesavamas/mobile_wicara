import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wicara_application_1/models/bilik.dart';
import 'package:wicara_application_1/widgets/wika_mascot.dart';

class ModeSelectionModal extends StatelessWidget {
  final Bilik bilik;
  final BilikLevel level;
  final bool isCompleted;
  final VoidCallback onStartGuided;
  final VoidCallback onStartIndependent;

  const ModeSelectionModal({
    Key? key,
    required this.bilik,
    required this.level,
    required this.isCompleted,
    required this.onStartGuided,
    required this.onStartIndependent,
  }) : super(key: key);

  Color _parseColor(String hex) {
    var value = hex.replaceAll('#', '');
    if (value.length == 6) value = 'FF$value';
    return Color(int.parse(value, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final brandColor = _parseColor(bilik.color);
    final softBg = _parseColor(bilik.colorTheme.soft);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD0D5DD),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: softBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFDCE2F0)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFC4CBDF)),
                        ),
                        child: Text(
                          '🎯 Misi Baru!',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: brandColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        level.title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1F2858),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Pilih cara bermainmu',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF5D6785),
                        ),
                      ),
                    ],
                  ),
                ),
                const WikaMascot(
                  mood: WikaMood.hint,
                  size: 64,
                  animated: false,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Guided Mode Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF3FF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFC4CBDF), width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4C5FD7),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  '⭐ Direkomendasikan',
                                  style: GoogleFonts.inter(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(color: const Color(0xFFE5A91D)),
                                ),
                                child: Text(
                                  '+50 XP',
                                  style: GoogleFonts.inter(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF6A4C00),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Mode Terpandu',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1F2858),
                            ),
                          ),
                          Text(
                            'Susun Kartu Kata',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF4C5FD7),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Geser dan susun kartu hingga menjadi pesan yang jelas.',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: const Color(0xFF5D6785),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFDDE2F0)),
                      ),
                      child: const Icon(
                        Icons.open_in_full_rounded,
                        color: Color(0xFF4C5FD7),
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: onStartGuided,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4C5FD7),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Mainkan Sekarang',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_forward_rounded, size: 14),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Independent Mode Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isCompleted ? const Color(0xFFF1EDFF) : const Color(0xFFF7F8FC),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isCompleted ? const Color(0xFFD8CCFA) : const Color(0xFFDDE2F0),
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isCompleted ? Colors.white : const Color(0xFFEEF0F5),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isCompleted ? const Color(0xFFD8CCFA) : const Color(0xFFDDE2F0),
                        ),
                      ),
                      child: Icon(
                        isCompleted ? Icons.lock_open_rounded : Icons.lock_rounded,
                        color: isCompleted ? const Color(0xFF6C4FD3) : const Color(0xFF69738F),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mode Mandiri',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1F2858),
                            ),
                          ),
                          Text(
                            'Tulis Pesanmu Sendiri',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF6C4FD3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) => Icon(
                    Icons.star_rounded,
                    size: 20,
                    color: isCompleted ? const Color(0xFFFFD36A) : const Color(0xFFDDE2F0),
                  )),
                ),
                const SizedBox(height: 8),
                Text(
                  isCompleted
                      ? 'Tulis pesanmu sendiri dan dapatkan petunjuk formalitas.'
                      : 'Dapatkan 3 bintang di Mode Terpandu untuk membuka mode ini.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xFF5D6785),
                    height: 1.4,
                  ),
                ),
                if (isCompleted) ...[
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: onStartIndependent,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C4FD3),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Mulai Mode Mandiri',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward_rounded, size: 14),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Close button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Tutup',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF8490AA),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
