enum LevenshteinEditType { correct, substitution, insertion, deletion }

class LevenshteinOp {
  final LevenshteinEditType type;
  final int studentIndex;
  final int targetIndex;
  final String? studentToken;
  final String? targetToken;

  const LevenshteinOp({
    required this.type,
    required this.studentIndex,
    required this.targetIndex,
    this.studentToken,
    this.targetToken,
  });
}

String _normalizeToken(String value) => value
    .trim()
    .toLowerCase()
    .replaceAll(RegExp(r'[^a-z0-9\u00c0-\u024f]+'), ' ')
    .replaceAll(RegExp(r'\s+'), ' ');

List<LevenshteinOp> calculateLevenshteinOps(
  List<String> studentTokens,
  List<String> targetTokens,
) {
  final rows = studentTokens.length + 1;
  final columns = targetTokens.length + 1;
  final matrix = List.generate(rows, (_) => List<int>.filled(columns, 0));

  for (var row = 0; row < rows; row++) {
    matrix[row][0] = row;
  }
  for (var column = 0; column < columns; column++) {
    matrix[0][column] = column;
  }

  for (var row = 1; row < rows; row++) {
    for (var column = 1; column < columns; column++) {
      final isMatch =
          _normalizeToken(studentTokens[row - 1]) ==
          _normalizeToken(targetTokens[column - 1]);
      matrix[row][column] = [
        matrix[row - 1][column] + 1,
        matrix[row][column - 1] + 1,
        matrix[row - 1][column - 1] + (isMatch ? 0 : 1),
      ].reduce((a, b) => a < b ? a : b);
    }
  }

  var row = studentTokens.length;
  var column = targetTokens.length;
  final reversed = <LevenshteinOp>[];

  while (row > 0 || column > 0) {
    if (row > 0 && column > 0) {
      final isMatch =
          _normalizeToken(studentTokens[row - 1]) ==
          _normalizeToken(targetTokens[column - 1]);
      final diagonalCost = matrix[row - 1][column - 1] + (isMatch ? 0 : 1);
      if (matrix[row][column] == diagonalCost) {
        reversed.add(
          LevenshteinOp(
            type: isMatch
                ? LevenshteinEditType.correct
                : LevenshteinEditType.substitution,
            studentIndex: row - 1,
            targetIndex: column - 1,
            studentToken: studentTokens[row - 1],
            targetToken: targetTokens[column - 1],
          ),
        );
        row--;
        column--;
        continue;
      }
    }

    if (row > 0 && matrix[row][column] == matrix[row - 1][column] + 1) {
      reversed.add(
        LevenshteinOp(
          type: LevenshteinEditType.insertion,
          studentIndex: row - 1,
          targetIndex: column,
          studentToken: studentTokens[row - 1],
        ),
      );
      row--;
      continue;
    }

    reversed.add(
      LevenshteinOp(
        type: LevenshteinEditType.deletion,
        studentIndex: row,
        targetIndex: column - 1,
        targetToken: targetTokens[column - 1],
      ),
    );
    column--;
  }

  return reversed.reversed.toList(growable: false);
}
