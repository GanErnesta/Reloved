import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/order_controller.dart';
import '../models/order_model.dart';
import '../widgets/order_card.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final OrderController _orderController = OrderController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _orderController.addListener(_onOrdersUpdated);
  }

  void _onOrdersUpdated() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _orderController.removeListener(_onOrdersUpdated);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          'Pesanan Saya',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textPrimary,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Beli'),
            Tab(text: 'Sewa'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrderList(OrderType.beli),
          _buildOrderList(OrderType.sewa),
        ],
      ),
    );
  }

  Widget _buildOrderList(OrderType type) {
    final orders = _orderController.getOrdersByType(type);

    if (orders.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada pesanan.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    // Langsung menampilkan daftar kartu tanpa tulisan "Hari ini"
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return OrderCard(
          order: order,
          showStatusBadge: true,
          onCardTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => OrderDetailScreen(
                  order: order,
                  orderController: _orderController,
                ),
              ),
            );
          },
          onShopTap: () {
            // Navigasi ke halaman toko
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Menuju toko ${order.shopName}...')),
            );
          },
          onCancelConfirmed: () {
            _orderController.cancelOrder(order.id);
          },
          onReorderTap: () {
            // Navigasi pesan ulang / checkout ulang
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Memproses pesan lagi...')),
            );
          },
        );
      },
    );
  }
}