import '../models/user_model.dart';
import 'api_client.dart';

class AuthService {
  AuthService(this._api);
  final ApiClient _api;

  Future<UserModel> login(String username, String password) async {
    final response = await _api.post('/login', body: {
      'username': username,
      'password': password,
    }) as Map<String, dynamic>;

    // Backend membungkus hasil login di dalam `data`.
    final data = response['data'] as Map<String, dynamic>;
    await _api.saveToken(data['token'] as String);
    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<void> register({
    required String username,
    required String password,
    required String passwordConfirmation,
  }) async {
    await _api.post('/register', body: {
      'username': username,
      'password': password,
      'password_confirmation': passwordConfirmation,
    });
  }

  /// Mengambil data user dari token yang tersimpan (dipakai untuk
  /// memulihkan sesi). Melempar ApiException(401) jika token tidak berlaku.
  Future<UserModel> me() async {
    final res = await _api.get('/me') as Map<String, dynamic>;
    final data = res['data'] as Map<String, dynamic>;
    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<UserModel> updateProfile({
    required String username,
    String? password,
  }) async {
    final res = await _api.put('/profil', body: {
      'username': username,
      'password': ?password,
      'password_confirmation': ?password,
    }) as Map<String, dynamic>;
    final data = res['data'] as Map<String, dynamic>;
    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<void> logout() async {
    try {
      await _api.post('/logout');
    } on ApiException {
      // Token mungkin sudah tidak berlaku; sesi lokal tetap dibersihkan.
    } finally {
      await _api.clearToken();
    }
  }
}