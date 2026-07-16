import 'package:flutter/material.dart';

abstract final class AppColors {
  static const navy = Color(0xFF1F2858);
  static const ink = Color(0xFF1F2858);
  static const text2 = Color(0xFF5D6785);
  static const muted = Color(0xFF8490AA);
  static const indigo = Color(0xFF4C5FD7);
  static const indigoDark = Color(0xFF3445AC);
  static const purple = Color(0xFF6C4FD3);
  static const purpleDark = Color(0xFF5137AA);
  static const softBlue = Color(0xFFEEF3FF);
  static const softPurple = Color(0xFFF1EDFF);
  static const softCoral = Color(0xFFFFECEF);
  static const softMint = Color(0xFFE8F8F1);
  static const softYellow = Color(0xFFFFF6DC);
  static const canvas = Colors.white;
  static const surface = Colors.white;
  static const line = Color(0xFFDDE2F0);
  static const success = Color(0xFF1F9D70);
  static const warning = Color(0xFFE5A91D);
  static const danger = Color(0xFFD9485F);

  static const subject = Color(0xFFEAF2FF);
  static const subjectInk = Color(0xFF163E8C);
  static const predicate = Color(0xFFFFECEF);
  static const predicateInk = Color(0xFF8B2235);
  static const object = Color(0xFFE8F8F1);
  static const objectInk = Color(0xFF145B42);
  static const complement = Color(0xFFEDE9FE);
  static const complementInk = Color(0xFF4C1D95);
  static const adverb = Color(0xFFFFF4D6);
  static const adverbInk = Color(0xFF6A4C00);
}

class SpokPalette {
  final Color background;
  final Color foreground;
  final String label;

  const SpokPalette(this.background, this.foreground, this.label);
}

SpokPalette spokPaletteFor(String role) {
  switch (role.toLowerCase()) {
    case 's':
      return const SpokPalette(
        AppColors.subject,
        AppColors.subjectInk,
        'Subjek',
      );
    case 'p':
      return const SpokPalette(
        AppColors.predicate,
        AppColors.predicateInk,
        'Predikat',
      );
    case 'o':
      return const SpokPalette(AppColors.object, AppColors.objectInk, 'Objek');
    case 'pel':
      return const SpokPalette(
        AppColors.complement,
        AppColors.complementInk,
        'Pelengkap',
      );
    case 'k':
    default:
      return const SpokPalette(
        AppColors.adverb,
        AppColors.adverbInk,
        'Keterangan',
      );
  }
}
