import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/order_model.dart';
import 'stacked_product_image.dart';

class OrderItemRow extends StatelessWidget {
  final OrderItemModel item;
  final bool showStackEffect;
  final String Function(int) formatCurrency;

  const OrderItemRow({
    super.key,
    required this.item,
    required this.formatCurrency,
    this.showStackEffect = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasVariant =
        item.variant != null && item.variant!.trim().isNotEmpty;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StackedProductImage(
          imagePath: item.imagePath,
          showStackEffect: showStackEffect,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Baris 1: Nama Produk (Kiri) & Harga (Kanan)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.productName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      formatCurrency(item.price),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Baris 2: Variasi Warna/Ukuran (Kiri - kosong jika tidak ada) & Kuantitas x1 (Kanan)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: hasVariant
                          ? Text(
                        item.variant!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      )
                          : const SizedBox.shrink(),
                    ),
                    Text(
                      'x${item.quantity}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}