/// Satu-satunya tempat alamat API backend diatur.
///
/// Ganti saat build/run dengan:
///   flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000/api
///
/// Default `10.0.2.2` = alamat komputer host dari Android Emulator.
/// Web/desktop di komputer yang sama: http://127.0.0.1:8000/api
class ApiConfig {
  const ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api',
  );

  static const Duration timeout = Duration(seconds: 15);
}
