import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class OrderProvider extends ChangeNotifier {
  List<Order> _orders = [];
  bool _isLoading = false;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;

  Future<void> loadOrders() async {
    _isLoading = true;
    notifyListeners();

    try {
      _orders = await ApiService.getOrders();
    } catch (e) {
      // silently fail
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Order> getOrderDetail(int id) async {
    return await ApiService.getOrder(id);
  }
}
