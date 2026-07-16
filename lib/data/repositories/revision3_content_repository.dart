import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:wicara_application_1/models/revision3_content.dart';

class Revision3ContentRepository {
  static Revision3Content? _cache;

  static Future<Revision3Content> load() async {
    final cached = _cache;
    if (cached != null) return cached;

    final raw = await rootBundle.loadString(
      'assets/data/revision3-content.json',
    );
    final content = Revision3Content.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
    _cache = content;
    return content;
  }

  static List<LearningMission> missionsFor(
    Revision3Content content,
    String bilikId,
  ) {
    final result = content.missions
        .where((mission) => mission.bilikId == bilikId)
        .toList();
    result.sort((a, b) => a.order.compareTo(b.order));
    return result;
  }
}
