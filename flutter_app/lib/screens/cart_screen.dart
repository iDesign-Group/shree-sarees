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
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  List<StoreName> _storeNames = [];
  List<StoreName> _suggestions = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadStoreNamesIfBroker());
  }

  Future<void> _loadStoreNamesIfBroker() async {
    final auth = context.read<AuthProvider>();
    if (!auth.isBroker) return;
    final stores = await ApiService.getStoreNames();
    if (mounted) setState(() => _storeNames = stores);
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
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final isBroker = context.watch<AuthProvider>().isBroker;
    final bottomPad = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      resizeToAvoidBottomInset: true,
      body: cart.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 64, color: AppTheme.border),
                  const SizedBox(height: 16),
                  Text('Your cart is empty', style: GoogleFonts.plusJakartaSans(color: AppTheme.textSecondary)),
                ],
              ),
            )
          : ListView(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 20 + bottomPad),
              children: [
                ...cart.items.asMap().entries.map((e) {
                  final item = e.value;
                  final imgUrl = item.product.images.isNotEmpty
                      ? '${ApiService.baseUrl}/${item.product.images.first.imagePath}'
                      : null;
                  return Padding(
                    padding: EdgeInsets.only(bottom: e.key < cart.items.length - 1 ? 16 : 0),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: imgUrl != null
                                  ? CachedNetworkImage(imageUrl: imgUrl, width: 60, height: 60, fit: BoxFit.cover)
                                  : Container(
                                      width: 60,
                                      height: 60,
                                      color: AppTheme.background,
                                      child: const Icon(Icons.image, color: AppTheme.border)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.product.productName,
                                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
                                  Text(item.product.productCode,
                                      style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textSecondary)),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _MiniBtn(icon: Icons.remove, onTap: () => cart.updateBundles(item.product.id, item.bundles - 1)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text('${item.bundles}',
                                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
                                ),
                                _MiniBtn(icon: Icons.add, onTap: () => cart.updateBundles(item.product.id, item.bundles + 1)),
                              ],
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 72,
                              child: Text(
                                '\u20b9${item.totalCost.toStringAsFixed(0)}',
                                textAlign: TextAlign.end,
                                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: AppTheme.primary),
                              ),
                            ),
                          ],
                        ),
                        if (e.key < cart.items.length - 1)
                          const Padding(
                            padding: EdgeInsets.only(top: 16),
                            child: Divider(color: AppTheme.accent, height: 1),
                          ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isBroker) ...[
                        Text('Placing order for',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _storeController,
                          onChanged: _onStoreChanged,
                          decoration: InputDecoration(
                            hintText: 'Saree store name',
                            hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.textSecondary),
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
                          style: GoogleFonts.plusJakartaSans(fontSize: 14),
                        ),
                        if (_suggestions.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(top: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              border: Border.all(color: AppTheme.border),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6),
                              ],
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
                                          Expanded(child: Text(s.name, style: GoogleFonts.plusJakartaSans(fontSize: 13))),
                                        ],
                                      ),
                                    ),
                                  )).toList(),
                            ),
                          ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _addressController,
                          minLines: 2,
                          maxLines: 4,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                            hintText: 'Full delivery address (area, city, PIN code)',
                            hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.textSecondary),
                            labelText: 'Store address',
                            alignLabelWithHint: true,
                            prefixIcon: const Icon(Icons.location_on_outlined, color: AppTheme.primary, size: 22),
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
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                          style: GoogleFonts.plusJakartaSans(fontSize: 14),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: 'Store contact number (WhatsApp preferred)',
                            hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.textSecondary),
                            labelText: 'Contact number',
                            prefixIcon: const Icon(Icons.phone_outlined, color: AppTheme.primary, size: 20),
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
                          style: GoogleFonts.plusJakartaSans(fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total Sarees', style: GoogleFonts.plusJakartaSans(color: AppTheme.textSecondary)),
                          Text('${cart.totalSarees}', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total Amount', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
                          Text(
                            '\u20b9${cart.totalAmount.toStringAsFixed(0)}',
                            style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.primary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: cart.isPlacingOrder ? null : () => _placeOrder(context, isBroker),
                          child: cart.isPlacingOrder
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
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

  void _placeOrder(BuildContext context, bool isBroker) async {
    final cart = context.read<CartProvider>();
    // Validate store name for brokers
    if (isBroker && _storeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the store name before placing the order.'), backgroundColor: Colors.red),
      );
      return;
    }
    if (isBroker && _addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the store address for delivery.'), backgroundColor: Colors.red),
      );
      return;
    }
    if (isBroker && _phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the store contact number.'), backgroundColor: Colors.red),
      );
      return;
    }
    try {
      final order = await cart.placeOrder(
        storeName: isBroker ? _storeController.text.trim() : null,
        storeAddress: isBroker ? _addressController.text.trim() : null,
        storePhone: isBroker ? _phoneController.text.trim() : null,
      );
      if (order != null && context.mounted) {
        _storeController.clear();
        _addressController.clear();
        _phoneController.clear();
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
                    style: GoogleFonts.sourceSerif4(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text('Order #${order.id}', style: GoogleFonts.plusJakartaSans(color: AppTheme.accent)),
                Text('${order.totalSarees} sarees | \u20b9${order.totalAmount.toStringAsFixed(0)}',
                    style: GoogleFonts.plusJakartaSans(color: AppTheme.textSecondary)),
                if (order.storeName != null) ...
                  [
                    const SizedBox(height: 4),
                    Text('For: ${order.storeName}',
                        style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.primary, fontWeight: FontWeight.w600)),
                  ],
                const SizedBox(height: 8),
                Text('A confirmation email has been sent to you.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textSecondary)),
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
