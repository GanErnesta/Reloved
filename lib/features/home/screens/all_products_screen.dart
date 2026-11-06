import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';


class AllProductsScreen extends StatefulWidget {
  const AllProductsScreen({super.key});

  @override
  State<AllProductsScreen> createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends State<AllProductsScreen> {
  final ProductService _productService = ProductService();

  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = _productService.getLatestProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.lg,
                ),
                child: Column(
                  children: [
                    _buildPromoBanner(),
                    const SizedBox(height: AppSpacing.md),
                    _buildProductGrid(),
                    const SizedBox(height: AppSpacing.md),
                    _buildInformationText(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, 8, AppSpacing.md, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const SizedBox(
              width: 36,
              height: 36,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: AppColors.primary,
                  size: 21,
                ),
              ),
            ),
          ),
          const Spacer(),
          Row(
            children: [
              const Icon(Icons.location_on, color: AppColors.primary, size: 18),
              const SizedBox(width: 4),
              Text(
                'Lowokwaru',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Agustus - September',
            style: AppTextStyles.caption.copyWith(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Musim Maba & Ospek Universitas Brawijaya',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    return FutureBuilder<List<Product>>(
      future: _productsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 60),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 60),
            child: Center(
              child: Text(
                'Gagal memuat produk',
                style: AppTextStyles.caption.copyWith(color: AppColors.danger),
              ),
            ),
          );
        }

        final products = snapshot.data ?? [];

        if (products.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 60),
            child: Center(
              child: Text(
                'Belum ada produk',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: products.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 18,
            childAspectRatio: 0.72,
          ),
          itemBuilder: (context, index) {
            final product = products[index];

            return ProductCard(
              product: ProductItem(
                imageUrl: product.imageUrl,
                name: product.name,
                price: formatPrice(product.price),
                location: product.locationName,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailScreen(product: product),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildInformationText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: 'Barang yang kamu cari habis? ',
              style: AppTextStyles.caption.copyWith(fontSize: 10, height: 1.4),
            ),
            TextSpan(
              text: 'Ketuk di sini',
              style: AppTextStyles.caption.copyWith(
                fontSize: 10,
                height: 1.4,
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.underline,
              ),
            ),
            TextSpan(
              text:
                  ' untuk panduan pengadaan resmi atribut di Koperasi Mahasiswa (Kopma) UB.',
              style: AppTextStyles.caption.copyWith(fontSize: 10, height: 1.4),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

String formatPrice(double price) {
  final value = price.toInt().toString();
  final formatted = value.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => '.',
  );

  return 'Rp $formatted';
}
