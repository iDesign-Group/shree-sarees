import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/cart_provider.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

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
                  Icon(Icons.shopping_bag_outlined,
                      size: 64, color: AppTheme.border),
                  const SizedBox(height: 16),
                  Text('Your cart is empty',
                      style: GoogleFonts.inter(color: AppTheme.textSecondary)),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.items.length,
                    separatorBuilder: (_, __) =>
                        const Divider(color: AppTheme.accent, height: 24),
                    itemBuilder: (ctx, i) {
                      final item = cart.items[i];
                      final imgUrl = item.product.images.isNotEmpty
                          ? '${ApiService.baseUrl}/${item.product.images.first.imagePath}'
                          : null;

                      return Row(
                        children: [
                          // Thumbnail
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: imgUrl != null
                                ? CachedNetworkImage(
                                    imageUrl: imgUrl,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover)
                                : Container(
                                    width: 60,
                                    height: 60,
                                    color: AppTheme.background,
                                    child: const Icon(Icons.image,
                                        color: AppTheme.border)),
                          ),
                          const SizedBox(width: 12),
                          // Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.product.productName,
                                    style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600)),
                                Text(item.product.productCode,
                                    style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: AppTheme.textSecondary)),
                              ],
                            ),
                          ),
                          // Stepper
                          Row(
                            children: [
                              _MiniBtn(
                                icon: Icons.remove,
                                onTap: () => cart.updateBundles(
                                    item.product.id, item.bundles - 1),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Text('${item.bundles}',
                                    style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w700)),
                              ),
                              _MiniBtn(
                                icon: Icons.add,
                                onTap: () => cart.updateBundles(
                                    item.product.id, item.bundles + 1),
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Text('₹${item.totalCost.toStringAsFixed(0)}',
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primary)),
                        ],
                      );
                    },
                  ),
                ),
                // Summary
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: AppTheme.surface,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 12,
                          offset: Offset(0, -2)),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total Sarees',
                              style: GoogleFonts.inter(
                                  color: AppTheme.textSecondary)),
                          Text('${cart.totalSarees}',
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total Amount',
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600)),
                          Text('₹${cart.totalAmount.toStringAsFixed(0)}',
                              style: GoogleFonts.inter(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primary)),
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
                          onPressed: cart.isPlacingOrder
                              ? null
                              : () => _placeOrder(context),
                          child: cart.isPlacingOrder
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
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
    try {
      final order = await cart.placeOrder();
      if (order != null && context.mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle,
                    color: AppTheme.success, size: 56),
                const SizedBox(height: 16),
                Text('Order Placed Successfully!',
                    style: GoogleFonts.playfairDisplay(
                        fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text('Order #${order.id}',
                    style: GoogleFonts.inter(color: AppTheme.accent)),
                Text(
                    '${order.totalSarees} sarees | ₹${order.totalAmount.toStringAsFixed(0)}',
                    style: GoogleFonts.inter(color: AppTheme.textSecondary)),
                const SizedBox(height: 8),
                Text('A confirmation email has been sent to you.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                        fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
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
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.accent),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16, color: AppTheme.primary),
      ),
    );
  }
}
