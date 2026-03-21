import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Product? _product;
  int _bundles = 1;
  int _currentImage = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    try {
      final p = await ApiService.getProduct(widget.productId);
      setState(() {
        _product = p;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppTheme.accent)),
      );
    }

    if (_product == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Product not found')),
      );
    }

    final p = _product!;
    final totalSarees = _bundles * p.setSize;

    return Scaffold(
      appBar: AppBar(title: Text(p.productName)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Carousel
            if (p.images.isNotEmpty)
              CarouselSlider(
                options: CarouselOptions(
                  height: 300,
                  viewportFraction: 1.0,
                  onPageChanged: (i, _) =>
                      setState(() => _currentImage = i),
                ),
                items: p.images.map((img) {
                  return CachedNetworkImage(
                    imageUrl: '${ApiService.baseUrl}/${img.imagePath}',
                    fit: BoxFit.cover,
                    width: double.infinity,
                  );
                }).toList(),
              )
            else
              Container(
                height: 300,
                color: AppTheme.background,
                child: const Center(
                  child: Icon(Icons.image, size: 64, color: AppTheme.border),
                ),
              ),

            // Dot indicators
            if (p.images.length > 1)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: p.images.asMap().entries.map((e) {
                    return Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentImage == e.key
                            ? AppTheme.accent
                            : AppTheme.border,
                      ),
                    );
                  }).toList(),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Code badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.accent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(p.productCode,
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary)),
                  ),
                  const SizedBox(height: 12),

                  // Name
                  Text(p.productName,
                      style: GoogleFonts.sourceSerif4(
                          fontSize: 22, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),

                  // Prices
                  Row(
                    children: [
                      Text('₹${p.pricePerSaree.toStringAsFixed(0)} per saree',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 14, color: AppTheme.textSecondary)),
                      const SizedBox(width: 16),
                      Text(
                          '₹${p.bundlePrice.toStringAsFixed(0)} per bundle',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primary)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Set info chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.accent),
                    ),
                    child: Text('${p.setSize} Sarees per Bundle',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primary)),
                  ),
                  const SizedBox(height: 24),

                  // Bundle stepper
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _StepperButton(
                        icon: Icons.remove,
                        onTap: () {
                          if (_bundles > 1) setState(() => _bundles--);
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text('$_bundles',
                            style: GoogleFonts.sourceSerif4(
                                fontSize: 20, fontWeight: FontWeight.w700)),
                      ),
                      _StepperButton(
                        icon: Icons.add,
                        onTap: () => setState(() => _bundles++),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text('Total Sarees: $totalSarees',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primary)),
                  ),
                  const SizedBox(height: 24),

                  // Add to Cart
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        context
                            .read<CartProvider>()
                            .addToCart(p, _bundles);
                        Fluttertoast.showToast(
                          msg: 'Added $_bundles bundle(s) to cart',
                          backgroundColor: AppTheme.success,
                        );
                      },
                      child: const Text('Add to Cart'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _StepperButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppTheme.accent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppTheme.textPrimary),
      ),
    );
  }
}
