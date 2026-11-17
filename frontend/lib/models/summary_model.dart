import 'transaction_model.dart';

class SummaryModel {
  final double balance;
  final double monthlyIncome;
  final double monthlyExpense;
  final List<TransactionModel> recentTransactions;

  const SummaryModel({
    required this.balance,
    required this.monthlyIncome,
    required this.monthlyExpense,
    required this.recentTransactions,
  });

  factory SummaryModel.fromJson(Map<String, dynamic> json) {
    return SummaryModel(
      balance: (json['saldo'] as num).toDouble(),
      monthlyIncome: (json['pemasukan_bulan_ini'] as num).toDouble(),
      monthlyExpense: (json['pengeluaran_bulan_ini'] as num).toDouble(),
      recentTransactions: (json['transaksi_terbaru'] as List)
          .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}