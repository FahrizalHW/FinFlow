import 'transaction_model.dart';

class SummaryModel {
  final double balance;
  final double totalIncome;
  final double totalExpense;
  final List<TransactionModel> recentTransactions;

  const SummaryModel({
    required this.balance,
    required this.totalIncome,
    required this.totalExpense,
    required this.recentTransactions,
  });

  factory SummaryModel.fromJson(Map<String, dynamic> json) {
    return SummaryModel(
      balance: (json['saldo'] as num).toDouble(),
      totalIncome: (json['total_pemasukan'] as num).toDouble(),
      totalExpense: (json['total_pengeluaran'] as num).toDouble(),
      recentTransactions: (json['transaksi_terbaru'] as List)
          .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}