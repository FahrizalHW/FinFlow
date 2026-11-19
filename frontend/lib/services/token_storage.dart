import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Menyimpan token login di penyimpanan terenkripsi perangkat
/// (Android Keystore / iOS Keychain) agar sesi bertahan setelah app ditutup.
class TokenStorage {
  static const _key = 'auth_token';
  final FlutterSecureStorage _secure = const FlutterSecureStorage();

  Future<String?> read() async {
    try {
      final token = await _secure.read(key: _key);
      if (token != null && token.isNotEmpty) return token;
    } catch (_) {
      // Data terenkripsi tidak bisa dibaca (mis. setelah restore backup):
      // anggap tidak ada token, user cukup login ulang.
      try {
        await _secure.deleteAll();
      } catch (_) {}
    }
    return _migrateLegacy();
  }

  Future<void> write(String token) async {
    await _writeSecure(token);
    await _removeLegacy();
  }

  Future<void> clear() async {
    try {
      await _secure.delete(key: _key);
    } catch (_) {}
    await _removeLegacy();
  }

  /// Menulis ke penyimpanan terenkripsi. true jika berhasil.
  Future<bool> _writeSecure(String token) async {
    try {
      await _secure.write(key: _key, value: token);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Token versi lama tersimpan di SharedPreferences (tidak terenkripsi).
  /// Jika ada, pindahkan ke penyimpanan terenkripsi lalu hapus yang lama.
  Future<String?> _migrateLegacy() async {
    final prefs = await SharedPreferences.getInstance();
    final legacy = prefs.getString(_key);
    if (legacy == null || legacy.isEmpty) return null;
    if (await _writeSecure(legacy)) {
      await prefs.remove(_key);
    }
    return legacy;
  }

  Future<void> _removeLegacy() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}