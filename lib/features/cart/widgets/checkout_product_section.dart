import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../orders/models/order_model.dart';
import '../models/cart_model.dart';

class CheckoutProductSection extends StatelessWidget {
  final String headerTitle;
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

  Widget _buildProductImage(String path) {
    final cleanPath = path.trim();
    final isNetwork = cleanPath.startsWith('http://') ||
        cleanPath.startsWith('https://');

    Widget fallbackWidget() {
      return Container(
        color: AppColors.primaryLight,
        alignment: Alignment.center,
        child: const Icon(
          Icons.checkroom_rounded,
          color: AppColors.primary,
          size: 28,
        ),
      );
    }

    if (isNetwork) {
      return Image.network(
        cleanPath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallbackWidget(),
      );
    }

    return Image.asset(
      cleanPath,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => fallbackWidget(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              headerTitle.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...items.map((item) {
            final isSewa = item.type == OrderType.sewa;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 64,
                      height: 64,
                      child: _buildProductImage(item.imagePath),
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
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          isSewa
                              ? '${item.subtitleInfo} • ${item.selectedRentalDays} Hari'
                              : item.subtitleInfo,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatRupiah(item.subtotalPrice),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              'x${item.quantity}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
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