import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import 'product_card.dart';
import '../screens/product_detail_screen.dart';

class ProductSection extends StatelessWidget {
  final VoidCallback onSeeAll;

  const ProductSection({super.key, required this.onSeeAll});

  static const List<ProductItem> products = [
    ProductItem(
      imageUrl:
          'https://images.unsplash.com/photo-1551488831-00ddcb6c6bd3?w=600',
      name: 'Jas Almamater UB Size L',
      price: 'Rp 120.000',
      location: 'Sumbersari',
    ),
    ProductItem(
      imageUrl:
          'https://images.unsplash.com/photo-1603252110481-7ba873bf42ab?w=600',
      name: 'Kemeja Putih',
      price: 'Rp 49.900',
      location: 'Ketawanggede',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Produk Terbaru',
            style: AppTextStyles.title.copyWith(fontSize: 16),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 246,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              separatorBuilder: (_, __) {
                return const SizedBox(width: 12);
              },
              itemBuilder: (context, index) {
                return ProductCard(
                  product: products[index],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ProductDetailScreen(product: products[index]),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: onSeeAll,
              child: Text(
                'Lihat Semua',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
