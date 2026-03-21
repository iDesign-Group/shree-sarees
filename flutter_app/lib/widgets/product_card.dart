import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = product.images.isNotEmpty;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image / Placeholder
            AspectRatio(
              aspectRatio: 1,
              child: hasImage
                  ? Image.network(
                      '${ApiService.baseUrl}/${product.images.first.imagePath}',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.productCode,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.accent,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.productName,
                    style: GoogleFonts.sourceSerif4(fontSize: 14, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '₹${product.pricePerSaree.toStringAsFixed(0)}/pc',
                        style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.primary),
                      ),
                      const Spacer(),
                      Text(
                        'Set of ${product.setSize}',
                        style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                  if (product.totalBundles != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${product.totalBundles} bundles in stock',
                      style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.textSecondary),
                    ),
                  ],
                ],
              ),
            ),
            if (onAddToCart != null)
              InkWell(
                onTap: onAddToCart,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(LucideIcons.shoppingBag, size: 14, color: AppTheme.primary),
                      const SizedBox(width: 6),
                      Text('Add to Cart', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primary)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
        color: const Color(0xFFF3F4F6),
        child: const Center(child: Icon(LucideIcons.image, size: 40, color: Color(0xFFD1D5DB))),
      );
}
