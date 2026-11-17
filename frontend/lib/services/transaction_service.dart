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
}