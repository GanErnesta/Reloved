import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/order_model.dart';
import 'cancel_order_dialogs.dart';
import 'order_action_buttons.dart';
import 'order_item_row.dart';
import 'order_status_badge.dart';
import 'rental_info_badge.dart';

class OrderCard extends StatefulWidget {
  final OrderModel order;
  final bool showStatusBadge;
  final VoidCallback? onCardTap;
  final VoidCallback onShopTap;
  final VoidCallback onCancelConfirmed;
  final VoidCallback onReorderTap;

  const OrderCard({
    super.key,
    required this.order,
    this.showStatusBadge = true,
    this.onCardTap,
    required this.onShopTap,
    required this.onCancelConfirmed,
    required this.onReorderTap,
  });

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  bool _isExpanded = false;

  String _formatRupiah(int amount) {
    final str = amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
    );
    return 'Rp$str';
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final bool hasMultipleItems = order.items.length > 1;
    final bool showStackedPhoto = hasMultipleItems && !_isExpanded;
    final List<OrderItemModel> displayedItems =
    _isExpanded ? order.items : [order.items.first];

    return GestureDetector(
      onTap: widget.onCardTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Kartu: Nama Toko + '>' (Kiri) & Status Badge (Kanan - Opsional)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: widget.onShopTap,
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          order.shopName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 20,
                          color: AppColors.textPrimary,
                        ),
                      ],
                    ),
                  ),
                ),
                if (widget.showStatusBadge)
                  OrderStatusBadge(status: order.status),
              ],
            ),
            const SizedBox(height: 14),

            // 2. Daftar Item Produk (1 item dengan efek menumpuk jika collapsed, semua item jika expanded)
            ...List.generate(displayedItems.length, (index) {
              final item = displayedItems[index];
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < displayedItems.length - 1 ? 12 : 0,
                ),
                child: OrderItemRow(
                  item: item,
                  showStackEffect: index == 0 && showStackedPhoto,
                  formatCurrency: _formatRupiah,
                ),
              );
            }),

            const SizedBox(height: 10),

            // 3. Informasi Sewa (Khusus Sewa) & Total Harga (Sesuai Referensi)
            Align(
              alignment: Alignment.centerRight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (order.orderType == OrderType.sewa &&
                      order.rentalDurationDays != null &&
                      order.rentalRemainingText != null) ...[
                    RentalInfoBadge(
                      durationDays: order.rentalDurationDays!,
                      remainingText: order.rentalRemainingText!,
                    ),
                    const SizedBox(height: 6),
                  ],
                  Text(
                    'Total: ${_formatRupiah(order.totalProductPrice)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // 4. Tombol Dropdown "More" jika terdapat lebih dari 1 item
            if (hasMultipleItems) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 34,
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isExpanded ? 'Less' : 'More',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 14),

            // 5. Tombol Aksi: Batalkan & Pesan Lagi
            OrderActionButtons(
              status: order.status,
              onCancelPressed: () {
                CancelOrderDialogs.showConfirmCancelDialog(
                  context,
                  onConfirmCancel: widget.onCancelConfirmed,
                );
              },
              onReorderPressed: widget.onReorderTap,
            ),
          ],
        ),
      ),
    );
  }
}