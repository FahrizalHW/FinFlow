import 'transaction_model.dart';

/// Hasil riwayat dari backend: daftar transaksi (sudah terfilter dan terurut)
/// dan angka yang ditampilkan di atas daftar.
class HistoryResult {
  final List<TransactionModel> transactions;
  final double displayedTotal;

  const HistoryResult({
    required this.transactions,
    required this.displayedTotal,
  });

  factory HistoryResult.fromJson(Map<String, dynamic> json) {
    return HistoryResult(
      transactions: (json['data'] as List)
          .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      displayedTotal: (json['total_tampil'] as num).toDouble(),
    );
  }
}