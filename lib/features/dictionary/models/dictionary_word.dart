enum DictionaryRole { subject, predicate, object, adverb, complement }

extension DictionaryRoleInfo on DictionaryRole {
  String get id => switch (this) {
    DictionaryRole.subject => 's',
    DictionaryRole.predicate => 'p',
    DictionaryRole.object => 'o',
    DictionaryRole.adverb => 'k',
    DictionaryRole.complement => 'pel',
  };

  String get shortLabel => switch (this) {
    DictionaryRole.subject => 'S',
    DictionaryRole.predicate => 'P',
    DictionaryRole.object => 'O',
    DictionaryRole.adverb => 'K',
    DictionaryRole.complement => 'Pel',
  };

  String get label => switch (this) {
    DictionaryRole.subject => 'Subjek',
    DictionaryRole.predicate => 'Predikat',
    DictionaryRole.object => 'Objek',
    DictionaryRole.adverb => 'Keterangan',
    DictionaryRole.complement => 'Pelengkap',
  };

  String get question => switch (this) {
    DictionaryRole.subject => 'Siapa yang melakukan?',
    DictionaryRole.predicate => 'Apa yang dilakukan?',
    DictionaryRole.object => 'Apa yang dikenai kegiatan?',
    DictionaryRole.adverb => 'Kapan, di mana, atau mengapa?',
    DictionaryRole.complement => 'Apa yang melengkapi makna?',
  };

  String get description => switch (this) {
    DictionaryRole.subject => 'Orang atau benda yang melakukan kegiatan.',
    DictionaryRole.predicate => 'Kegiatan atau keadaan yang sedang dilakukan.',
    DictionaryRole.object => 'Benda atau hal yang dikenai kegiatan.',
    DictionaryRole.adverb => 'Menjelaskan waktu, tempat, cara, atau alasan.',
    DictionaryRole.complement =>
      'Bagian tambahan agar makna kalimat menjadi utuh.',
  };

  static DictionaryRole fromId(String id) => DictionaryRole.values.firstWhere(
    (role) => role.id == id,
    orElse: () => DictionaryRole.subject,
  );
}

class DictionaryWord {
  final String id;
  final String word;
  final DictionaryRole role;
  final String meaning;
  final String usage;
  final String example;
  final String everydayExample;
  final String formalExample;
  final String contextLabel;
  final String? missionId;
  final String? missionTitle;
  final String clozeSentence;
  final List<String> clozeOptions;

  const DictionaryWord({
    required this.id,
    required this.word,
    required this.role,
    required this.meaning,
    required this.usage,
    required this.example,
    required this.everydayExample,
    required this.formalExample,
    required this.contextLabel,
    required this.clozeSentence,
    required this.clozeOptions,
    this.missionId,
    this.missionTitle,
  });
}

enum DictionaryMastery { newWord, practicing, mastered }

extension DictionaryMasteryInfo on DictionaryMastery {
  String get label => switch (this) {
    DictionaryMastery.newWord => 'Baru',
    DictionaryMastery.practicing => 'Sedang Dilatih',
    DictionaryMastery.mastered => 'Dikuasai',
  };
}

class DictionaryWordProgress {
  final int attempts;
  final int correctAnswers;
  final int lastScore;
  final DateTime? lastPracticedAt;

  const DictionaryWordProgress({
    this.attempts = 0,
    this.correctAnswers = 0,
    this.lastScore = 0,
    this.lastPracticedAt,
  });

  DictionaryMastery get mastery {
    if (attempts == 0) return DictionaryMastery.newWord;
    if (lastScore >= 100 || (attempts >= 2 && accuracy >= 0.75)) {
      return DictionaryMastery.mastered;
    }
    return DictionaryMastery.practicing;
  }

  double get accuracy => attempts == 0 ? 0 : correctAnswers / (attempts * 2);

  Map<String, dynamic> toJson() => {
    'attempts': attempts,
    'correctAnswers': correctAnswers,
    'lastScore': lastScore,
    'lastPracticedAt': lastPracticedAt?.toIso8601String(),
  };

  factory DictionaryWordProgress.fromJson(Map<String, dynamic> json) {
    return DictionaryWordProgress(
      attempts: json['attempts'] as int? ?? 0,
      correctAnswers: json['correctAnswers'] as int? ?? 0,
      lastScore: json['lastScore'] as int? ?? 0,
      lastPracticedAt: DateTime.tryParse(
        json['lastPracticedAt']?.toString() ?? '',
      ),
    );
  }
}

class DictionaryLearningState {
  final Set<String> favoriteIds;
  final List<String> recentIds;
  final Map<String, DictionaryWordProgress> progress;

  const DictionaryLearningState({
    this.favoriteIds = const {},
    this.recentIds = const [],
    this.progress = const {},
  });

  DictionaryWordProgress progressFor(String wordId) =>
      progress[wordId] ?? const DictionaryWordProgress();
}
