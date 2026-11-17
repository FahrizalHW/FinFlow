class TransactionModel {
  final int id;
  final int userId;
  final int categoryId;
  final String categoryName;
  final String type; // 'pemasukan' atau 'pengeluaran'
  final String title;
  final double amount;
  final DateTime date;
  final String? notes;

  const TransactionModel({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.categoryName,
    required this.type,
    required this.title,
    required this.amount,
    required this.date,
    this.notes,
  });

  bool get isIncome => type.toLowerCase() == 'pemasukan';

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id_transaksi'] as int,
      userId: json['id_user'] as int,
      categoryId: json['id_kategori'] as int,
      categoryName: (json['nama_kategori'] as String?) ?? '',
      type: json['jenis_transaksi'] as String,
      title: json['nama_transaksi'] as String,
      amount: (json['nominal'] as num).toDouble(),
      date: DateTime.parse(json['tanggal_transaksi'] as String),
      notes: json['catatan'] as String?,
    );
  }
}