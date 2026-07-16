import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:wicara_application_1/models/bilik.dart';

class LocalContentRepository {
  const LocalContentRepository();

  Future<List<Bilik>> getBiliks() async {
    final source = await rootBundle.loadString('assets/data/bilik.json');
    final decoded = jsonDecode(source) as List<dynamic>;
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(Bilik.fromJson)
        .toList(growable: false);
  }

  Future<List<BilikLevel>> getLevels(String bilikId) async {
    final source = await rootBundle.loadString('assets/data/bilik-levels.json');
    final decoded = jsonDecode(source) as Map<String, dynamic>;
    final levels = decoded[bilikId] as List<dynamic>? ?? const [];
    return levels
        .whereType<Map<String, dynamic>>()
        .map(BilikLevel.fromJson)
        .toList(growable: false);
  }
}
