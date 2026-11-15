class CategoryModel {
  final int id;
  final int? userId; // null means system default
  final String name;
  final String type; // 'pemasukan' or 'pengeluaran'

  const CategoryModel({
    required this.id,
    this.userId,
    required this.name,
    required this.type,
  });

  bool get isDefault => userId == null;

  CategoryModel copyWith({
    int? id,
    int? userId,
    String? name,
    String? type,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_kategori': id,
      'id_user': userId,
      'nama_kategori': name,
      'jenis': type,
    };
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id_kategori'] as int,
      userId: json['id_user'] as int?,
      name: json['nama_kategori'] as String,
      type: json['jenis'] as String,
    );
  }
}

