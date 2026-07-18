import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wicara_application_1/features/dictionary/data/dictionary_catalog.dart';
import 'package:wicara_application_1/features/dictionary/models/dictionary_word.dart';
import 'package:wicara_application_1/features/dictionary/repositories/dictionary_learning_repository.dart';
import 'package:wicara_application_1/features/dictionary/screens/color_dictionary_screen.dart';
import 'package:wicara_application_1/services/session_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('dictionary catalog has unique ids and valid cloze answers', () {
    final ids = DictionaryCatalog.words.map((word) => word.id).toSet();

    expect(ids, hasLength(DictionaryCatalog.words.length));
    for (final word in DictionaryCatalog.words) {
      expect(word.clozeOptions, contains(word.word));
      expect(word.example, isNotEmpty);
      expect(word.formalExample, isNotEmpty);
    }
  });

  test(
    'favorites and recent words are stored for the active student',
    () async {
      await SessionService.saveSession(
        token: 'token-a',
        studentId: 'WCR-A',
        avatarEmoji: 'face',
        avatarColor: '#4C5FD7',
      );
      final repository = DictionaryLearningRepository();

      expect(await repository.toggleFavorite('s_saya'), isTrue);
      await repository.markViewed('s_saya');
      final state = await repository.load();

      expect(state.favoriteIds, contains('s_saya'));
      expect(state.recentIds.first, 's_saya');
    },
  );

  test('dictionary state is isolated between student accounts', () async {
    await SessionService.saveSession(
      token: 'token-a',
      studentId: 'WCR-A',
      avatarEmoji: 'face',
      avatarColor: '#4C5FD7',
    );
    final repository = DictionaryLearningRepository();
    await repository.toggleFavorite('s_saya');

    await SessionService.saveSession(
      token: 'token-b',
      studentId: 'WCR-B',
      avatarEmoji: 'face',
      avatarColor: '#4C5FD7',
    );
    final secondState = await repository.load();

    expect(secondState.favoriteIds, isEmpty);
  });

  test(
    'practice result moves a word from new to practicing and mastered',
    () async {
      await SessionService.saveDemoSession();
      final repository = DictionaryLearningRepository();

      final first = await repository.recordPractice(
        wordId: 'p_membaca',
        correctAnswers: 1,
        totalQuestions: 2,
      );
      expect(first.mastery, DictionaryMastery.practicing);

      final second = await repository.recordPractice(
        wordId: 'p_membaca',
        correctAnswers: 2,
        totalQuestions: 2,
      );
      expect(second.mastery, DictionaryMastery.mastered);
      expect(second.attempts, 2);
    },
  );

  test('recent list stays ordered and capped', () async {
    await SessionService.saveDemoSession();
    final repository = DictionaryLearningRepository();
    final ids = DictionaryCatalog.words
        .take(DictionaryLearningRepository.maxRecentWords + 2)
        .map((word) => word.id)
        .toList();

    for (final id in ids) {
      await repository.markViewed(id);
    }
    final state = await repository.load();

    expect(
      state.recentIds,
      hasLength(DictionaryLearningRepository.maxRecentWords),
    );
    expect(state.recentIds.first, ids.last);
  });

  testWidgets('word detail opens the interactive practice flow', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 1200);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await SessionService.saveDemoSession();
    await tester.pumpWidget(
      const MaterialApp(home: ColorDictionaryScreen(showBackButton: true)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('SAYA'));
    await tester.pumpAndSettle();
    expect(find.text('Latih Kata Ini'), findsOneWidget);

    await tester.tap(find.text('Latih Kata Ini'));
    await tester.pumpAndSettle();
    expect(find.text('Apa fungsi kata ini?'), findsOneWidget);
    expect(find.text('Periksa Jawaban'), findsOneWidget);
  });
}
