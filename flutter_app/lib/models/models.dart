// ── Product ──────────────────────────────────────────────────
class ProductImage {
  final int id;
  final String imagePath;

  ProductImage({required this.id, required this.imagePath});

  factory ProductImage.fromJson(Map<String, dynamic> json) => ProductImage(
        id: json['id'],
        imagePath: json['image_path'] ?? '',
      );
}

class Product {
  final int id;
  final String productCode;
  final String productName;
  final int setSize;
  final double pricePerSaree;
  final int? totalBundles;
  final int? totalSareesInStock;
  final List<ProductImage> images;

  Product({
    required this.id,
    required this.productCode,
    required this.productName,
    required this.setSize,
    required this.pricePerSaree,
    this.totalBundles,
    this.totalSareesInStock,
    this.images = const [],
  });

  double get bundlePrice => setSize * pricePerSaree;

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'],
        productCode: json['product_code'] ?? '',
        productName: json['product_name'] ?? '',
        setSize: json['set_size'] ?? 0,
        pricePerSaree: double.tryParse(json['price_per_saree'].toString()) ?? 0,
        totalBundles: json['total_bundles'] != null ? int.tryParse(json['total_bundles'].toString()) : null,
        totalSareesInStock: json['total_sarees_in_stock'] != null ? int.tryParse(json['total_sarees_in_stock'].toString()) : null,
        images: json['images'] != null
            ? (json['images'] as List).map((e) => ProductImage.fromJson(e)).toList()
            : [],
      );
}

// ── Cart Item ───────────────────────────────────────────
class CartItem {
  final Product product;
  int bundles;

  CartItem({required this.product, this.bundles = 1});

  int get sareesCount => bundles * product.setSize;
  double get totalCost => sareesCount * product.pricePerSaree;
}

// ── Order ───────────────────────────────────────────────
class OrderItem {
  final int productId;
  final String productCode;
  final String productName;
  final int bundlesOrdered;
  final int sareesCount;
  final double pricePerSaree;
  final double bundleCost;

  OrderItem({
    required this.productId,
    required this.productCode,
    required this.productName,
    required this.bundlesOrdered,
    required this.sareesCount,
    required this.pricePerSaree,
    required this.bundleCost,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        productId: json['product_id'],
        productCode: json['product_code'] ?? '',
        productName: json['product_name'] ?? '',
        bundlesOrdered: json['bundles_ordered'] ?? 0,
        sareesCount: json['sarees_count'] ?? 0,
        pricePerSaree:
            double.tryParse(json['price_per_saree_at_order'].toString()) ?? 0,
        bundleCost: double.tryParse(json['bundle_cost'].toString()) ?? 0,
      );
}

class Order {
  final int id;
  final int userId;
  final String status;
  final DateTime orderDate;
  final int totalSarees;
  final double totalAmount;
  final String? userName;
  final String? storeName;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.userId,
    required this.status,
    required this.orderDate,
    required this.totalSarees,
    required this.totalAmount,
    this.userName,
    this.storeName,
    this.items = const [],
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'],
        userId: json['user_id'] ?? 0,
        status: json['status'] ?? 'pending',
        orderDate: DateTime.tryParse(json['order_date'] ?? '') ?? DateTime.now(),
        totalSarees: json['total_sarees'] ?? 0,
        totalAmount: double.tryParse(json['total_amount'].toString()) ?? 0,
        userName: json['user_name'],
        storeName: json['store_name'],
        items: json['items'] != null
            ? (json['items'] as List).map((e) => OrderItem.fromJson(e)).toList()
            : [],
      );
}

// ── Store Name (autocomplete) ───────────────────────────
class StoreName {
  final int id;
  final String name;

  StoreName({required this.id, required this.name});

  factory StoreName.fromJson(Map<String, dynamic> json) => StoreName(
        id: json['id'],
        name: json['name'] ?? '',
      );
}

// ── Shipment ──────────────────────────────────────────
class Shipment {
  final int id;
  final int orderId;
  final String? courierName;
  final String? trackingNumber;
  final String? shipmentDate;
  final String? notes;

  Shipment({
    required this.id,
    required this.orderId,
    this.courierName,
    this.trackingNumber,
    this.shipmentDate,
    this.notes,
  });

  factory Shipment.fromJson(Map<String, dynamic> json) => Shipment(
        id: json['id'],
        orderId: json['order_id'],
        courierName: json['courier_name'],
        trackingNumber: json['tracking_number'],
        shipmentDate: json['shipment_date'],
        notes: json['notes'],
      );
}

// ── User ────────────────────────────────────────────────
class AppUser {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? phone;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'],
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        role: json['role'] ?? 'broker',
        phone: json['phone'],
      );

  bool get isAdmin => role == 'admin';
  bool get isBroker => role == 'broker';
}
