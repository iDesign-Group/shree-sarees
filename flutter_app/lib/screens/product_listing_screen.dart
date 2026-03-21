import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import 'product_detail_screen.dart';

class ProductListingScreen extends StatefulWidget {
  const ProductListingScreen({super.key});

  @override
  State<ProductListingScreen> createState() => _ProductListingScreenState();
}

class _ProductListingScreenState extends State<ProductListingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final cartCount = context.watch<CartProvider>().itemCount;

    return Scaffold(
      appBar: AppBar(
        title: Text('Shree Sarees',
            style: GoogleFonts.sourceSerif4(
                fontSize: 20, fontWeight: FontWeight.w600)),
        actions: [
          Badge(
            isLabelVisible: cartCount > 0,
            label: Text('$cartCount',
                style: const TextStyle(fontSize: 10, color: Colors.white)),
            backgroundColor: AppTheme.accent,
            child: IconButton(
              icon: const Icon(LucideIcons.shoppingCart),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (q) => provider.setSearch(q),
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon:
                    const Icon(LucideIcons.search, color: AppTheme.textSecondary),
                filled: true,
                fillColor: AppTheme.surface,
              ),
            ),
          ),
          // Product Grid
          Expanded(
            child: provider.isLoading
                ? const Center(
                    child:
                        CircularProgressIndicator(color: AppTheme.accent))
                : provider.products.isEmpty
                    ? Center(
                        child: Text('No products found.',
                            style: GoogleFonts.plusJakartaSans(
                                color: AppTheme.textSecondary)))
                    : GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.65,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: provider.products.length,
                        itemBuilder: (ctx, i) =>
                            _ProductCard(product: provider.products[i]),
                      ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final imageUrl = product.images.isNotEmpty
        ? '${ApiService.baseUrl}/${product.images.first.imagePath}'
        : null;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailScreen(productId: product.id),
        ),
      ),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: AppTheme.background,
                            child: const Center(
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: AppTheme.accent),
                            ),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: AppTheme.background,
                            child: const Icon(LucideIcons.image,
                                color: AppTheme.border),
                          ),
                        )
                      : Container(
                          color: AppTheme.background,
                          child: const Icon(LucideIcons.image,
                              size: 40, color: AppTheme.border),
                        ),
                  // Code badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.accent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        product.productCode,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.productName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.sourceSerif4(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${product.bundlePrice.toStringAsFixed(0)}/bundle',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.background,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.accent, width: 1),
                      ),
                      child: Text(
                        '${product.setSize} per bundle',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
