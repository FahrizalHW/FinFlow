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
}