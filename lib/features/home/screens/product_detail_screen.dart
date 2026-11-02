import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../transaction/services/cart_service.dart';
import '../../transaction/widgets/transaction_confirmation_modal.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with TickerProviderStateMixin {
  final CartService _cartService = CartService();
  final ProductService _productService = ProductService();

  late Product _product;
  late AnimationController _cartAnimationController;

  final GlobalKey _productImageKey = GlobalKey();
  final GlobalKey _cartButtonKey = GlobalKey();

  bool _isAddingToCart = false;
  bool _isLoadingProduct = false;

  Product get product => _product;

  @override
  void initState() {
    super.initState();
    _product = widget.product;

    _cartAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );

    _refreshProduct();
  }

  @override
  void dispose() {
    _cartAnimationController.dispose();
    super.dispose();
  }

  Future<void> _playAddToCartAnimation() async {
    if (!mounted) return;

    final sourceContext = _productImageKey.currentContext;
    final targetContext = _cartButtonKey.currentContext;

    if (sourceContext == null || targetContext == null) return;

    final sourceObject = sourceContext.findRenderObject();
    final targetObject = targetContext.findRenderObject();

    if (sourceObject is! RenderBox || targetObject is! RenderBox) return;
    if (!sourceObject.hasSize || !targetObject.hasSize) return;

    final sourcePosition = sourceObject.localToGlobal(Offset.zero);
    final targetPosition = targetObject.localToGlobal(Offset.zero);

    final startRect = sourcePosition & sourceObject.size;
    final targetCenter = targetPosition + targetObject.size.center(Offset.zero);

    final endRect = Rect.fromCenter(
      center: targetCenter,
      width: 30,
      height: 34,
    );

    final overlay = Overlay.of(context);
    late final OverlayEntry entry;

    entry = OverlayEntry(
      builder: (overlayContext) {
        final progress = Curves.easeInOutCubic.transform(
          _cartAnimationController.value,
        );
        final currentRect = Rect.lerp(startRect, endRect, progress)!;
        final opacity = (1 - (progress * 0.15)).clamp(0.0, 1.0).toDouble();

        return Positioned.fromRect(
          rect: currentRect,
          child: IgnorePointer(
            child: Opacity(
              opacity: opacity,
              child: Material(
                color: Colors.transparent,
                elevation: 10,
                borderRadius: BorderRadius.circular(12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return Container(
                        color: AppColors.background,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.shopping_bag_outlined,
                          color: AppColors.primary,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    void updateOverlay() {
      entry.markNeedsBuild();
    }

    overlay.insert(entry);
    _cartAnimationController.addListener(updateOverlay);

    try {
      await _cartAnimationController.forward(from: 0);
    } finally {
      _cartAnimationController.removeListener(updateOverlay);
      entry.remove();
      _cartAnimationController.reset();
    }
  }

  Future<void> _saveCartSelection(Map<String, dynamic> data) async {
    final transactionType = data['transactionType'] as String;
    final quantity = data['quantity'] as int;

    try {
      final latestProduct = await _productService.getProductById(product.id);

      if (!mounted) return;

      setState(() {
        _product = latestProduct;
      });

      if (latestProduct.status != 'available') {
        _showMessage('Produk sudah tidak tersedia');
        return;
      }

      if (quantity < latestProduct.minPurchase ||
          quantity > latestProduct.stock) {
        _showMessage('Jumlah barang tidak sesuai dengan stok');
        return;
      }

      await _cartService.addToCart(
        latestProduct.id,
        transactionType: transactionType,
        quantity: quantity,
        rentalDuration: data['duration'] as int?,
        rentalPeriod: data['rentalPeriod'] as String?,
      );

      if (!mounted) return;

      await _playAddToCartAnimation();

      if (!mounted) return;

      _showMessage(
        transactionType == 'rent'
            ? '$quantity barang berhasil ditambahkan sebagai sewa'
            : '$quantity barang berhasil ditambahkan ke keranjang',
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage('Gagal menambahkan produk ke keranjang');

      debugPrint('ERROR SAVE CART: $e');
    }
  }

  Future<void> _refreshProduct() async {
    try {
      final latestProduct = await _productService.getProductById(
        widget.product.id,
      );

      if (!mounted) return;

      setState(() {
        _product = latestProduct;
      });
    } catch (e) {
      debugPrint('ERROR REFRESH PRODUCT: $e');
    }
  }

  Future<void> _addToCart() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      _showMessage('Silakan login terlebih dahulu');
      return;
    }

    if (_isAddingToCart) return;

    setState(() {
      _isAddingToCart = true;
    });

    try {
      final latestProduct = await _productService.getProductById(product.id);

      if (!mounted) return;

      setState(() {
        _product = latestProduct;
      });

      if (product.stock <= 0) {
        _showMessage('Stok produk sedang habis');
        return;
      }

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black.withValues(alpha: 0.45),
        enableDrag: true,
        isDismissible: true,
        builder: (sheetContext) {
          return TransactionConfirmationModal(
            product: product,
            initialMode: product.transactionType == 'rent'
                ? TransactionMode.rent
                : TransactionMode.sale,
            onConfirm: (data) {
              _saveCartSelection(data);
            },
          );
        },
      );
    } catch (e) {
      if (mounted) {
        _showMessage('Gagal mengambil data produk');
      }
      debugPrint('ERROR ADD TO CART: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isAddingToCart = false;
        });
      }
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

  Future<void> _showTransactionModal() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      _showMessage('Silakan login terlebih dahulu');
      return;
    }

    if (_isLoadingProduct) return;

    setState(() {
      _isLoadingProduct = true;
    });

    try {
      final latestProduct = await _productService.getProductById(
        widget.product.id,
      );

      if (!mounted) return;

      setState(() {
        _product = latestProduct;
      });

      if (product.stock <= 0) {
        _showMessage('Maaf, stok produk sedang habis');
        return;
      }

      if (product.transactionType == 'rent' &&
          (product.rentalPrice == null || product.rentalPrice! <= 0)) {
        _showMessage('Harga sewa produk belum tersedia');
        return;
      }

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black.withValues(alpha: 0.45),
        enableDrag: true,
        isDismissible: true,
        builder: (context) {
          return TransactionConfirmationModal(
            product: product,
            initialMode: product.transactionType == 'rent'
                ? TransactionMode.rent
                : TransactionMode.sale,
            onConfirm: (data) {
              final mode = data['transactionType'];
              final quantity = data['quantity'];
              final totalPrice = data['totalPrice'];

              _showMessage(
                mode == 'rent'
                    ? 'Konfirmasi sewa: $quantity barang, total ${formatPrice((totalPrice as num).toDouble())}'
                    : 'Konfirmasi pembelian: $quantity barang, total ${formatPrice((totalPrice as num).toDouble())}',
              );
            },
          );
        },
      );
    } catch (e) {
      if (mounted) {
        _showMessage('Gagal mengambil data produk terbaru');
      }

      debugPrint('ERROR SHOW TRANSACTION: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingProduct = false;
        });
      }
    }
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
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProductImage(),
                    const SizedBox(height: AppSpacing.md),
                    _buildProductInfo(),
                    const SizedBox(height: AppSpacing.md),
                    _buildSellerCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActionBar(),
    );
  }

  Widget _buildBottomActionBar() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              width: 42,
              height: 42,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor: const Color(0xFFF4E5E7),
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Icon(
                  Icons.chat_bubble_outline,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                key: _cartButtonKey,
                height: 42,
                child: OutlinedButton(
                  onPressed: _isAddingToCart ? null : _addToCart,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFFE8B7BE),
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isAddingToCart
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          '+ Keranjang',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 42,
                child: ElevatedButton(
                  onPressed: _isLoadingProduct ? null : _showTransactionModal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.primary.withValues(
                      alpha: 0.6,
                    ),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoadingProduct
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Beli',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      height: 58,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: AppSpacing.md),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.primary,
              size: 21,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Container(
        key: _productImageKey,
        width: double.infinity,
        height: 455,
        padding: const EdgeInsets.all(26),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(7),
          child: Image.network(
            product.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) {
              return Container(
                color: AppColors.background,
                child: const Icon(
                  Icons.image_outlined,
                  size: 48,
                  color: AppColors.textSecondary,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProductInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name,
            style: AppTextStyles.title.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            formatPrice(product.price),
            style: AppTextStyles.heading.copyWith(
              fontSize: 25,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildTag('Kondisi: ${product.condition}'),
              const SizedBox(width: 6),
              Flexible(child: _buildTag('Kategori: ${product.categoryName}')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on, color: AppColors.primary, size: 17),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Lokasi COD: Area ${product.locationName} / Kampus UB',
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            product.description.isEmpty
                ? 'Belum ada deskripsi produk.'
                : product.description,
            style: AppTextStyles.caption.copyWith(
              fontSize: 11,
              height: 1.35,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.textSecondary.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          color: Colors.white,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildSellerCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFFF1DE),
              ),
              child: const Icon(
                Icons.person,
                color: Color(0xFFE8C995),
                size: 25,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    product.sellerName.isEmpty
                        ? 'Pengguna Reloved'
                        : product.sellerName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium.copyWith(fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.sellerFaculty.isEmpty
                        ? product.sellerCampus
                        : product.sellerFaculty,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.success,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 76,
              height: 32,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                child: Text(
                  'Chat',
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
