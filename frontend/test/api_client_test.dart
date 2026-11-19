import 'dart:convert';

import 'package:finflow_app/services/api_client.dart';
import 'package:finflow_app/services/token_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Penyimpanan token palsu di memori, supaya tes tidak menyentuh Keystore.
class FakeTokenStorage extends TokenStorage {
  String? value;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String token) async => value = token;
  @override
  Future<void> clear() async => value = null;
}

http.Response _json(Object body, int status) => http.Response(
      jsonEncode(body),
      status,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

void main() {
  test('request membawa header Bearer setelah token disimpan', () async {
    String? auth;
    final api = ApiClient(
      client: MockClient((req) async {
        auth = req.headers['Authorization'];
        return _json({'data': {}}, 200);
      }),
      tokenStorage: FakeTokenStorage(),
    );
    await api.saveToken('abc');
    await api.get('/me');
    expect(auth, 'Bearer abc');
  });

  test('token tersimpan bisa dipulihkan lewat loadToken', () async {
    final storage = FakeTokenStorage()..value = 'xyz';
    final api = ApiClient(
      client: MockClient((_) async => _json({}, 200)),
      tokenStorage: storage,
    );
    expect(api.hasToken, false);
    await api.loadToken();
    expect(api.hasToken, true);
  });

  test('error validasi 422 menampilkan pesan pertama', () async {
    final api = ApiClient(
      client: MockClient((_) async => _json({
            'message': 'The given data was invalid.',
            'errors': {
              'username': ['Username sudah dipakai.'],
            },
          }, 422)),
      tokenStorage: FakeTokenStorage(),
    );
    expect(
      () => api.post('/register', body: {'username': 'a'}),
      throwsA(isA<ApiException>()
          .having((e) => e.message, 'message', 'Username sudah dipakai.')
          .having((e) => e.statusCode, 'statusCode', 422)),
    );
  });

  test('401 dengan token memanggil onUnauthorized', () async {
    var called = 0;
    final api = ApiClient(
      client: MockClient(
          (_) async => _json({'message': 'Unauthenticated.'}, 401)),
      tokenStorage: FakeTokenStorage(),
    )..onUnauthorized = () => called++;
    await api.saveToken('abc');
    await expectLater(api.get('/me'), throwsA(isA<ApiException>()));
    expect(called, 1);
  });

  test('401 tanpa token (salah password) tidak memicu logout otomatis',
      () async {
    var called = 0;
    final api = ApiClient(
      client: MockClient(
          (_) async => _json({'message': 'Username atau password salah.'}, 401)),
      tokenStorage: FakeTokenStorage(),
    )..onUnauthorized = () => called++;
    await expectLater(api.post('/login', body: {}), throwsA(isA<ApiException>()));
    expect(called, 0);
  });

  test('error 500 tanpa pesan memakai teks bawaan', () async {
    final api = ApiClient(
      client: MockClient((_) async => http.Response('', 500)),
      tokenStorage: FakeTokenStorage(),
    );
    expect(
      () => api.get('/ringkasan'),
      throwsA(isA<ApiException>()
          .having((e) => e.message, 'message', 'Terjadi kesalahan pada server.')),
    );
  });

  test('gagal terhubung diterjemahkan menjadi pesan yang ramah', () async {
    final api = ApiClient(
      client: MockClient((_) async => throw Exception('offline')),
      tokenStorage: FakeTokenStorage(),
    );
    expect(
      () => api.get('/me'),
      throwsA(isA<ApiException>().having(
          (e) => e.message, 'message', contains('Tidak dapat terhubung'))),
    );
  });
}