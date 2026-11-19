import 'dart:convert';

import 'package:finflow_app/services/api_client.dart';
import 'package:finflow_app/services/token_storage.dart';
import 'package:finflow_app/services/transaction_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

class _FakeStorage extends TokenStorage {
  @override
  Future<String?> read() async => null;
  @override
  Future<void> write(String token) async {}
  @override
  Future<void> clear() async {}
}

Map<String, dynamic> _tx(int id, String type, String category, num amount,
        String date) =>
    {
      'id_transaksi': id,
      'id_user': 1,
      'id_kategori': id,
      'nama_kategori': category,
      'jenis_transaksi': type,
      'nama_transaksi': 'Transaksi $id',
      'nominal': amount,
      'tanggal_transaksi': date,
      'catatan': null,
    };

TransactionService _service() {
  final data = [
    _tx(3, 'pengeluaran', 'Transport', 20000, '2026-11-03'),
    _tx(2, 'pengeluaran', 'Makanan', 50000, '2026-11-02'),
    _tx(1, 'pemasukan', 'Gaji', 2000000, '2026-11-01'),
  ];
  final client = MockClient((_) async => http.Response(
        jsonEncode({'data': data}),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      ));
  return TransactionService(ApiClient(client: client, tokenStorage: _FakeStorage()));
}

void main() {
  test('tab Semua: total tampil = pemasukan - pengeluaran', () async {
    final r = await _service().fetchHistory();
    expect(r.transactions.length, 3);
    expect(r.displayedTotal, 1930000);
  });

  test('tab Pengeluaran: hanya pengeluaran dan jumlahnya dijumlah', () async {
    final r = await _service().fetchHistory(type: 'pengeluaran');
    expect(r.transactions.every((t) => t.type == 'pengeluaran'), true);
    expect(r.displayedTotal, 70000);
  });

  test('filter kategori menyaring daftar', () async {
    final r = await _service().fetchHistory(categoryName: 'Makanan');
    expect(r.transactions.length, 1);
    expect(r.transactions.first.categoryName, 'Makanan');
  });

  test('filter tanggal bersifat inklusif di kedua ujung', () async {
    final r = await _service().fetchHistory(
      startDate: DateTime(2026, 11, 2),
      endDate: DateTime(2026, 11, 3),
    );
    expect(r.transactions.map((t) => t.id), [3, 2]);
  });
}