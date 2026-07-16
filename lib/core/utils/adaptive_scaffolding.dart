import 'levenshtein.dart';
import 'spok_analyzer.dart';

enum ScaffoldLevel { p1Visual, p2Soft, p3Hard, p4Constraint }

extension ScaffoldLevelDetails on ScaffoldLevel {
  String get code => switch (this) {
    ScaffoldLevel.p1Visual => 'P1_VISUAL_MORPH',
    ScaffoldLevel.p2Soft => 'P2_SOFT_GLOW',
    ScaffoldLevel.p3Hard => 'P3_GHOST_CARD',
    ScaffoldLevel.p4Constraint => 'P4_UI_CONSTRAINT',
  };

  String get title => switch (this) {
    ScaffoldLevel.p1Visual => 'Coba susun ulang',
    ScaffoldLevel.p2Soft => 'Fokus pada slot yang menyala',
    ScaffoldLevel.p3Hard => 'Cocokkan kartu dengan bayangannya',
    ScaffoldLevel.p4Constraint => 'Ikuti kartu yang aktif',
  };

  String get message => switch (this) {
    ScaffoldLevel.p1Visual =>
      'Kartu kembali dengan gerakan lembut. Perhatikan polanya, lalu coba lagi.',
    ScaffoldLevel.p2Soft =>
      'Slot biru menunjukkan tempat yang perlu kamu isi lebih dulu.',
    ScaffoldLevel.p3Hard =>
      'Cari kartu yang sama dengan bayangan pudar di area jawaban.',
    ScaffoldLevel.p4Constraint =>
      'Satu kartu tetap terang. Pilih kartu itu untuk melanjutkan susunan.',
  };
}

class GuidedAttemptAnalysis {
  final CardAnalysis cardAnalysis;
  final List<int> mismatchedPositions;
  final List<String> errorTypes;

  const GuidedAttemptAnalysis({
    required this.cardAnalysis,
    required this.mismatchedPositions,
    required this.errorTypes,
  });

  bool get isCorrect => cardAnalysis.isCorrect;
}

GuidedAttemptAnalysis analyzeGuidedAttempt(
  List<String> submitted,
  List<String> target,
) {
  final analysis = analyzeCardErrors(submitted, target);
  final positions =
      analysis.operations
          .where((operation) => operation.type != LevenshteinEditType.correct)
          .map((operation) => operation.targetIndex)
          .where((index) => index >= 0)
          .toSet()
          .toList()
        ..sort();
  final types = analysis.operations
      .where((operation) => operation.type != LevenshteinEditType.correct)
      .map((operation) => operation.type.name)
      .toList(growable: false);
  return GuidedAttemptAnalysis(
    cardAnalysis: analysis,
    mismatchedPositions: positions,
    errorTypes: types,
  );
}

ScaffoldLevel scaffoldForWrongAttempt(int wrongAttempt) {
  if (wrongAttempt <= 1) return ScaffoldLevel.p1Visual;
  if (wrongAttempt == 2) return ScaffoldLevel.p2Soft;
  if (wrongAttempt == 3) return ScaffoldLevel.p3Hard;
  return ScaffoldLevel.p4Constraint;
}

int starsForSuccessfulAttempt(int attemptNumber) {
  if (attemptNumber <= 1) return 3;
  if (attemptNumber == 2) return 2;
  return 1;
}
