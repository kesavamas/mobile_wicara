import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wicara_application_1/core/theme/app_colors.dart';

class WordCard extends StatelessWidget {
  final String word;
  final String role;
  final VoidCallback? onTap;
  final bool hasError;
  final bool selected;

  const WordCard({
    super.key,
    required this.word,
    required this.role,
    this.onTap,
    this.hasError = false,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final palette = spokPaletteFor(role);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
          decoration: BoxDecoration(
            color: hasError ? const Color(0xFFFFE4E6) : palette.background,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: hasError
                  ? AppColors.danger
                  : selected
                  ? palette.foreground
                  : palette.foreground.withValues(alpha: 0.28),
              width: selected || hasError ? 2 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: (hasError ? AppColors.danger : palette.foreground)
                    .withValues(alpha: 0.12),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            word,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: hasError ? AppColors.danger : palette.foreground,
            ),
          ),
        ),
      ),
    );
  }
}
