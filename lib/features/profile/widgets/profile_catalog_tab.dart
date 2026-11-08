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

  final Set<String> _deletingProducts = {};

  bool get _canDelete => widget.sellerId == null;

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

  Future<bool> _showDeleteConfirmation(Product product) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Produk?'),
          content: Text(
            'Apakah kamu yakin ingin menghapus "${product.name}"? '
            'Produk ini juga akan dihapus dari katalog.',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text(
                'Batal',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    return result == true;
  }

  Future<void> _deleteProduct(Product product) async {
    final confirmed = await _showDeleteConfirmation(product);

    if (!confirmed || !mounted) return;

    setState(() {
      _deletingProducts.add(product.id);
    });

    try {
      await _service.deleteProduct(product.id);

      if (!mounted) return;

      setState(() {
        _deletingProducts.remove(product.id);
        _loadProducts();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Produk berhasil dihapus.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _deletingProducts.remove(product.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus produk: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildEmptyState() {
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
          return _buildEmptyState();
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
              final isDeleting = _deletingProducts.contains(product.id);

              return Stack(
                children: [
                  Positioned.fill(
                    child: ProductCard(
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
                    ),
                  ),

                  if (_canDelete)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Material(
                        color: Colors.white,
                        shape: const CircleBorder(),
                        elevation: 2,
                        child: isDeleting
                            ? const Padding(
                                padding: EdgeInsets.all(10),
                                child: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : PopupMenuButton<String>(
                                tooltip: 'Pilihan produk',
                                icon: const Icon(
                                  Icons.more_vert,
                                  color: AppColors.textPrimary,
                                  size: 21,
                                ),
                                onSelected: (value) {
                                  if (value == 'delete') {
                                    _deleteProduct(product);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.delete_outline,
                                          color: AppColors.danger,
                                          size: 20,
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          'Hapus Produk',
                                          style: TextStyle(
                                            color: AppColors.danger,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}