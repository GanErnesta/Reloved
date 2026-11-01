import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../sell/screens/sell_screen.dart';
import '../controllers/seller_order_controller.dart';
import '../models/seller_order_model.dart';
import '../widgets/seller_filter_chips.dart';
import '../widgets/seller_mode_selector.dart';
import '../widgets/seller_order_card.dart';

class SellerManageOrdersScreen extends StatefulWidget {
  final VoidCallback? onAddCatalogTap;

  const SellerManageOrdersScreen({
    super.key,
    this.onAddCatalogTap,
  });

  @override
  State<SellerManageOrdersScreen> createState() =>
      _SellerManageOrdersScreenState();
}

class _SellerManageOrdersScreenState extends State<SellerManageOrdersScreen> {
  final SellerOrderController _controller = SellerOrderController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentMode = _controller.currentMode;
    final salePendingCount =
    _controller.getPendingCountByMode(SellerOrderMode.penjualan);
    final rentalPendingCount =
    _controller.getPendingCountByMode(SellerOrderMode.penyewaan);
    final activePendingCount = currentMode == SellerOrderMode.penjualan
        ? salePendingCount
        : rentalPendingCount;
    final orders = _controller.filteredOrders;

    return Scaffold(
      backgroundColor: const Color(0xFFFCFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCFAFA),
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
          'Kelola Pesanan',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          // Bagian Atas: Pemilih Mode + Filter Chips
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              children: [
                SellerModeSelector(
                  currentMode: currentMode,
                  salePendingCount: salePendingCount,
                  rentalPendingCount: rentalPendingCount,
                  onModeSelected: (mode) => _controller.switchMode(mode),
                ),
                const SizedBox(height: 12),
                SellerFilterChips(
                  mode: currentMode,
                  selectedIndex: _controller.selectedFilterIndex,
                  pendingCount: activePendingCount,
                  onSelected: (index) => _controller.selectFilter(index),
                ),
              ],
            ),
          ),

          // Daftar Kartu Pesanan Seller
          Expanded(
            child: orders.isEmpty
                ? const Center(
              child: Text(
                'Tidak ada pesanan pada kategori ini.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return SellerOrderCard(
                  order: order,
                  onAccept: () => _controller.acceptOrder(order.id),
                  onReject: () => _controller.rejectOrder(order.id),
                  onMarkSaleCompleted: () =>
                      _controller.markSaleCompleted(order.id),
                  onVerifyRentalReturn: () =>
                      _controller.verifyRentalReturn(order.id),
                );
              },
            ),
          ),
        ],
      ),

      // Tombol '+' Lingkaran Merah Floating -> Menuju Menu Tambah Katalog
      floatingActionButton: SizedBox(
        width: 64,
        height: 64,
        child: FloatingActionButton(
          onPressed: () {
            if (widget.onAddCatalogTap != null) {
              widget.onAddCatalogTap!();
              return;
            }
            // Navigasi default ke halaman Tambah Katalog / SellScreen
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SellScreen()),
            );
          },
          backgroundColor: AppColors.primary,
          elevation: 4,
          shape: const CircleBorder(),
          child: const Icon(
            Icons.add_rounded,
            color: Colors.white,
            size: 38,
          ),
        ),
      ),
    );
  }
}