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
      categoryName: _categoryName(json),
      type: json['jenis_transaksi'] as String,
      title: json['nama_transaksi'] as String,
      amount: _toDouble(json['nominal']),
      date: _toDate(json['tanggal_transaksi'] as String),
      notes: json['catatan'] as String?,
    );
  }

  /// Backend mengirim nama kategori di dalam relasi `kategori`.
  static String _categoryName(Map<String, dynamic> json) {
    final flat = json['nama_kategori'];
    if (flat is String) return flat;
    final nested = json['kategori'];
    if (nested is Map && nested['nama_kategori'] is String) {
      return nested['nama_kategori'] as String;
    }
    return '';
  }

  /// Backend mengirim nominal sebagai teks (mis. "50000.00"), bukan angka.
  static double _toDouble(dynamic v) =>
      v is num ? v.toDouble() : double.parse(v.toString());

  /// Backend mengirim tanggal seperti "2026-11-17T00:00:00.000000Z".
  /// Dibaca sebagai tanggal biasa supaya tidak bergeser karena zona waktu.
  static DateTime _toDate(String s) {
    final d = DateTime.parse(s);
    return d.isUtc ? DateTime(d.year, d.month, d.day, d.hour, d.minute) : d;
  }
}