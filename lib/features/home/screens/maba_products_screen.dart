import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';

class MabaProductsScreen extends StatefulWidget {
  const MabaProductsScreen({super.key});

  @override
  State<MabaProductsScreen> createState() => _MabaProductsScreenState();
}

class _MabaProductsScreenState extends State<MabaProductsScreen> {
  final ProductService _productService = ProductService();

  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = _productService.getMabaProducts();
  }

  String _formatPrice(double price) {
    final value = price.toInt().toString();

    final formatted = value.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );

    return 'Rp $formatted';
  }

  void _openProductDetail(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
    );
  }

  Future<void> _refreshProducts() async {
    final future = _productService.getMabaProducts();

    setState(() {
      _productsFuture = future;
    });

    await future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: AppColors.textPrimary,
          ),
        ),
        title: Text(
          'Musim Maba',
          style: AppTextStyles.subHeading.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            color: const Color(0xFFFFF5F4),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HAH! MUSIM MABA',
                  style: TextStyle(
                    color: Color(0xFFB52D43),
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Temukan berbagai kebutuhan kuliah dan perlengkapan mahasiswa baru di Reloved.',
                  style: TextStyle(
                    color: Color(0xFF8F3444),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              20,
              AppSpacing.md,
              12,
            ),
            child: Text(
              'Produk Pilihan untuk Mahasiswa Baru',
              style: AppTextStyles.title.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          Expanded(
            child: FutureBuilder<List<Product>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 42,
                            color: AppColors.danger,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Gagal memuat produk',
                            style: AppTextStyles.bodyMedium,
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: _refreshProducts,
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final products = snapshot.data ?? [];

                if (products.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: _refreshProducts,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 100),
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 60,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Text(
                            'Belum ada produk Musim Maba',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _refreshProducts,
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      4,
                      AppSpacing.md,
                      24,
                    ),
                    itemCount: products.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 0.72,
                        ),
                    itemBuilder: (context, index) {
                      final product = products[index];

                      return ProductCard(
                        product: ProductItem(
                          imageUrl: product.imageUrl,
                          name: product.name,
                          price: _formatPrice(product.price),
                          location: product.locationName,
                        ),
                        onTap: () {
                          _openProductDetail(product);
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
