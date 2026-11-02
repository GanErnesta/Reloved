import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../orders/models/order_model.dart';
import '../../orders/models/safe_meeting_point_model.dart';
import '../../orders/widgets/order_location_card.dart';
import '../../orders/widgets/order_payment_card.dart';
import '../../orders/widgets/safe_meeting_point_sheet.dart';
import '../controllers/cart_controller.dart';
import '../models/cart_model.dart';
import '../widgets/checkout_product_section.dart';
import 'payment_method_screen.dart';
import 'payment_waiting_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartItemModel> selectedItems;

  const CheckoutScreen({
    super.key,
    required this.selectedItems,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  SafeMeetingPointModel _selectedMeetingPoint =
      SafeMeetingPointModel.campusPoints.first;

  // Default kosong (belum ada metode pembayaran yang dipilih)
  String? _selectedPaymentMethod;

  int get _productSubtotal =>
      widget.selectedItems.fold(0, (sum, item) => sum + item.subtotalPrice);

  @override
  Widget build(BuildContext context) {
    final beliItems = widget.selectedItems
        .where((i) => i.type == OrderType.beli)
        .toList();
    final sewaItems = widget.selectedItems
        .where((i) => i.type == OrderType.sewa)
        .toList();

    final bool canPay =
        _selectedPaymentMethod != null && _selectedPaymentMethod!.isNotEmpty;

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
        title: const Text(
          'Rincian Pembayaran',
          style: TextStyle(
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
            // 1. Paling Atas: Alamat Diambil dari & Diantar ke (Safe Meeting Point)
            OrderLocationCard(
              pickupAddress: widget.selectedItems.first.sellerPickupAddress,
              safeMeetingPoint: _selectedMeetingPoint,
              buyerAccountInfo:
              'falishakeyrani - falishakeyrani@student.ub.ac.id',
              canEditMeetingPoint: true,
              onTapMeetingPoint: () async {
                final picked = await SafeMeetingPointSheet.show(
                  context,
                  currentSelection: _selectedMeetingPoint,
                );
                if (picked != null) {
                  setState(() {
                    _selectedMeetingPoint = picked;
                  });
                }
              },
            ),

            // 2. Tengah: Card Produk dipisah Headernya (Beli & Sewa)
            if (beliItems.isNotEmpty)
              CheckoutProductSection(
                headerTitle: 'Beli',
                items: beliItems,
              ),
            if (sewaItems.isNotEmpty)
              CheckoutProductSection(
                headerTitle: 'Sewa',
                items: sewaItems,
              ),

            // 3. Bawah: Rincian Pembayaran (Default kosong, wajib dipilih terlebih dahulu)
            OrderPaymentCard(
              productSubtotal: _productSubtotal,
              shippingFee: 5000,
              discount: 0,
              paymentMethod: _selectedPaymentMethod,
              isEditable: true,
              onPaymentMethodTap: () async {
                final newMethod = await Navigator.of(context).push<String?>(
                  MaterialPageRoute(
                    builder: (_) => PaymentMethodScreen(
                      initialMethod: _selectedPaymentMethod,
                    ),
                  ),
                );
                if (newMethod != null) {
                  setState(() {
                    _selectedPaymentMethod = newMethod;
                  });
                }
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: canPay
                  ? () {
                CartController.instance.startPaymentSession(
                  itemsToCheckout: widget.selectedItems,
                  safeMeetingPoint: _selectedMeetingPoint,
                  paymentMethod: _selectedPaymentMethod!,
                );

                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => const PaymentWaitingScreen(),
                  ),
                );
              }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.disabledBg,
                foregroundColor: Colors.white,
                disabledForegroundColor: AppColors.disabledText,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text(
                'Bayar Sekarang',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}