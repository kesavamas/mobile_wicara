import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wicara_application_1/models/revision3_content.dart';

void main() {
  late Revision3Content content;

  setUpAll(() async {
    final raw = await File('assets/data/revision3-content.json').readAsString();
    content = Revision3Content.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  });

  test('ports both revision3 biliks and all six missions', () {
    expect(content.biliks.map((bilik) => bilik.id), ['sekolah', 'profesional']);
    expect(content.missions, hasLength(6));
  });

  test('keeps progressive 3, 4, and 5 round structure', () {
    for (final bilikId in ['sekolah', 'profesional']) {
      final missions =
          content.missions
              .where((mission) => mission.bilikId == bilikId)
              .toList()
            ..sort((a, b) => a.order.compareTo(b.order));
      expect(missions.map((mission) => mission.guided.rounds.length), [
        3,
        4,
        5,
      ]);
    }
  });

  test('every guided round has an exact target and visible cards', () {
    for (final mission in content.missions) {
      for (final round in mission.guided.rounds) {
        expect(round.target, isNotEmpty);
        expect(round.targetSentence, isNotEmpty);
        for (final target in round.target) {
          expect(
            round.cards.any((card) => card.text == target),
            isTrue,
            reason: '${mission.id}: target card "$target" is missing',
          );
        }
      }
    }
  });
}
