import '../models/user_model.dart';
import 'api_client.dart';

class AuthService {
  AuthService(this._api);
  final ApiClient _api;

  Future<UserModel> login(String username, String password) async {
    final data = await _api.post('/login', body: {
      'username': username,
      'password': password,
    }) as Map<String, dynamic>;

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