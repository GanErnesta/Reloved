import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/order_controller.dart';
import '../models/order_model.dart';
import '../widgets/order_card.dart';
import '../widgets/order_date_info_card.dart';
import '../widgets/order_location_card.dart';
import '../widgets/order_payment_card.dart';
import '../widgets/order_status_header_card.dart';

class OrderDetailScreen extends StatefulWidget {
  final OrderModel order;
  final OrderController orderController;

  const OrderDetailScreen({
    super.key,
    required this.order,
    required this.orderController,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    widget.orderController.addListener(_onUpdate);
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.orderController.removeListener(_onUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final bool isSewa = order.orderType == OrderType.sewa;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          child: InkWell(
            onTap: () => Navigator.of(context).pop(),
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
        title: Text(
          isSewa ? 'Detail Sewa' : 'Detail Pesanan',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 1. Kartu Header Status (4 Tahap + 1 Baris Chat Toko)
            OrderStatusHeaderCard(
              status: order.status,
              shopName: order.shopName,
              shopAvatarPath: order.shopAvatarPath,
              onChatTap: () {
                // Navigasi ke ChatRoomScreen dengan toko
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Membuka ruang chat ${order.shopName}...'),
                  ),
                );
              },
            ),

            // 2. Kartu Produk (Tanpa badge status kecil agar tidak berulang)
            OrderCard(
              order: order,
              showStatusBadge: false,
              onShopTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Menuju toko ${order.shopName}...')),
                );
              },
              onCancelConfirmed: () {
                widget.orderController.cancelOrder(order.id);
                Navigator.of(context).pop();
              },
              onReorderTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Memproses pesan lagi...')),
                );
              },
            ),

            // 3. Kartu Detail Tanggal Pemesanan, Penerimaan & Pengembalian Sewa
            OrderDateInfoCard(order: order),

            // 4. Kartu Lokasi Diambil dari & Diantar ke (Hanya bisa diklik saat Menunggu)
            OrderLocationCard(
              order: order,
              onChangeDeliveryAddressTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Membuka halaman ubah alamat pengantaran...'),
                  ),
                );
              },
            ),

            // 5. Kartu Rincian Pembayaran (Metode pembayaran hanya bisa diklik saat Menunggu)
            OrderPaymentCard(
              order: order,
              onChangePaymentMethodTap: () {
                _showPaymentMethodPicker(context, order);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Contoh bottom sheet pemilihan metode pembayaran (Slot integrasi Midtrans)
  void _showPaymentMethodPicker(BuildContext context, OrderModel order) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final methods = ['QRIS', 'GoPay (Midtrans)', 'Virtual Account BCA'];
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pilih Metode Pembayaran',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                ...methods.map(
                      (method) => ListTile(
                    title: Text(method),
                    trailing: order.paymentMethod == method
                        ? const Icon(Icons.check, color: AppColors.primary)
                        : null,
                    onTap: () {
                      widget.orderController.changePaymentMethod(
                        order.id,
                        method,
                      );
                      Navigator.of(ctx).pop();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}