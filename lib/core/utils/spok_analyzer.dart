import 'levenshtein.dart';

class CardErrorResult {
  final String token;
  final int studentIndex;
  final LevenshteinEditType type;

  const CardErrorResult({
    required this.token,
    required this.studentIndex,
    required this.type,
  });

  bool get isCorrect => type == LevenshteinEditType.correct;
}

class CardAnalysis {
  final int totalError;
  final double errorRate;
  final List<CardErrorResult> cards;
  final List<LevenshteinOp> operations;

  const CardAnalysis({
    required this.totalError,
    required this.errorRate,
    required this.cards,
    required this.operations,
  });

  bool get isCorrect => totalError == 0;
}

CardAnalysis analyzeCardErrors(
  List<String> studentTokens,
  List<String> targetTokens,
) {
  final operations = calculateLevenshteinOps(studentTokens, targetTokens);
  final totalError = operations
      .where((operation) => operation.type != LevenshteinEditType.correct)
      .length;
  final divisor = targetTokens.isEmpty ? 1 : targetTokens.length;
  final cards = operations
      .where((operation) => operation.studentToken != null)
      .map(
        (operation) => CardErrorResult(
          token: operation.studentToken!,
          studentIndex: operation.studentIndex,
          type: operation.type,
        ),
      )
      .toList(growable: false);

  return CardAnalysis(
    totalError: totalError,
    errorRate: totalError / divisor,
    cards: cards,
    operations: operations,
  );
}
