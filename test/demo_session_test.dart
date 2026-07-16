import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wicara_application_1/models/bilik.dart';
import 'package:wicara_application_1/services/api_service.dart';
import 'package:wicara_application_1/services/session_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('demo session logs in without an access token', () async {
    await SessionService.saveDemoSession();

    expect(await SessionService.getToken(), isNull);
    expect(await SessionService.isDemoMode(), isTrue);
    expect(await SessionService.isLoggedIn(), isTrue);
    expect(await SessionService.getStudentId(), 'WCR-DEMO');
  });

  test('normal login session disables demo mode', () async {
    await SessionService.saveDemoSession();
    await SessionService.saveSession(
      token: 'real-token',
      studentId: 'WCR-01',
      avatarEmoji: 'face',
      avatarColor: '#4C5FD7',
    );

    expect(await SessionService.isDemoMode(), isFalse);
    expect(await SessionService.getToken(), 'real-token');
  });

  test('demo progress is isolated from student progress', () async {
    await SessionService.saveSession(
      token: 'real-token',
      studentId: 'WCR-01',
      avatarEmoji: 'face',
      avatarColor: '#4C5FD7',
    );
    await ApiService.saveCachedProgress([
      StudentProgress(bilikId: 'akademik', levelId: 1, status: 'completed'),
    ]);

    await SessionService.saveDemoSession();
    expect(await ApiService.getCachedProgress(), isEmpty);
    await ApiService.saveCachedProgress([
      StudentProgress(bilikId: 'profesional', levelId: 1, status: 'completed'),
    ]);

    await SessionService.saveSession(
      token: 'real-token',
      studentId: 'WCR-01',
      avatarEmoji: 'face',
      avatarColor: '#4C5FD7',
    );
    final studentProgress = await ApiService.getCachedProgress();
    expect(studentProgress, hasLength(1));
    expect(studentProgress.single.bilikId, 'akademik');
  });
}
