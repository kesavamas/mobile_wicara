import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:wicara_application_1/features/dictionary/models/dictionary_word.dart';
import 'package:wicara_application_1/services/session_service.dart';

class DictionaryLearningRepository {
  static const int maxRecentWords = 5;

  Future<String> _key(String suffix) async {
    final studentId = await SessionService.getStudentId() ?? 'guest';
    final scope = studentId.toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9]+'),
      '_',
    );
    return 'dictionary_${scope}_$suffix';
  }

  Future<DictionaryLearningState> load() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(await _key('favorites')) ?? const [];
    final recent = prefs.getStringList(await _key('recent')) ?? const [];
    final rawProgress = prefs.getString(await _key('progress'));
    final progress = <String, DictionaryWordProgress>{};

    if (rawProgress != null && rawProgress.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawProgress) as Map<String, dynamic>;
        for (final entry in decoded.entries) {
          if (entry.value is Map<String, dynamic>) {
            progress[entry.key] = DictionaryWordProgress.fromJson(
              entry.value as Map<String, dynamic>,
            );
          }
        }
      } catch (_) {
        // Corrupt local dictionary data should not block the learning screen.
      }
    }

    return DictionaryLearningState(
      favoriteIds: favorites.toSet(),
      recentIds: List.unmodifiable(recent),
      progress: Map.unmodifiable(progress),
    );
  }

  Future<bool> toggleFavorite(String wordId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _key('favorites');
    final favorites = (prefs.getStringList(key) ?? const []).toSet();
    final nowFavorite = !favorites.remove(wordId);
    if (nowFavorite) favorites.add(wordId);
    await prefs.setStringList(key, favorites.toList()..sort());
    return nowFavorite;
  }

  Future<void> markViewed(String wordId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _key('recent');
    final recent = [...(prefs.getStringList(key) ?? const <String>[])];
    recent.remove(wordId);
    recent.insert(0, wordId);
    if (recent.length > maxRecentWords) {
      recent.removeRange(maxRecentWords, recent.length);
    }
    await prefs.setStringList(key, recent);
  }

  Future<DictionaryWordProgress> recordPractice({
    required String wordId,
    required int correctAnswers,
    required int totalQuestions,
  }) async {
    final state = await load();
    final previous = state.progressFor(wordId);
    final safeTotal = totalQuestions <= 0 ? 1 : totalQuestions;
    final safeCorrect = correctAnswers.clamp(0, safeTotal);
    final updated = DictionaryWordProgress(
      attempts: previous.attempts + 1,
      correctAnswers: previous.correctAnswers + safeCorrect,
      lastScore: ((safeCorrect / safeTotal) * 100).round(),
      lastPracticedAt: DateTime.now(),
    );
    final progress = {...state.progress, wordId: updated};
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      await _key('progress'),
      jsonEncode({
        for (final entry in progress.entries) entry.key: entry.value.toJson(),
      }),
    );
    await markViewed(wordId);
    return updated;
  }
}
