import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/dio_client.dart';
import '../../data/models/product_model.dart';
import 'product_repository.dart';
 
class ProductRepositoryImpl implements ProductRepository {
  final _dio = DioClient.instance;
 
  @override
  Future<List<ProductModel>> getProducts({int page = 1, int limit = 10, String? category}) async {
    final queryParams = <String, dynamic>{'page': page, 'limit': limit};
    if (category != null && category.isNotEmpty) queryParams['category'] = category;
 
    final response = await _dio.get(ApiConstants.products, queryParameters: queryParams);
    final List data = response.data['data'] ?? [];
    return data.map((e) => ProductModel.fromJson(e)).toList();
  }
}
