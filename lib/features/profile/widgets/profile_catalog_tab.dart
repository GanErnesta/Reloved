
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';

import '../../home/models/product.dart';
import '../../home/services/product_service.dart';
import '../../home/widgets/product_card.dart';
import '../../home/screens/product_detail_screen.dart';

class ProfileCatalogTab extends StatefulWidget {
  final String? sellerId;

  const ProfileCatalogTab({
    super.key,
    this.sellerId,
  });

  @override
  State<ProfileCatalogTab> createState() => _ProfileCatalogTabState();
}

class _ProfileCatalogTabState extends State<ProfileCatalogTab> {
  final ProductService _service = ProductService();

  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    _productsFuture = widget.sellerId != null
        ? _service.getProductsBySellerId(widget.sellerId!)
        : _service.getMyProducts();
  }

  Future<void> _refresh() async {
    setState(_loadProducts);
    await _productsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Product>>(
      future: _productsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 44,
                    color: AppColors.danger,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Gagal memuat katalog',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _refresh,
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
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 70),
                Icon(
                  Icons.shopping_bag_outlined,
                  size: 58,
                  color: AppColors.textSecondary,
                ),
                SizedBox(height: 12),
                Center(
                  child: Text(
                    'Belum Ada Produk',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 6),
                Center(
                  child: Text(
                    'Produk yang tersedia akan muncul di sini.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _refresh,
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            physics: const AlwaysScrollableScrollPhysics(),
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
                  price: formatPrice(product.price),
                  location: product.locationName,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailScreen(
                        product: product,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
