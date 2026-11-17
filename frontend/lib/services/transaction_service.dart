import '../models/history_result.dart';
import '../models/summary_model.dart';
import 'api_client.dart';

class TransactionService {
  TransactionService(this._api);
  final ApiClient _api;

  /// Saldo, total bulan ini, dan transaksi terbaru (dihitung server).
  Future<SummaryModel> fetchSummary() async {
    final data = await _api.get('/ringkasan') as Map<String, dynamic>;
    return SummaryModel.fromJson(data);
  }

  /// Riwayat. Pemfilteran, pengurutan, dan penjumlahan dilakukan di server.
  Future<HistoryResult> fetchHistory({
    String? type,
    String? categoryName,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final data = await _api.get('/transaksi', query: {
      'jenis': ?type,
      'kategori': ?categoryName,
      if (startDate != null) 'tanggal_mulai': _dateOnly(startDate),
      if (endDate != null) 'tanggal_akhir': _dateOnly(endDate),
    }) as Map<String, dynamic>;

    return HistoryResult.fromJson(data);
  }

  String _dateOnly(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}