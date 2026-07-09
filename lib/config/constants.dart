class AppConstants {
  // Default ini cocok untuk Flutter Web/Chrome saat backend berjalan lokal.
  // Android emulator: flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
  // Physical device: flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );
}
