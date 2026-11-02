import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../orders/models/order_model.dart';
import '../controllers/cart_controller.dart';
import '../widgets/cart_bottom_bar.dart';
import '../widgets/cart_shop_card.dart';
import 'checkout_screen.dart';
import 'payment_waiting_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final CartController _cartController = CartController.instance;

  OrderType? get _currentFilterType {
    if (_tabController.index == 1) return OrderType.beli;
    if (_tabController.index == 2) return OrderType.sewa;
    return null; // Tab Semua
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    _cartController.addListener(_onCartUpdated);

    // Jika masih ada pembayaran yang menggantung, langsung pindahkan ke layar Pembayaran
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPendingPaymentRedirect();
    });
  }

  void _checkPendingPaymentRedirect() {
    if (_cartController.hasPendingPayment && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const PaymentWaitingScreen()),
      );
    }
  }

  void _onCartUpdated() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _cartController.removeListener(_onCartUpdated);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filterType = _currentFilterType;
    final bool isAllSelected = _cartController.isAllSelectedInTab(filterType);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          child: InkWell(
            onTap: () => Navigator.of(context).maybePop(),
            borderRadius: BorderRadius.circular(24),
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chevron_left_rounded,
                color: AppColors.textPrimary,
                size: 26,
              ),
            ),
          ),
        ),
        title: const Text(
          'Keranjang',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.textPrimary,
          unselectedLabelColor: AppColors.textPrimary,
          labelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          indicatorColor: AppColors.primary,
          indicatorWeight: 3.5,
          tabs: const [
            Tab(text: 'Semua'),
            Tab(text: 'Beli'),
            Tab(text: 'Sewa'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Baris "Pilih semua produk"
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                InkWell(
                  onTap: () => _cartController.toggleSelectAll(
                    filterType,
                    !isAllSelected,
                  ),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: isAllSelected ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isAllSelected
                            ? AppColors.primary
                            : const Color(0xFFD0C4C4),
                        width: 1.5,
                      ),
                    ),
                    child: isAllSelected
                        ? const Icon(Icons.check, size: 15, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Pilih semua produk',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          // Daftar Card Per Toko
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildShopGroupList(null),
                _buildShopGroupList(OrderType.beli),
                _buildShopGroupList(OrderType.sewa),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CartBottomBar(
        totalAmount: _cartController.getSelectedTotalAmount(filterType),
        selectedCount: _cartController.getSelectedCount(filterType),
        onCheckoutPressed: () {
          final selectedItems = _cartController.getSelectedItems(filterType);
          if (selectedItems.isEmpty) return;

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CheckoutScreen(selectedItems: selectedItems),
            ),
          );
        },
      ),
    );
  }

  Widget _buildShopGroupList(OrderType? filterType) {
    final groups = _cartController.getShopGroups(filterType);
    if (groups.isEmpty) {
      return const Center(
        child: Text(
          'Keranjang masih kosong.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        return CartShopCard(
          shopGroup: group,
          onShopCheckChanged: (val) => _cartController.toggleShopSelection(
            group.shopId,
            filterType,
            val,
          ),
          onShopHeaderTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Menuju toko ${group.shopName}...')),
            );
          },
          onItemCheckChanged: (itemId, val) =>
              _cartController.toggleItemSelection(itemId, val),
          onItemDelete: (itemId) => _cartController.removeItem(itemId),
          onItemQuantityDelta: (itemId, delta) =>
              _cartController.updateQuantity(itemId, delta),
          onItemRentalDurationChanged: (itemId, days) =>
              _cartController.updateRentalDuration(itemId, days),
        );
      },
    );
  }
}