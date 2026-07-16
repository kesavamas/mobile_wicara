import 'dart:math';

import 'package:wicara_application_1/models/revision3_content.dart';

class FormalToken {
  final String text;
  final String role;
  final bool misplaced;

  const FormalToken({
    required this.text,
    required this.role,
    required this.misplaced,
  });
}

class SentenceChunk {
  final String role;
  final String text;

  const SentenceChunk({required this.role, required this.text});
}

class FormalTextAnalysis {
  final int score;
  final List<FormalToken> tokens;
  final List<SentenceChunk> chunks;
  final String feedback;
  final String hint;

  const FormalTextAnalysis({
    required this.score,
    required this.tokens,
    required this.chunks,
    required this.feedback,
    required this.hint,
  });

  bool get isFullyFormal => score >= 81;
  double get meterValue => score / 100;
}

FormalTextAnalysis analyzeFormalText(String input, LearningMission mission) {
  final words = _tokenize(input);
  final targetWords = _tokenize(mission.guided.fullMessage);
  final roleDictionary = <String, String>{};
  for (final round in mission.guided.rounds) {
    for (final card in round.cards.where((card) => !card.distractor)) {
      for (final word in _tokenize(card.text)) {
        roleDictionary[word] = _normalizeRole(card.kind);
      }
    }
  }

  final rawRoles = words
      .map((word) => _classify(word, roleDictionary))
      .toList(growable: false);
  var furthestRank = 0;
  final tokens = <FormalToken>[];
  for (var index = 0; index < words.length; index++) {
    final role = rawRoles[index];
    final rank = _roleRank(role);
    final misplaced = rank > 0 && rank + 1 < furthestRank;
    if (rank > furthestRank) furthestRank = rank;
    tokens.add(
      FormalToken(text: words[index], role: role, misplaced: misplaced),
    );
  }

  final targetKeywords = targetWords
      .where((word) => !_stopWords.contains(word))
      .toSet();
  final inputKeywords = words.toSet();
  final covered = targetKeywords.where(inputKeywords.contains).length;
  final coverage = targetKeywords.isEmpty
      ? 1.0
      : covered / targetKeywords.length;
  final ordered = tokens.where((token) => token.role != 'Lainnya').toList();
  final orderQuality = ordered.isEmpty
      ? 0.0
      : ordered.where((token) => !token.misplaced).length / ordered.length;
  final hasFormalIdentity = words.any(
    {'saya', 'bapak', 'ibu', 'yth', 'selamat', 'mohon'}.contains,
  );
  final hasPurpose = rawRoles.any((role) => role == 'Predikat');
  final hasContext = rawRoles.any(
    (role) => role == 'Objek' || role == 'Keterangan',
  );
  final informalCount = words.where(_informalWords.contains).length;

  var score = 15;
  score += (coverage * 35).round();
  score += (orderQuality * 20).round();
  if (hasFormalIdentity) score += 12;
  if (hasPurpose) score += 10;
  if (hasContext) score += 8;
  score -= informalCount * 18;
  if (words.length < 4) score = min(score, 45);
  score = score.clamp(0, 100);

  final feedback = switch (score) {
    <= 50 =>
      'Pesan masih butuh penyesuaian. Yuk, coba susun lagi biar lebih mudah dipahami!',
    <= 80 =>
      'Pesan sudah jelas! Tinggal dirapikan sedikit lagi agar lebih formal.',
    _ => 'Sangat Formal! Susunan kalimatmu sudah tepat!',
  };
  final hint = _buildHint(
    tokens: tokens,
    hasFormalIdentity: hasFormalIdentity,
    hasPurpose: hasPurpose,
    informalCount: informalCount,
  );

  return FormalTextAnalysis(
    score: score,
    tokens: tokens,
    chunks: _buildChunks(tokens),
    feedback: feedback,
    hint: hint,
  );
}

List<String> _tokenize(String value) => RegExp(r'[A-Za-zÀ-ɏ]+')
    .allMatches(value.toLowerCase())
    .map((match) => match.group(0)!)
    .toList(growable: false);

String _normalizeRole(String kind) => switch (kind) {
  's' => 'Subjek',
  'p' => 'Predikat',
  'o' => 'Objek',
  'k' || 'waktu' => 'Keterangan',
  'pel' => 'Pelengkap',
  'salam' || 'sapaan' || 'hormat' => 'Pembuka',
  _ => 'Lainnya',
};

String _classify(String word, Map<String, String> dictionary) {
  final known = dictionary[word];
  if (known != null) return known;
  if (_subjectWords.contains(word)) return 'Subjek';
  if (_predicateWords.contains(word)) return 'Predikat';
  if (_timeWords.contains(word) || _placeWords.contains(word)) {
    return 'Keterangan';
  }
  if (_openingWords.contains(word)) return 'Pembuka';
  return 'Lainnya';
}

int _roleRank(String role) => switch (role) {
  'Pembuka' => 0,
  'Subjek' => 1,
  'Predikat' => 2,
  'Objek' || 'Pelengkap' => 3,
  'Keterangan' => 4,
  _ => 0,
};

List<SentenceChunk> _buildChunks(List<FormalToken> tokens) {
  final chunks = <SentenceChunk>[];
  for (final token in tokens) {
    final role = token.role == 'Lainnya' ? 'Pelengkap' : token.role;
    if (chunks.isNotEmpty && chunks.last.role == role) {
      final previous = chunks.removeLast();
      chunks.add(
        SentenceChunk(role: role, text: '${previous.text} ${token.text}'),
      );
    } else {
      chunks.add(SentenceChunk(role: role, text: token.text));
    }
  }
  return chunks;
}

String _buildHint({
  required List<FormalToken> tokens,
  required bool hasFormalIdentity,
  required bool hasPurpose,
  required int informalCount,
}) {
  if (informalCount > 0) {
    return 'Pesanmu sudah punya maksud. Coba gunakan kata yang lebih formal, misalnya “Saya” atau “mohon”.';
  }
  final misplaced = tokens.where((token) => token.misplaced).firstOrNull;
  if (misplaced != null) {
    return 'Pesan sudah bagus! Coba pindahkan bagian ${misplaced.role.toLowerCase()} yang berwarna ke posisi yang lebih rapi.';
  }
  if (!hasFormalIdentity) {
    return 'Mulai dengan sapaan atau kata “Saya” agar penerima pesan langsung memahami siapa yang berbicara.';
  }
  if (!hasPurpose) {
    return 'Tambahkan kegiatan atau tujuan pesan setelah menyebutkan diri.';
  }
  return 'Tambahkan alasan, waktu, atau tempat di bagian akhir agar pesan semakin lengkap.';
}

const _stopWords = {
  'dan',
  'di',
  'ke',
  'dari',
  'yang',
  'untuk',
  'pada',
  'dengan',
};
const _informalWords = {
  'aku',
  'gue',
  'gua',
  'lu',
  'lo',
  'nggak',
  'gak',
  'ga',
  'banget',
  'gara',
};
const _subjectWords = {'saya', 'kami', 'kita', 'bapak', 'ibu', 'hrd'};
const _predicateWords = {
  'izin',
  'memohon',
  'mohon',
  'mengajukan',
  'bertanya',
  'meminjam',
  'bersedia',
  'datang',
  'mengikuti',
};
const _timeWords = {
  'hari',
  'ini',
  'besok',
  'pagi',
  'siang',
  'sore',
  'terlambat',
};
const _placeWords = {'sekolah', 'kantor', 'laboratorium', 'perusahaan'};
const _openingWords = {'yth', 'selamat', 'kepada', 'hormat'};

extension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    return iterator.moveNext() ? iterator.current : null;
  }
}
