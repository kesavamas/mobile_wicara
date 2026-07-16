class Revision3Content {
  final List<LearningBilik> biliks;
  final List<LearningMission> missions;

  const Revision3Content({required this.biliks, required this.missions});

  factory Revision3Content.fromJson(Map<String, dynamic> json) {
    return Revision3Content(
      biliks: (json['biliks'] as List<dynamic>? ?? const [])
          .map((item) => LearningBilik.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
      missions: (json['missions'] as List<dynamic>? ?? const [])
          .map((item) => LearningMission.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}

class LearningBilik {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String theme;
  final int order;

  const LearningBilik({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.theme,
    required this.order,
  });

  bool get isSchool => theme == 'school';
  String get progressId => isSchool ? 'akademik' : 'profesional';
  String get iconAsset => isSchool
      ? 'assets/revision3/icons/bilik-akademik.svg'
      : 'assets/revision3/icons/bilik-profesional.svg';
  String get patternAsset => isSchool
      ? 'assets/revision3/patterns/akademik.svg'
      : 'assets/revision3/patterns/profesional.svg';

  factory LearningBilik.fromJson(Map<String, dynamic> json) {
    return LearningBilik(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      description: json['description'] as String? ?? '',
      theme: json['theme'] as String? ?? 'school',
      order: json['order'] as int? ?? 0,
    );
  }
}

class LearningMission {
  final String id;
  final String bilikId;
  final int order;
  final String? prerequisiteMissionId;
  final String title;
  final String description;
  final int rewardXp;
  final String studentName;
  final String otherName;
  final String scene;
  final String otherPersona;
  final List<String> objectives;
  final GuidedContent guided;
  final IndependentContent independent;

  const LearningMission({
    required this.id,
    required this.bilikId,
    required this.order,
    required this.prerequisiteMissionId,
    required this.title,
    required this.description,
    required this.rewardXp,
    required this.studentName,
    required this.otherName,
    required this.scene,
    required this.otherPersona,
    required this.objectives,
    required this.guided,
    required this.independent,
  });

  bool get isSchool => bilikId == 'sekolah';
  String get progressBilikId => isSchool ? 'akademik' : 'profesional';
  String get shortTitle {
    const labels = {
      'sekolah-1': 'Izin Sakit',
      'sekolah-2': 'Jadwal Remedial',
      'sekolah-3': 'Pinjam Proyektor',
      'profesional-1': 'Email Magang',
      'profesional-2': 'Balas HRD',
      'profesional-3': 'Izin Terlambat',
    };
    return labels[id] ?? title;
  }

  String get comicAsset {
    final folder = isSchool ? 'dosen' : 'kerja';
    return 'assets/comics/$folder/step-$order.png';
  }

  factory LearningMission.fromJson(Map<String, dynamic> json) {
    return LearningMission(
      id: json['id'] as String? ?? '',
      bilikId: json['bilikId'] as String? ?? '',
      order: json['order'] as int? ?? 0,
      prerequisiteMissionId: json['prerequisiteMissionId'] as String?,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      rewardXp: json['rewardXP'] as int? ?? 0,
      studentName: json['studentName'] as String? ?? 'Siswa',
      otherName: json['otherName'] as String? ?? '',
      scene: json['scene'] as String? ?? '',
      otherPersona: json['otherPersona'] as String? ?? '',
      objectives: List<String>.from(
        json['objectives'] as List<dynamic>? ?? const [],
      ),
      guided: GuidedContent.fromJson(
        json['guided'] as Map<String, dynamic>? ?? const {},
      ),
      independent: IndependentContent.fromJson(
        json['independent'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }
}

class GuidedContent {
  final List<ContextFrame> frames;
  final List<DialogLine> opening;
  final List<GuidedRound> rounds;
  final List<List<DialogLine>> responses;
  final List<DialogLine> ending;
  final List<String> roundLabels;
  final String fullMessage;

  const GuidedContent({
    required this.frames,
    required this.opening,
    required this.rounds,
    required this.responses,
    required this.ending,
    required this.roundLabels,
    required this.fullMessage,
  });

  factory GuidedContent.fromJson(Map<String, dynamic> json) {
    List<DialogLine> dialogs(Object? value) {
      return (value as List<dynamic>? ?? const [])
          .map((item) => DialogLine.fromJson(item as Map<String, dynamic>))
          .toList(growable: false);
    }

    return GuidedContent(
      frames: (json['frames'] as List<dynamic>? ?? const [])
          .map((item) => ContextFrame.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
      opening: dialogs(json['opening']),
      rounds: (json['rounds'] as List<dynamic>? ?? const [])
          .map((item) => GuidedRound.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
      responses: (json['responses'] as List<dynamic>? ?? const [])
          .map(dialogs)
          .toList(growable: false),
      ending: dialogs(json['ending']),
      roundLabels: List<String>.from(
        json['roundLabels'] as List<dynamic>? ?? const [],
      ),
      fullMessage: json['fullMessage'] as String? ?? '',
    );
  }
}

class ContextFrame {
  final String caption;
  final String expression;

  const ContextFrame({required this.caption, required this.expression});

  factory ContextFrame.fromJson(Map<String, dynamic> json) {
    return ContextFrame(
      caption: json['caption'] as String? ?? '',
      expression: json['expr'] as String? ?? 'neutral',
    );
  }
}

class DialogLine {
  final String who;
  final String text;

  const DialogLine({required this.who, required this.text});

  factory DialogLine.fromJson(Map<String, dynamic> json) {
    return DialogLine(
      who: json['who'] as String? ?? 'student',
      text: json['text'] as String? ?? '',
    );
  }
}

class GuidedRound {
  final String title;
  final String objective;
  final List<LearningWordCard> cards;
  final List<String> target;
  final String targetSentence;
  final String hintText;
  final String wrongHintText;
  final List<String> slotLabels;

  const GuidedRound({
    required this.title,
    required this.objective,
    required this.cards,
    required this.target,
    required this.targetSentence,
    required this.hintText,
    required this.wrongHintText,
    required this.slotLabels,
  });

  factory GuidedRound.fromJson(Map<String, dynamic> json) {
    return GuidedRound(
      title: json['title'] as String? ?? '',
      objective: json['objective'] as String? ?? '',
      cards: (json['cards'] as List<dynamic>? ?? const [])
          .map(
            (item) => LearningWordCard.fromJson(item as Map<String, dynamic>),
          )
          .toList(growable: false),
      target: List<String>.from(json['target'] as List<dynamic>? ?? const []),
      targetSentence: json['targetSentence'] as String? ?? '',
      hintText: json['hintText'] as String? ?? '',
      wrongHintText: json['wrongHintText'] as String? ?? '',
      slotLabels: List<String>.from(
        json['slotLabels'] as List<dynamic>? ?? const [],
      ),
    );
  }
}

class LearningWordCard {
  final String text;
  final String kind;
  final bool distractor;

  const LearningWordCard({
    required this.text,
    required this.kind,
    required this.distractor,
  });

  factory LearningWordCard.fromJson(Map<String, dynamic> json) {
    return LearningWordCard(
      text: json['text'] as String? ?? '',
      kind: json['kind'] as String? ?? 'plain',
      distractor: json['distractor'] as bool? ?? false,
    );
  }
}

class IndependentContent {
  final String kind;
  final String contactName;
  final String instruction;
  final String placeholder;
  final String? emailSubject;

  const IndependentContent({
    required this.kind,
    required this.contactName,
    required this.instruction,
    required this.placeholder,
    required this.emailSubject,
  });

  factory IndependentContent.fromJson(Map<String, dynamic> json) {
    return IndependentContent(
      kind: json['kind'] as String? ?? 'chat',
      contactName: json['contactName'] as String? ?? '',
      instruction: json['instruction'] as String? ?? '',
      placeholder: json['placeholder'] as String? ?? '',
      emailSubject: json['emailSubject'] as String?,
    );
  }
}
