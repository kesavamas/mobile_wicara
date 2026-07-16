import 'package:flutter_test/flutter_test.dart';
import 'package:wicara_application_1/core/utils/adaptive_scaffolding.dart';

void main() {
  test('scaffolding rises gradually and caps at P4', () {
    expect(scaffoldForWrongAttempt(1), ScaffoldLevel.p1Visual);
    expect(scaffoldForWrongAttempt(2), ScaffoldLevel.p2Soft);
    expect(scaffoldForWrongAttempt(3), ScaffoldLevel.p3Hard);
    expect(scaffoldForWrongAttempt(9), ScaffoldLevel.p4Constraint);
  });

  test('stars reward first, second, and later successful attempts', () {
    expect(starsForSuccessfulAttempt(1), 3);
    expect(starsForSuccessfulAttempt(2), 2);
    expect(starsForSuccessfulAttempt(3), 1);
    expect(starsForSuccessfulAttempt(8), 1);
  });

  test('guided analysis exposes error positions and raw edit types', () {
    final result = analyzeGuidedAttempt(['Bapak', 'Yth.'], ['Yth.', 'Bapak']);
    expect(result.isCorrect, isFalse);
    expect(result.mismatchedPositions, isNotEmpty);
    expect(result.errorTypes, isNotEmpty);
  });
}
