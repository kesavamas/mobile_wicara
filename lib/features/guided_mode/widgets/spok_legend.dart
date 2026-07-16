import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wicara_application_1/core/theme/app_colors.dart';

class SpokLegend extends StatelessWidget {
  const SpokLegend({super.key});

  @override
  Widget build(BuildContext context) {
    const items = [
      ('S', 'Subjek', AppColors.subject, AppColors.subjectInk),
      ('P', 'Predikat', AppColors.predicate, AppColors.predicateInk),
      ('O', 'Objek', AppColors.object, AppColors.objectInk),
      ('K', 'Keterangan', AppColors.adverb, AppColors.adverbInk),
    ];
    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children: items
          .map(
            (item) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
              decoration: BoxDecoration(
                color: item.$3,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${item.$1} · ${item.$2}',
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: item.$4,
                ),
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}
