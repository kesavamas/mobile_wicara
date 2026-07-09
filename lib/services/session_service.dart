import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String _keyToken = 'access_token';
  static const String _keyStudentId = 'student_id';
  static const String _keyAvatarEmoji = 'avatar_emoji';
  static const String _keyAvatarColor = 'avatar_color';

  static Future<void> saveSession({
    required String token,
    required String studentId,
    required String avatarEmoji,
    required String avatarColor,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    await prefs.setString(_keyStudentId, studentId);
    await prefs.setString(_keyAvatarEmoji, avatarEmoji);
    await prefs.setString(_keyAvatarColor, avatarColor);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  static Future<String?> getStudentId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyStudentId);
  }

  static Future<Map<String, String>?> getAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    final emoji = prefs.getString(_keyAvatarEmoji);
    final color = prefs.getString(_keyAvatarColor);
    if (emoji != null && color != null) {
      return {'emoji': emoji, 'color': color};
    }
    return null;
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyStudentId);
    await prefs.remove(_keyAvatarEmoji);
    await prefs.remove(_keyAvatarColor);
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
}
