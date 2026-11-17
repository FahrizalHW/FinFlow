import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// SEMENTARA: server palsu untuk mengecek tampilan. JANGAN di-commit.
final mockClient = MockClient((request) async {
  Map<String, dynamic> body;
  switch (request.url.path) {
    case '/api/login':
      body = {
        'token': 'abc',
        'user': {'id_user': 1, 'username': 'Reyan', 'foto_profil': null},
      };
    case '/api/ringkasan':
      body = {
        'saldo': 1500000,
        'pemasukan_bulan_ini': 2000000,
        'pengeluaran_bulan_ini': 500000,
        'transaksi_terbaru': [
          {
            'id_transaksi': 1, 'id_user': 1, 'id_kategori': 1,
            'nama_kategori': 'Gaji', 'jenis_transaksi': 'pemasukan',
            'nama_transaksi': 'Gaji Bulanan', 'nominal': 2000000,
            'tanggal_transaksi': '2026-11-01', 'catatan': null,
          },
          {
            'id_transaksi': 2, 'id_user': 1, 'id_kategori': 2,
            'nama_kategori': 'Makanan', 'jenis_transaksi': 'pengeluaran',
            'nama_transaksi': 'Makan Siang', 'nominal': 50000,
            'tanggal_transaksi': '2026-11-02', 'catatan': null,
          },
        ],
      };
    default:
      body = {};
  }
  return http.Response(
    jsonEncode(body),
    200,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );
});