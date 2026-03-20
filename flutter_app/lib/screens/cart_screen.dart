import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../services/api_service.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _storeController = TextEditingController();
  List<StoreName> _storeNames = [];
  List<StoreName> _suggestions = [];
  bool _isBroker = false;

  @override
  void initState() {
    super.initState();
    _checkRole();
  }

  Future<void> _checkRole() async {
    final user = await ApiService.getCurrentUser();
    if (user != null && user.isBroker) {
      setState(() => _isBroker = true);
      final stores = await ApiService.getStoreNames();
      setState(() => _storeNames = stores);
    }
  }

  void _onStoreChanged(String value) {
    setState(() {
      _suggestions = value.isEmpty
          ? []
          : _storeNames
              .where((s) => s.name.toLowerCase().contains(value.toLowerCase()))
              .toList();
    });
  }

  @override
  void dispose() {
    _storeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: cart.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 64, color: AppTheme.border),
                  const SizedBox(height: 16),
                  Text('Your cart is empty', style: GoogleFonts.inter(color: AppTheme.textSecondary)),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.items.length,
                    separatorBuilder: (_, __) => const Divider(color: AppTheme.accent, height: 24),
                    itemBuilder: (ctx, i) {
                      final item = cart.items[i];
                      final imgUrl = item.product.images.isNotEmpty
                          ? '${ApiService.baseUrl}/${item.product.images.first.imagePath}'
                          : null;
                      return Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: imgUrl != null
                                ? CachedNetworkImage(imageUrl: imgUrl, width: 60, height: 60, fit: BoxFit.cover)
                                : Container(width: 60, height: 60, color: AppTheme.background,
                                    child: const Icon(Icons.image, color: AppTheme.border)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.product.productName, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                                Text(item.product.productCode, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              _MiniBtn(icon: Icons.remove, onTap: () => cart.updateBundles(item.product.id, item.bundles - 1)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Text('${item.bundles}', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                              ),
                              _MiniBtn(icon: Icons.add, onTap: () => cart.updateBundles(item.product.id, item.bundles + 1)),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Text('\u20b9${item.totalCost.toStringAsFixed(0)}',
                              style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppTheme.primary)),
                        ],
                      );
                    },
                  ),
                ),
                // Summary + Store Name
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: AppTheme.surface,
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, -2))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Store name field — brokers only
                      if (_isBroker) ...
                        [
                          Text('Placing order for', style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _storeController,
                            onChanged: _onStoreChanged,
                            decoration: InputDecoration(
                              hintText: 'Enter saree store name',
                              hintStyle: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary),
                              prefixIcon: const Icon(Icons.store_outlined, color: AppTheme.primary, size: 20),
                              filled: true,
                              fillColor: AppTheme.background,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppTheme.border),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppTheme.accent, width: 2),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                            style: GoogleFonts.inter(fontSize: 14),
                          ),
                          // Autocomplete suggestions
                          if (_suggestions.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.surface,
                                border: Border.all(color: AppTheme.border),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6)],
                              ),
                              child: Column(
                                children: _suggestions.map((s) => InkWell(
                                  onTap: () {
                                    _storeController.text = s.name;
                                    setState(() => _suggestions = []);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.history, size: 16, color: AppTheme.textSecondary),
                                        const SizedBox(width: 8),
                                        Text(s.name, style: GoogleFonts.inter(fontSize: 13)),
                                      ],
                                    ),
                                  ),
                                )).toList(),
                              ),
                            ),
                          const SizedBox(height: 14),
                        ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total Sarees', style: GoogleFonts.inter(color: AppTheme.textSecondary)),
                          Text('${cart.totalSarees}', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total Amount', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                          Text('\u20b9${cart.totalAmount.toStringAsFixed(0)}',
                              style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.primary)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: cart.isPlacingOrder ? null : () => _placeOrder(context),
                          child: cart.isPlacingOrder
                              ? const SizedBox(height: 20, width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Text('Place Order'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  void _placeOrder(BuildContext context) async {
    final cart = context.read<CartProvider>();
    // Validate store name for brokers
    if (_isBroker && _storeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the store name before placing the order.'), backgroundColor: Colors.red),
      );
      return;
    }
    try {
      final order = await cart.placeOrder(
        storeName: _isBroker ? _storeController.text.trim() : null,
      );
      if (order != null && context.mounted) {
        _storeController.clear();
        setState(() => _suggestions = []);
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: AppTheme.success, size: 56),
                const SizedBox(height: 16),
                Text('Order Placed Successfully!',
                    style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text('Order #${order.id}', style: GoogleFonts.inter(color: AppTheme.accent)),
                Text('${order.totalSarees} sarees | \u20b9${order.totalAmount.toStringAsFixed(0)}',
                    style: GoogleFonts.inter(color: AppTheme.textSecondary)),
                if (order.storeName != null) ...
                  [
                    const SizedBox(height: 4),
                    Text('For: ${order.storeName}',
                        style: GoogleFonts.inter(fontSize: 13, color: AppTheme.primary, fontWeight: FontWeight.w600)),
                  ],
                const SizedBox(height: 8),
                Text('A confirmation email has been sent to you.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to place order: $e')),
        );
      }
    }
  }
}

class _MiniBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _MiniBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.accent),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16, color: AppTheme.primary),
      ),
    );
  }
}
