import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/order_controller.dart';
import '../models/order_model.dart';
import '../widgets/order_card.dart';
import '../widgets/order_date_info_card.dart';
import '../widgets/order_location_card.dart';
import '../widgets/order_payment_card.dart';
import '../widgets/order_status_header_card.dart';
import '../widgets/safe_meeting_point_sheet.dart';

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
    final bool isWaiting = order.status == OrderStatus.menunggu;

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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Membuka ruang chat ${order.shopName}...'),
                  ),
                );
              },
            ),

            // 2. Kartu Produk (Tanpa badge status kecil)
            OrderCard(
              order: order,
              showStatusBadge: false,
              onShopTap: () {},
              onCancelConfirmed: () {
                widget.orderController.cancelOrder(order.id);
                Navigator.of(context).pop();
              },
              onReorderTap: () {},
            ),

            // 3. Kartu Detail Tanggal
            OrderDateInfoCard(order: order),

            // 4. Kartu Lokasi (Safe Meeting Point bisa diubah jika status == menunggu)
            OrderLocationCard(
              pickupAddress: order.pickupAddress,
              safeMeetingPoint: order.safeMeetingPoint,
              buyerAccountInfo: order.buyerAccountInfo,
              canEditMeetingPoint: isWaiting,
              onTapMeetingPoint: () async {
                final selected = await SafeMeetingPointSheet.show(
                  context,
                  currentSelection: order.safeMeetingPoint,
                );
                if (selected != null) {
                  widget.orderController.updateSafeMeetingPoint(
                    order.id,
                    selected,
                  );
                }
              },
            ),

            // 5. Kartu Rincian Pembayaran (Fix, tanpa '>')
            OrderPaymentCard(
              productSubtotal: order.productSubtotal,
              shippingFee: order.shippingFee,
              discount: order.discount,
              paymentMethod: order.paymentMethod,
              isEditable: false,
            ),
          ],
        ),
      ),
    );
  }
}