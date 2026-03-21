import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  bool _isPlacingOrder = false;

  List<CartItem> get items => _items;
  bool get isPlacingOrder => _isPlacingOrder;
  int get itemCount => _items.length;
  bool get isEmpty => _items.isEmpty;

  int get totalSarees => _items.fold(0, (sum, item) => sum + item.sareesCount);
  double get totalAmount => _items.fold(0, (sum, item) => sum + item.totalCost);

  void addToCart(Product product, int bundles) {
    final existing = _items.indexWhere((i) => i.product.id == product.id);
    if (existing >= 0) {
      _items[existing].bundles += bundles;
    } else {
      _items.add(CartItem(product: product, bundles: bundles));
    }
    notifyListeners();
  }

  void updateBundles(int productId, int bundles) {
    final idx = _items.indexWhere((i) => i.product.id == productId);
    if (idx >= 0) {
      if (bundles <= 0) {
        _items.removeAt(idx);
      } else {
        _items[idx].bundles = bundles;
      }
      notifyListeners();
    }
  }

  void removeItem(int productId) {
    _items.removeWhere((i) => i.product.id == productId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  Future<Order?> placeOrder({
    String? storeName,
    String? storeAddress,
    String? storePhone,
  }) async {
    if (_items.isEmpty) return null;
    _isPlacingOrder = true;
    notifyListeners();
    try {
      final orderItems = _items
          .map((item) => {
                'product_id': item.product.id,
                'bundles_ordered': item.bundles,
              })
          .toList();
      final order = await ApiService.placeOrder(
        orderItems,
        storeName: storeName,
        storeAddress: storeAddress,
        storePhone: storePhone,
      );
      _items.clear();
      _isPlacingOrder = false;
      notifyListeners();
      return order;
    } catch (e) {
      _isPlacingOrder = false;
      notifyListeners();
      rethrow;
    }
  }
}
