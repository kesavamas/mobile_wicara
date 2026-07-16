import 'package:flutter_test/flutter_test.dart';
import 'package:wicara_application_1/core/utils/formal_text_analyzer.dart';
import 'package:wicara_application_1/data/repositories/revision3_content_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('formal target reaches the green formality band', () async {
    final content = await Revision3ContentRepository.load();
    final mission = content.missions.first;
    final analysis = analyzeFormalText(mission.guided.fullMessage, mission);

    expect(analysis.score, greaterThanOrEqualTo(81));
    expect(analysis.isFullyFormal, isTrue);
    expect(analysis.chunks, isNotEmpty);
  });

  test('short informal message receives a self-correction hint', () async {
    final content = await Revision3ContentRepository.load();
    final mission = content.missions.first;
    final analysis = analyzeFormalText('aku gak masuk', mission);

    expect(analysis.score, lessThanOrEqualTo(50));
    expect(analysis.isFullyFormal, isFalse);
    expect(analysis.hint, contains('formal'));
  });
}
