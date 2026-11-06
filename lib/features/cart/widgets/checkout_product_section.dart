import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../orders/models/order_model.dart';
import '../models/cart_model.dart';

class CheckoutProductSection extends StatelessWidget {
  final String headerTitle; // "Beli" atau "Sewa"
  final List<CartItemModel> items;

  const CheckoutProductSection({
    super.key,
    required this.headerTitle,
    required this.items,
  });

  String _formatRupiah(int amount) {
    final str = amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
    );
    return 'Rp $str';
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            headerTitle,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(items.length, (index) {
            final item = items[index];
            final bool isSewa = item.type == OrderType.sewa;

            return Padding(
              padding: EdgeInsets.only(
                bottom: index < items.length - 1 ? 12 : 0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 74,
                      height: 74,
                      color: AppColors.primaryLight,
                      child: Image.asset(
                        item.imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.checkroom_rounded,
                          color: AppColors.primary,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isSewa
                              ? '${item.selectedRentalDays} hari, ${item.quantity} pcs'
                              : '${item.quantity} pcs · ${item.subtitleInfo}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatRupiah(item.subtotalPrice),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}