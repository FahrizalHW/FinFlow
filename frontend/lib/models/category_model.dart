class CategoryModel {
  final int id;
  final int? userId; // null = kategori bawaan sistem
  final String name;
  final String type; // 'pemasukan' atau 'pengeluaran'

  const CategoryModel({
    required this.id,
    this.userId,
    required this.name,
    required this.type,
  });

  bool get isDefault => userId == null;

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id_kategori'] as int,
      userId: json['id_user'] as int?,
      name: json['nama_kategori'] as String,
      type: json['jenis_kategori'] as String,
    );
  }
}