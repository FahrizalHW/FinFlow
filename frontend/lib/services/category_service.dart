import '../models/category_model.dart';
import 'api_client.dart';

class CategoryService {
  CategoryService(this._api);
  final ApiClient _api;

  Future<List<CategoryModel>> fetchAll() async {
    final data = await _api.get('/kategori') as Map<String, dynamic>;
    return (data['data'] as List)
        .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<CategoryModel> create({required String name, required String type}) async {
    final data = await _api.post('/kategori', body: {
      'nama_kategori': name,
      'jenis_kategori': type,
    }) as Map<String, dynamic>;
    return CategoryModel.fromJson(data['data'] as Map<String, dynamic>);
  }

  Future<void> delete(int id) async {
    await _api.delete('/kategori/$id');
  }
}