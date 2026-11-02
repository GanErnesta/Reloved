
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../models/cart_item.dart';
import '../services/cart_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cartService = CartService();

  List<CartItem> _cartItems = [];
  final Set<String> _processingItems = {};

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final items = await _cartService.getCartItems();

      if (!mounted) return;

      setState(() {
        _cartItems = items;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'Gagal memuat keranjang';
      });

      debugPrint('ERROR LOAD CART: $e');
    }
  }

  double get _totalPrice {
    return _cartItems.fold(0, (total, item) {
      final unitPrice = item.isRent
          ? (item.product.rentalPrice ?? 0)
          : item.product.price;

      final duration = item.isRent
          ? (item.rentalDuration ?? 1)
          : 1;

      return total + (unitPrice * item.quantity * duration);
    });
  }

  int get _totalItems {
    return _cartItems.fold(
      0,
      (total, item) => total + item.quantity,
    );
  }

  String _formatPrice(double price) {
    final value = price.toInt().toString();

    final formatted = value.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );

    return 'Rp $formatted';
  }

  String _getRentalPeriodLabel(String? period) {
    switch (period) {
      case 'daily':
        return 'Hari';
      case 'weekly':
        return 'Minggu';
      case 'monthly':
        return 'Bulan';
      default:
        return 'Periode';
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.textPrimary,
        ),
      );
  }

  Future<void> _changeQuantity(
    CartItem item,
    int newQuantity,
  ) async {
    final minimum = item.product.minPurchase;
    final stock = item.product.stock;

    if (newQuantity < minimum || newQuantity > stock) {
      if (newQuantity > stock) {
        _showMessage('Jumlah melebihi stok yang tersedia');
      }
      return;
    }

    if (_processingItems.contains(item.id)) return;

    setState(() {
      _processingItems.add(item.id);
    });

    try {
      await _cartService.updateQuantity(
        item.id,
        newQuantity,
      );

      if (!mounted) return;

      setState(() {
        final index = _cartItems.indexWhere(
          (element) => element.id == item.id,
        );

        if (index != -1) {
          _cartItems[index] = item.copyWith(
            quantity: newQuantity,
          );
        }
      });
    } catch (e) {
      if (mounted) {
        _showMessage('Gagal memperbarui jumlah barang');
      }

      debugPrint('ERROR UPDATE CART: $e');
    } finally {
      if (mounted) {
        setState(() {
          _processingItems.remove(item.id);
        });
      }
    }
  }

  Future<void> _removeItem(CartItem item) async {
    if (_processingItems.contains(item.id)) return;

    setState(() {
      _processingItems.add(item.id);
    });

    try {
      await _cartService.removeFromCart(item.id);

      if (!mounted) return;

      setState(() {
        _cartItems.removeWhere(
          (element) => element.id == item.id,
        );
      });

      _showMessage('Produk berhasil dihapus dari keranjang');
    } catch (e) {
      if (mounted) {
        _showMessage('Gagal menghapus produk');
      }

      debugPrint('ERROR REMOVE CART: $e');
    } finally {
      if (mounted) {
        setState(() {
          _processingItems.remove(item.id);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Keranjang',
          style: AppTextStyles.title.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: _buildBody(),
      bottomNavigationBar: _cartItems.isEmpty || _isLoading
          ? null
          : _buildBottomSummary(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.danger,
              ),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loadCart,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (_cartItems.isEmpty) {
      return _buildEmptyCart();
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadCart,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Row(
            children: [
              Text(
                'Produk di Keranjang',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              Text(
                '$_totalItems barang',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ..._cartItems.map(_buildCartItem),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: const Color(0xFFF4E5E7),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                size: 55,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Keranjang Masih Kosong',
              style: AppTextStyles.title.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Yuk, temukan barang yang kamu butuhkan '
              'dan tambahkan ke keranjang!',
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(
                  color: AppColors.primary,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Mulai Belanja'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem(CartItem item) {
    final product = item.product;
    final isProcessing = _processingItems.contains(item.id);

    final unitPrice = item.isRent
        ? (product.rentalPrice ?? 0)
        : product.price;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              product.imageUrl,
              width: 88,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return Container(
                  width: 88,
                  height: 100,
                  color: AppColors.background,
                  child: const Icon(
                    Icons.image_outlined,
                    color: AppColors.textSecondary,
                    size: 32,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  product.categoryName,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  _formatPrice(unitPrice),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                if (item.isRent)
                  Text(
                    'Sewa • ${item.rentalDuration ?? 1} '
                    '${_getRentalPeriodLabel(item.rentalPeriod)}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  )
                else
                  Text(
                    'Jual',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                const SizedBox(height: 9),
                Row(
                  children: [
                    _buildQuantityButton(
                      icon: Icons.remove,
                      onPressed: item.quantity >
                                  product.minPurchase &&
                              !isProcessing
                          ? () => _changeQuantity(
                                item,
                                item.quantity - 1,
                              )
                          : null,
                    ),
                    SizedBox(
                      width: 30,
                      child: isProcessing
                          ? const SizedBox(
                              height: 15,
                              width: 15,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            )
                          : Text(
                              '${item.quantity}',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                    _buildQuantityButton(
                      icon: Icons.add,
                      onPressed: item.quantity < product.stock &&
                              !isProcessing
                          ? () => _changeQuantity(
                                item,
                                item.quantity + 1,
                              )
                          : null,
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: isProcessing
                          ? null
                          : () => _removeItem(item),
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppColors.danger,
                        size: 21,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                if (product.stock <= 0)
                  Text(
                    'Stok habis',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.danger,
                      fontSize: 10,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: 27,
      height: 27,
      child: IconButton(
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        iconSize: 16,
        constraints: const BoxConstraints(),
        icon: Icon(
          icon,
          color: onPressed == null
              ? AppColors.textSecondary
              : AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildBottomSummary() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  'Total ($_totalItems barang)',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatPrice(_totalPrice),
                  style: AppTextStyles.title.copyWith(
                    color: AppColors.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  _showMessage(
                    'Fitur checkout akan dihubungkan pada tahap transaksi.',
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Lanjutkan Transaksi',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
