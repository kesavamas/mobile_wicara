import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wicara_application_1/config/constants.dart';
import 'package:wicara_application_1/services/session_service.dart';
import 'package:wicara_application_1/models/bilik.dart';

class ApiService {
  static String? lastError;
  static bool _isSyncing = false;

  static Future<Map<String, String>> _getHeaders() async {
    final token = await SessionService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static dynamic _decodeBody(http.Response response) {
    if (response.body.isEmpty) return null;
    return jsonDecode(response.body);
  }

  static String _messageFromResponse(http.Response response) {
    try {
      final body = _decodeBody(response);
      if (body is Map<String, dynamic>) {
        return (body['detail'] ??
                body['error'] ??
                'Terjadi kendala pada server.')
            .toString();
      }
    } catch (_) {}
    return 'Terjadi kendala pada server.';
  }

  // --- OFFLINE HELPER METHODS ---

  static Future<List<StudentProgress>> getCachedProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString('cached_progress');
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List decoded = jsonDecode(jsonStr);
        return decoded.map((x) => StudentProgress.fromJson(x)).toList();
      }
    } catch (_) {}
    return [];
  }

  static Future<void> saveCachedProgress(List<StudentProgress> progress) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = jsonEncode(progress.map((x) => x.toJson()).toList());
      await prefs.setString('cached_progress', jsonStr);
    } catch (_) {}
  }

  static Future<void> _queuePendingProgress(String bilikId, int levelId, String status) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueStr = prefs.getString('pending_progress') ?? '[]';
      final List queue = jsonDecode(queueStr);
      
      // Remove any existing entry for the same level to avoid duplicates
      queue.removeWhere((x) => x['bilikId'] == bilikId && x['levelId'] == levelId);
      
      queue.add({
        'bilikId': bilikId,
        'levelId': levelId,
        'status': status,
      });
      await prefs.setString('pending_progress', jsonEncode(queue));
    } catch (_) {}
  }

  static Future<void> _queuePendingLog(bool isCorrect, List<int> mismatchedPositions) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueStr = prefs.getString('pending_logs') ?? '[]';
      final List queue = jsonDecode(queueStr);
      queue.add({
        'is_correct': isCorrect,
        'mismatched_positions': mismatchedPositions,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      await prefs.setString('pending_logs', jsonEncode(queue));
    } catch (_) {}
  }

  static Future<void> syncOfflineData() async {
    if (_isSyncing) return;
    final token = await SessionService.getToken();
    if (token == null) return; // Not logged in, skip

    _isSyncing = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 1. Sync pending progress
      final progressQueueStr = prefs.getString('pending_progress') ?? '[]';
      final List progressQueue = jsonDecode(progressQueueStr);
      if (progressQueue.isNotEmpty) {
        final List remaining = [];
        final headers = await _getHeaders();
        for (var item in progressQueue) {
          try {
            final response = await http.post(
              Uri.parse('${AppConstants.baseUrl}/api/progress'),
              headers: headers,
              body: jsonEncode(item),
            ).timeout(const Duration(seconds: 4));

            if (response.statusCode != 200) {
              remaining.add(item);
            }
          } catch (_) {
            remaining.add(item);
          }
        }
        await prefs.setString('pending_progress', jsonEncode(remaining));
      }

      // 2. Sync pending logs
      final logsQueueStr = prefs.getString('pending_logs') ?? '[]';
      final List logsQueue = jsonDecode(logsQueueStr);
      if (logsQueue.isNotEmpty) {
        final List remaining = [];
        final headers = await _getHeaders();
        for (var item in logsQueue) {
          try {
            final response = await http.post(
              Uri.parse('${AppConstants.baseUrl}/api/log'),
              headers: headers,
              body: jsonEncode({
                'is_correct': item['is_correct'],
                'mismatched_positions': List<int>.from(item['mismatched_positions']),
              }),
            ).timeout(const Duration(seconds: 4));

            if (response.statusCode != 200) {
              remaining.add(item);
            }
          } catch (_) {
            remaining.add(item);
          }
        }
        await prefs.setString('pending_logs', jsonEncode(remaining));
      }
    } catch (_) {
      // Sync failed
    } finally {
      _isSyncing = false;
    }
  }

  // --- API CALL METHODS ---

  static Future<bool> login(String token, String password) async {
    lastError = null;
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/api/auth/student-login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token, 'password': password}),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = _decodeBody(response) as Map<String, dynamic>;
        final accessToken = data['access_token']?.toString();
        final avatar = data['avatar'] is Map<String, dynamic>
            ? data['avatar'] as Map<String, dynamic>
            : <String, dynamic>{};

        if (accessToken == null || accessToken.isEmpty) {
          lastError = 'Respons login tidak lengkap dari server.';
          return false;
        }

        await SessionService.saveSession(
          token: accessToken,
          studentId: token.trim().toUpperCase(),
          avatarEmoji:
              avatar['emoji']?.toString() ??
              avatar['label']?.toString() ??
              token.trim().toUpperCase().replaceFirst('WCR-', 'S'),
          avatarColor: avatar['color']?.toString() ?? '#3B82F6',
        );
        
        // Trigger sync of any cached progress/logs immediately after login succeeds
        syncOfflineData();
        
        return true;
      }

      lastError = _messageFromResponse(response);
      return false;
    } catch (e) {
      lastError = 'Tidak bisa terhubung ke server. Pastikan backend aktif.';
      return false;
    }
  }

  static Future<String?> register(String nickname, String password, String emoji, String color) async {
    lastError = null;
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/api/auth/student-register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nickname': nickname,
          'password': password,
          'avatar': {'emoji': emoji, 'color': color}
        }),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = _decodeBody(response) as Map<String, dynamic>;
        final accessToken = data['access_token']?.toString();
        final token = data['token']?.toString();
        final avatar = data['avatar'] is Map<String, dynamic>
            ? data['avatar'] as Map<String, dynamic>
            : <String, dynamic>{};

        if (accessToken == null || token == null) {
          lastError = 'Respons registrasi tidak lengkap dari server.';
          return null;
        }

        await SessionService.saveSession(
          token: accessToken,
          studentId: token,
          avatarEmoji: avatar['emoji']?.toString() ?? avatar['label']?.toString() ?? emoji,
          avatarColor: avatar['color']?.toString() ?? color,
        );
        return token;
      }

      lastError = _messageFromResponse(response);
      return null;
    } catch (e) {
      lastError = 'Tidak bisa terhubung ke server. Pastikan backend aktif.';
      return null;
    }
  }

  static Future<List<StudentProgress>> fetchProgress() async {
    // Try to sync offline data in background first
    syncOfflineData();

    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/api/progress'),
        headers: headers,
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = _decodeBody(response) as Map<String, dynamic>;
        final List progressList = data['progress'] ?? [];
        final list = progressList
            .whereType<Map<String, dynamic>>()
            .map(StudentProgress.fromJson)
            .toList();
        
        await saveCachedProgress(list);
        return list;
      }
    } catch (_) {
      // Failed to reach backend, load from cache
    }
    return await getCachedProgress();
  }

  static Future<bool> updateProgress(
    String bilikId,
    int levelId,
    String status,
  ) async {
    // 1. Instantly update local progress cache
    final currentCache = await getCachedProgress();
    final index = currentCache.indexWhere(
      (p) => p.bilikId == bilikId && p.levelId == levelId
    );
    final newProgress = StudentProgress(
      bilikId: bilikId,
      levelId: levelId,
      status: status,
    );
    if (index != -1) {
      currentCache[index] = newProgress;
    } else {
      currentCache.add(newProgress);
    }
    await saveCachedProgress(currentCache);

    // 2. Try to update backend
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/api/progress'),
        headers: headers,
        body: jsonEncode({
          'bilikId': bilikId,
          'levelId': levelId,
          'status': status,
        }),
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        return true;
      }
    } catch (_) {
      // API call failed, queue for background sync
    }

    await _queuePendingProgress(bilikId, levelId, status);
    return true; // Return true to allow UI to advance smoothly offline
  }

  static Future<bool> updateProfile(String nickname, String password, String emoji, String color) async {
    lastError = null;
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('${AppConstants.baseUrl}/api/profile'),
        headers: headers,
        body: jsonEncode({
          'nickname': nickname,
          'password': password,
          'avatar': {'emoji': emoji, 'color': color}
        }),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final token = await SessionService.getToken();
        final studentId = await SessionService.getStudentId();
        if (token != null && studentId != null) {
          await SessionService.saveSession(
            token: token,
            studentId: studentId,
            avatarEmoji: emoji,
            avatarColor: color,
          );
        }
        return true;
      }

      lastError = _messageFromResponse(response);
      return false;
    } catch (e) {
      lastError = 'Tidak bisa terhubung ke server. Pastikan backend aktif.';
      return false;
    }
  }

  static Future<bool> logAttempt(
    bool isCorrect,
    List<int> mismatchedPositions,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/api/log'),
        headers: headers,
        body: jsonEncode({
          'is_correct': isCorrect,
          'mismatched_positions': mismatchedPositions,
        }),
      ).timeout(const Duration(seconds: 4));
      return response.statusCode == 200;
    } catch (e) {
      // Failed to reach backend, queue for background sync
      await _queuePendingLog(isCorrect, mismatchedPositions);
      return false;
    }
  }

  static Future<Map<String, dynamic>?> getEmergencyAssist(
    String scenario,
    String userInput,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/api/ai/emergency-assist'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'scenario': scenario, 'user_input': userInput}),
      );

      if (response.statusCode == 200) {
        return _decodeBody(response) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getSentenceFeedback(
    String sentence,
    String context,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/api/ai/sentence-feedback'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_sentence': sentence, 'context': context}),
      );

      if (response.statusCode == 200) {
        return _decodeBody(response) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getVocabularyHelper(
    String informalWord,
    String context,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/api/ai/vocabulary-helper'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'informal_word': informalWord, 'context': context}),
      );

      if (response.statusCode == 200) {
        return _decodeBody(response) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
