class TransactionModel {
  final int id;
  final int userId;
  final int categoryId;
  final String categoryName;
  final String type; // 'pemasukan' or 'pengeluaran'
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

  TransactionModel copyWith({
    int? id,
    int? userId,
    int? categoryId,
    String? categoryName,
    String? type,
    String? title,
    double? amount,
    DateTime? date,
    String? notes,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      type: type ?? this.type,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_transaksi': id,
      'id_user': userId,
      'id_kategori': categoryId,
      'nama_kategori': categoryName,
      'jenis_transaksi': type,
      'nama_transaksi': title,
      'nominal': amount,
      'tanggal_transaksi': date.toIso8601String(),
      'catatan': notes,
    };
  }
}

