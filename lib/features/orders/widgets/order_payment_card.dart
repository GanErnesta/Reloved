import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/order_model.dart';

class OrderPaymentCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onChangePaymentMethodTap;

  const OrderPaymentCard({
    super.key,
    required this.order,
    required this.onChangePaymentMethodTap,
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
    final bool canChangePayment = order.status == OrderStatus.menunggu;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rincian Pembayaran',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildPriceRow('Biaya Produk', _formatRupiah(order.productSubtotal)),
          const SizedBox(height: 6),
          _buildPriceRow('Ongkir', _formatRupiah(order.shippingFee)),
          const SizedBox(height: 6),
          _buildPriceRow(
            'Diskon',
            '- ${_formatRupiah(order.discount)}',
            valueColor: AppColors.statusSuccess,
          ),
          const SizedBox(height: 8),
          _buildPriceRow(
            'Total Biaya',
            _formatRupiah(order.grandTotal),
            isBold: true,
          ),
          const SizedBox(height: 14),

          // Metode Pembayaran (Hanya dapat diklik jika status == menunggu)
          InkWell(
            onTap: canChangePayment ? onChangePaymentMethodTap : null,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Metode Pembayaran',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        order.paymentMethod,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: canChangePayment
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: canChangePayment
                            ? AppColors.textPrimary
                            : AppColors.disabledText,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
      String label,
      String value, {
        Color? valueColor,
        bool isBold = false,
      }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}