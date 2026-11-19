import 'package:finflow_app/models/summary_model.dart';
import 'package:finflow_app/models/transaction_model.dart';
import 'package:finflow_app/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TransactionModel.fromJson', () {
    final json = {
      'id_transaksi': 1,
      'id_user': 1,
      'id_kategori': 2,
      'jenis_transaksi': 'pengeluaran',
      'nama_transaksi': 'Makan Siang',
      'nominal': '50000.00', // backend mengirim teks
      'tanggal_transaksi': '2026-11-17T00:00:00.000000Z',
      'catatan': null,
      'kategori': {'nama_kategori': 'Makanan'},
    };

    test('nominal berbentuk teks dibaca sebagai angka', () {
      expect(TransactionModel.fromJson(json).amount, 50000.0);
    });

    test('nama kategori dibaca dari relasi kategori', () {
      expect(TransactionModel.fromJson(json).categoryName, 'Makanan');
    });

    test('tanggal UTC tidak bergeser karena zona waktu', () {
      final t = TransactionModel.fromJson(json);
      expect(t.date, DateTime(2026, 11, 17));
    });

    test('isIncome hanya true untuk pemasukan', () {
      expect(TransactionModel.fromJson(json).isIncome, false);
      final income = Map<String, dynamic>.from(json)
        ..['jenis_transaksi'] = 'pemasukan';
      expect(TransactionModel.fromJson(income).isIncome, true);
    });
  });

  test('SummaryModel.fromJson membaca saldo, total, dan transaksi terbaru', () {
    final s = SummaryModel.fromJson({
      'saldo': 1950000,
      'total_pemasukan': 2000000,
      'total_pengeluaran': 50000,
      'transaksi_terbaru': [],
    });
    expect(s.balance, 1950000);
    expect(s.totalIncome, 2000000);
    expect(s.totalExpense, 50000);
    expect(s.recentTransactions, isEmpty);
  });

  test('UserModel.copyWith mempertahankan id dan foto', () {
    const u = UserModel(id: 7, username: 'nofal', profilePhoto: '/a.jpg');
    final c = u.copyWith(username: 'baru');
    expect(c.id, 7);
    expect(c.username, 'baru');
    expect(c.profilePhoto, '/a.jpg');
  });
}
