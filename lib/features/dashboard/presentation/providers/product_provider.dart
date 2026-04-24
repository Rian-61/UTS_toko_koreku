import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';
import '../../domain/repositories/product_repository_impl.dart';
 
enum ProductStatus { initial, loading, loaded, error }
 
class ProductProvider extends ChangeNotifier {
  final _repo = ProductRepositoryImpl();
 
  ProductStatus _status = ProductStatus.initial;
  List<ProductModel> _products = [];
  List<ProductModel> _filtered = [];
  String? _errorMessage;
  String _selectedCategory = '';
  String _searchQuery = '';
 
  ProductStatus get status => _status;
  List<ProductModel> get products => _filtered;
  String? get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;
 
  Future<void> loadProducts() async {
    _status = ProductStatus.loading;
    notifyListeners();
    try {
      _products = await _repo.getProducts();
      _applyFilter();
      _status = ProductStatus.loaded;
    } catch (e) {
      _status = ProductStatus.error;
      _errorMessage = 'Gagal memuat produk. Pastikan backend jalan.';
    }
    notifyListeners();
  }
 
  void setCategory(String category) {
    _selectedCategory = category;
    _applyFilter();
    notifyListeners();
  }
 
  void setSearch(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilter();
    notifyListeners();
  }
 
  void _applyFilter() {
    _filtered = _products.where((p) {
      final matchCat = _selectedCategory.isEmpty || p.category == _selectedCategory;
      final matchSearch = _searchQuery.isEmpty || p.name.toLowerCase().contains(_searchQuery);
      return matchCat && matchSearch;
    }).toList();
  }
 
  List<String> get categories {
    final cats = _products.map((p) => p.category).toSet().toList();
    return ['Semua', ...cats];
  }
}
