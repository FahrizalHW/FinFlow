import '../models/history_result.dart';
import '../models/summary_model.dart';
import '../models/transaction_model.dart';
import 'api_client.dart';

class TransactionService {
  TransactionService(this._api);
  final ApiClient _api;

  /// Mengambil semua transaksi milik user (sudah terurut terbaru di atas).
  Future<List<TransactionModel>> _fetchAll() async {
    final data = await _api.get('/transaksi') as Map<String, dynamic>;
    return (data['data'] as List)
        .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<SummaryModel> fetchSummary() async {
    final res = await _api.get('/ringkasan') as Map<String, dynamic>;
    return SummaryModel.fromJson(res['data'] as Map<String, dynamic>);
  }

  // SEMENTARA: backend belum punya filter dan total_tampil di /transaksi, jadi
  // filter dan total dihitung di sini. Kalau backend sudah menyediakannya,
  // kirim parameter filter lewat `query` dan baca `total_tampil` dari respons.
  Future<HistoryResult> fetchHistory({
    String? type,
    String? categoryName,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final all = await _fetchAll();
    final start = startDate == null ? null : _dateOnly(startDate);
    final end = endDate == null ? null : _dateOnly(endDate);

    final filtered = all.where((t) {
      if (type != null && t.type != type) return false;
      if (categoryName != null && t.categoryName != categoryName) return false;
      final day = _dateOnly(t.date);
      if (start != null && day.compareTo(start) < 0) return false;
      if (end != null && day.compareTo(end) > 0) return false;
      return true;
    }).toList();

    // Tab Semua: saldo total. Tab Pemasukan/Pengeluaran: jumlah yang lolos filter.
    final total = type == null
        ? _sum(all, 'pemasukan') - _sum(all, 'pengeluaran')
        : _sum(filtered, type);

    return HistoryResult(transactions: filtered, displayedTotal: total);
  }

  double _sum(List<TransactionModel> list, String type) => list
      .where((t) => t.type == type)
      .fold<double>(0, (sum, t) => sum + t.amount);

  Future<TransactionModel> create({
    required String title,
    required double amount,
    required String type,
    required int categoryId,
    required DateTime date,
    String? notes,
  }) async {
    final data =
        await _api.post(
              '/transaksi',
              body: {
                'nama_transaksi': title,
                'nominal': amount,
                'jenis_transaksi': type,
                'id_kategori': categoryId,
                'tanggal_transaksi': _dateOnly(date),
                'catatan': notes,
              },
            )
            as Map<String, dynamic>;
    return TransactionModel.fromJson(data['data'] as Map<String, dynamic>);
  }

  Future<TransactionModel> update({
    required int id,
    required String title,
    required double amount,
    required String type,
    required int categoryId,
    required DateTime date,
    String? notes,
  }) async {
    final data =
        await _api.put(
              '/transaksi/$id',
              body: {
                'nama_transaksi': title,
                'nominal': amount,
                'jenis_transaksi': type,
                'id_kategori': categoryId,
                'tanggal_transaksi': _dateOnly(date),
                'catatan': notes,
              },
            )
            as Map<String, dynamic>;
    return TransactionModel.fromJson(data['data'] as Map<String, dynamic>);
  }

  Future<void> delete(int id) async {
    await _api.delete('/transaksi/$id');
  }

  String _dateOnly(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${_two(d.month)}-${_two(d.day)}';

  String _two(int n) => n.toString().padLeft(2, '0');
}