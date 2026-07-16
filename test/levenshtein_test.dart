import 'package:flutter_test/flutter_test.dart';
import 'package:wicara_application_1/core/utils/levenshtein.dart';
import 'package:wicara_application_1/core/utils/spok_analyzer.dart';

void main() {
  group('calculateLevenshteinOps', () {
    test('marks an exact sentence as correct', () {
      final operations = calculateLevenshteinOps(
        ['Saya', 'izin', 'hari ini'],
        ['Saya', 'izin', 'hari ini'],
      );

      expect(
        operations.every((item) => item.type == LevenshteinEditType.correct),
        isTrue,
      );
    });

    test('reports insertion, deletion, and substitution', () {
      expect(
        calculateLevenshteinOps(
          ['Saya', 'sehat'],
          ['Saya', 'sakit'],
        ).where((item) => item.type == LevenshteinEditType.substitution),
        hasLength(1),
      );
      expect(
        calculateLevenshteinOps(
          ['Saya', 'izin', 'sekarang'],
          ['Saya', 'izin'],
        ).where((item) => item.type == LevenshteinEditType.insertion),
        hasLength(1),
      );
      expect(
        calculateLevenshteinOps(
          ['Saya'],
          ['Saya', 'izin'],
        ).where((item) => item.type == LevenshteinEditType.deletion),
        hasLength(1),
      );
    });
  });

  test('analyzeCardErrors calculates a token error rate', () {
    final analysis = analyzeCardErrors(
      ['Saya', 'sakit', 'hari ini'],
      ['Saya', 'izin', 'hari ini'],
    );

    expect(analysis.totalError, 1);
    expect(analysis.errorRate, closeTo(1 / 3, 0.0001));
    expect(analysis.isCorrect, isFalse);
  });
}
