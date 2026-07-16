class ColorTheme {
  final String soft;
  final String border;
  final String ink;

  ColorTheme({required this.soft, required this.border, required this.ink});

  factory ColorTheme.fromJson(Map<String, dynamic> json) {
    return ColorTheme(
      soft: json['soft'] ?? '#F8FAFC',
      border: json['border'] ?? '#E2E8F0',
      ink: json['ink'] ?? '#475569',
    );
  }
}

class Bilik {
  final String id;
  final String title;
  final String icon;
  final String color;
  final ColorTheme colorTheme;
  final String description;

  Bilik({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    required this.colorTheme,
    required this.description,
  });

  factory Bilik.fromJson(Map<String, dynamic> json) {
    return Bilik(
      id: json['id'],
      title: json['title'],
      icon: json['icon'],
      color: json['color'] ?? '#3B82F6',
      colorTheme: ColorTheme.fromJson(json['colorTheme'] ?? {}),
      description: json['description'] ?? '',
    );
  }
}

class Comic {
  final String narration;
  final String? speechBubble;
  final String imagePath;

  Comic({required this.narration, this.speechBubble, required this.imagePath});

  factory Comic.fromJson(Map<String, dynamic> json) {
    return Comic(
      narration: json['narration'] ?? '',
      speechBubble: json['speechBubble'],
      imagePath: json['imagePath'] ?? '',
    );
  }
}

class SpokAnswer {
  final String s;
  final String p;
  final String o;
  final String k;

  SpokAnswer({
    required this.s,
    required this.p,
    required this.o,
    required this.k,
  });

  factory SpokAnswer.fromJson(Map<String, dynamic> json) {
    return SpokAnswer(
      s: json['S'] ?? '',
      p: json['P'] ?? '',
      o: json['O'] ?? '',
      k: json['K'] ?? '',
    );
  }
}

class BilikLevel {
  final int id;
  final String title;
  final String shortTitle;
  final String prompt;
  final String target;
  final Comic comic;
  final List<String> tokens;
  final Map<String, String> tokenRoles;
  final SpokAnswer spokAnswer;
  final String explanation;

  BilikLevel({
    required this.id,
    required this.title,
    required this.shortTitle,
    required this.prompt,
    required this.target,
    required this.comic,
    required this.tokens,
    required this.tokenRoles,
    required this.spokAnswer,
    required this.explanation,
  });

  factory BilikLevel.fromJson(Map<String, dynamic> json) {
    return BilikLevel(
      id: json['id'],
      title: json['title'] ?? '',
      shortTitle: json['shortTitle'] ?? json['title'] ?? '',
      prompt: json['prompt'] ?? json['comic']?['narration'] ?? '',
      target: json['target'] ?? '',
      comic: Comic.fromJson(json['comic'] ?? {}),
      tokens: List<String>.from(json['tokens'] ?? []),
      tokenRoles: Map<String, String>.from(json['tokenRoles'] ?? const {}),
      spokAnswer: SpokAnswer.fromJson(json['spok_answer'] ?? {}),
      explanation: json['explanation'] ?? '',
    );
  }
}

class StudentProgress {
  final String bilikId;
  final int levelId;
  final String status; // 'unlocked' | 'completed'

  StudentProgress({
    required this.bilikId,
    required this.levelId,
    required this.status,
  });

  factory StudentProgress.fromJson(Map<String, dynamic> json) {
    final rawLevelId = json['level_id'] ?? json['levelId'] ?? 0;
    return StudentProgress(
      bilikId: (json['bilik_id'] ?? json['bilikId'] ?? '').toString(),
      levelId: rawLevelId is int
          ? rawLevelId
          : int.tryParse(rawLevelId.toString()) ?? 0,
      status: (json['status'] ?? 'unlocked').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'bilik_id': bilikId, 'level_id': levelId, 'status': status};
  }
}
