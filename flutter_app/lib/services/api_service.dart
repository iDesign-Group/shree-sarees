import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class ApiService {
  // Auto-detect: localhost for web browser, LAN IP for real device
  static final String baseUrl = kIsWeb
      ? 'http://localhost:3000'
      : 'http://192.168.1.11:3000';
  static String? _memoryToken;
  static Future<String?> _getToken() async {
    if (_memoryToken != null) return _memoryToken;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<Map<String, String>> _headers() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ── Auth ────────────────────────────────────────────
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode != 200) throw Exception(data['error']);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', data['token']);
    await prefs.setString('user', jsonEncode(data['user']));
    _memoryToken = data['token'];
    return data;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
    _memoryToken = null;
  }

  static Future<AppUser?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('user');
    if (userStr == null) return null;

    // Restore token into memory on app start
    final token = prefs.getString('token');
    if (token != null) _memoryToken = token;

    return AppUser.fromJson(jsonDecode(userStr));
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') != null;
  }

  // ── Products ────────────────────────────────────────
  static Future<List<Product>> getProducts() async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/products'),
      headers: await _headers(),
    );
    if (res.statusCode != 200) throw Exception('Failed to load products');
    final List data = jsonDecode(res.body);
    return data.map((e) => Product.fromJson(e)).toList();
  }

  static Future<Product> getProduct(int id) async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/products/$id'),
      headers: await _headers(),
    );
    if (res.statusCode != 200) throw Exception('Failed to load product');
    return Product.fromJson(jsonDecode(res.body));
  }

  // ── Orders ──────────────────────────────────────────
  static Future<Order> placeOrder(List<Map<String, dynamic>> items) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/orders'),
      headers: await _headers(),
      body: jsonEncode({'items': items}),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode != 201) throw Exception(data['error']);
    return Order.fromJson(data);
  }

  static Future<List<Order>> getOrders() async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/orders'),
      headers: await _headers(),
    );
    if (res.statusCode != 200) throw Exception('Failed to load orders');
    final List data = jsonDecode(res.body);
    return data.map((e) => Order.fromJson(e)).toList();
  }

  static Future<Order> getOrder(int id) async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/orders/$id'),
      headers: await _headers(),
    );
    if (res.statusCode != 200) throw Exception('Failed to load order');
    return Order.fromJson(jsonDecode(res.body));
  }

  // ── Shipments ───────────────────────────────────────
  static Future<Shipment?> getShipment(int orderId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/shipments/$orderId'),
      headers: await _headers(),
    );
    if (res.statusCode == 404) return null;
    if (res.statusCode != 200) throw Exception('Failed to load shipment');
    return Shipment.fromJson(jsonDecode(res.body));
  }

  // ── Users (Admin) ───────────────────────────────────
  static Future<List<AppUser>> getUsers() async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/users'),
      headers: await _headers(),
    );
    if (res.statusCode != 200) throw Exception('Failed to load users');
    final List data = jsonDecode(res.body);
    return data.map((e) => AppUser.fromJson(e)).toList();
  }

  // ── Dashboard Stats (Admin) ─────────────────────────
  static Future<Map<String, dynamic>> getDashboardStats() async {
    final products = await getProducts();
    final orders = await getOrders();
    final users = await getUsers();

    int totalBundles = 0;
    for (final p in products) {
      totalBundles += p.totalBundles ?? 0;
    }

    int pendingOrders = orders.where((o) => o.status == 'pending').length;

    return {
      'totalProducts': products.length,
      'totalBundles': totalBundles,
      'pendingOrders': pendingOrders,
      'totalUsers': users.length,
      'recentOrders': orders.take(10).toList(),
    };
  }
}
