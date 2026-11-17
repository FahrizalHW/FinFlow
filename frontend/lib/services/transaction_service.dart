import '../models/history_result.dart';
import '../models/summary_model.dart';
import '../models/transaction_model.dart';
import 'api_client.dart';

class TransactionService {
  TransactionService(this._api);
  final ApiClient _api;

  Future<SummaryModel> fetchSummary() async {
    final data = await _api.get('/ringkasan') as Map<String, dynamic>;
    return SummaryModel.fromJson(data);
  }

  Future<HistoryResult> fetchHistory({
    String? type,
    String? categoryName,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final data =
        await _api.get(
              '/transaksi',
              query: {
                if (type != null) 'jenis': type,
                if (categoryName != null) 'kategori': categoryName,
                if (startDate != null) 'tanggal_mulai': _dateOnly(startDate),
                if (endDate != null) 'tanggal_akhir': _dateOnly(endDate),
              },
            )
            as Map<String, dynamic>;
    return HistoryResult.fromJson(data);
  }

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
                'tanggal_transaksi':
                    '${_dateOnly(date)} ${_two(date.hour)}:${_two(date.minute)}:00',
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
                'tanggal_transaksi':
                    '${_dateOnly(date)} ${_two(date.hour)}:${_two(date.minute)}:00',
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
