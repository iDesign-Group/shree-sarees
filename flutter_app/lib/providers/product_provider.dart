import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  List<Product> get products {
    if (_searchQuery.isEmpty) return _products;
    return _products.where((p) {
      final q = _searchQuery.toLowerCase();
      return p.productName.toLowerCase().contains(q) ||
          p.productCode.toLowerCase().contains(q);
    }).toList();
  }

  List<Product> get allProducts => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> loadProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await ApiService.getProducts();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
