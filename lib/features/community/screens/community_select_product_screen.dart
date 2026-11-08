import 'package:flutter/material.dart';
import '../../home/widgets/community_image.dart';
import '../models/community_post_model.dart';
import '../repositories/community_repository.dart';
import '../widgets/community_back_button.dart';
import '../widgets/community_search_loading.dart';

class CommunitySelectProductScreen extends StatefulWidget {
  const CommunitySelectProductScreen({super.key});

  @override
  State<CommunitySelectProductScreen> createState() =>
      _CommunitySelectProductScreenState();
}

class _CommunitySelectProductScreenState
    extends State<CommunitySelectProductScreen> {
  final CommunityRepository _repository = CommunityRepository();
  UserProductModel? _selectedProduct;
  List<UserProductModel> _myProducts = [];
  bool _isLoading = true;

  static const Color _primaryMaroon = Color(0xFF9B2335);

  @override
  void initState() {
    super.initState();
    _fetchMyProducts();
  }

  Future<void> _fetchMyProducts() async {
    setState(() => _isLoading = true);
    try {
      final products = await _repository.getMyCatalogProducts();
      if (mounted) {
        setState(() {
          _myProducts = products;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final int availableCount = _myProducts.where((p) => !p.isSold).length;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Row(
                children: [
                  const CommunityBackButton(),
                  const SizedBox(width: 16),
                  const Text(
                    'Cantumkan Produk',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text(
                'Barang Saya ($availableCount tersedia)',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF4A4A4A),
                ),
              ),
            ),
            // Grid Produk
            Expanded(
              child: _isLoading
                  ? const CommunitySearchLoading(message: 'Memuat katalog...')
                  : _myProducts.isEmpty
                  ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Kamu belum memiliki produk di katalog.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF757575)),
                  ),
                ),
              )
                  : GridView.builder(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.72,
                ),
                itemCount: _myProducts.length,
                itemBuilder: (context, index) {
                  final product = _myProducts[index];
                  final isSelected =
                      _selectedProduct?.id == product.id;

                  return GestureDetector(
                    onTap: product.isSold
                        ? null
                        : () {
                      setState(() {
                        _selectedProduct =
                        isSelected ? null : product;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? _primaryMaroon
                              : const Color(0xFFF0F0F0),
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                            Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                CommunityImage(
                                  path: product.imageAsset,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      Container(
                                        color: const Color(0xFFEEEEEE),
                                        child: const Icon(
                                          Icons.image_outlined,
                                          color: Colors.grey,
                                        ),
                                      ),
                                ),
                                Positioned(
                                  top: 8,
                                  left: 8,
                                  child: Container(
                                    padding:
                                    const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: product.condition ==
                                          'Bekas Baik'
                                          ? const Color(0xFFD4E5D4)
                                          : product.condition ==
                                          'Baru'
                                          ? const Color(
                                          0xFFD4E0F0)
                                          : const Color(
                                          0xFFF3E5D8),
                                      borderRadius:
                                      BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      product.condition,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: product.condition ==
                                            'Bekas Baik'
                                            ? const Color(0xFF2E632E)
                                            : product.condition ==
                                            'Baru'
                                            ? const Color(
                                            0xFF2B4D7E)
                                            : const Color(
                                            0xFF8B5A2B),
                                      ),
                                    ),
                                  ),
                                ),
                                if (product.isSold)
                                  Container(
                                    color: Colors.black
                                        .withValues(alpha: 0.5),
                                    alignment: Alignment.center,
                                    child: Container(
                                      padding:
                                      const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black
                                            .withValues(alpha: 0.6),
                                        borderRadius:
                                        BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'TERJUAL',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    height: 1.3,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF1E1E1E),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  product.price,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: _primaryMaroon,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _selectedProduct == null
                ? null
                : () {
              Navigator.of(context).pop(_selectedProduct);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryMaroon,
              disabledBackgroundColor: const Color(0xFFDCA9AF),
              foregroundColor: Colors.white,
              disabledForegroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: Text(
              _selectedProduct == null ? 'Tambahkan (0)' : 'Tambahkan (1)',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}