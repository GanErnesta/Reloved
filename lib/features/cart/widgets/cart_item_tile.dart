import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../orders/models/order_model.dart';
import '../models/cart_model.dart';

class CartItemTile extends StatelessWidget {
  final CartItemModel item;
  final ValueChanged<bool> onCheckChanged;
  final VoidCallback onDeleteTap;
  final ValueChanged<int> onQuantityDelta;
  final ValueChanged<int> onRentalDurationSelected;

  const CartItemTile({
    super.key,
    required this.item,
    required this.onCheckChanged,
    required this.onDeleteTap,
    required this.onQuantityDelta,
    required this.onRentalDurationSelected,
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
    final bool isSewa = item.type == OrderType.sewa;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Checkbox di sebelah kiri
              _buildCustomCheckbox(
                value: item.isSelected,
                onChanged: onCheckChanged,
              ),
              const SizedBox(width: 10),

              // Foto Produk
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 82,
                  height: 88,
                  color: AppColors.primaryLight,
                  child: Image.asset(
                    item.imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.checkroom_rounded,
                      color: AppColors.primary,
                      size: 36,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Detail Produk Kanan
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Baris Badge (BELI / SEWA) & Tombol Hapus (Sampah)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: isSewa
                                ? const Color(0xFFE6F4EA)
                                : AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isSewa ? 'SEWA' : 'BELI',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isSewa
                                  ? const Color(0xFF2E7D32)
                                  : AppColors.primary,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: onDeleteTap,
                          borderRadius: BorderRadius.circular(12),
                          child: const Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Icon(
                              Icons.delete_outline_rounded,
                              size: 20,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Nama Produk
                    Text(
                      item.productName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),

                    // Sub-info (Ukuran / Kondisi / Mulai tanggal)
                    Text(
                      item.subtitleInfo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Baris Harga & Stepper Kuantitas (Khusus BELI)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: _formatRupiah(item.unitPrice),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                              if (isSewa)
                                const TextSpan(
                                  text: '/hari',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // Stepper (- 1 +) untuk tipe BELI
                        if (!isSewa)
                          Container(
                            height: 30,
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.25),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: () => onQuantityDelta(-1),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 6),
                                    child: Icon(
                                      Icons.remove,
                                      size: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(
                                    '${item.quantity}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () => onQuantityDelta(1),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 6),
                                    child: Icon(
                                      Icons.add,
                                      size: 14,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Kotak Pengaturan Durasi Sewa (1h, 3h, 7h) & Deposit (Khusus SEWA)
          if (isSewa) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 34),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6EFEF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Durasi sewa',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.rentalDateRangeText,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [1, 3, 7].map((days) {
                            final bool selected =
                                item.selectedRentalDays == days;
                            return Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: InkWell(
                                onTap: () => onRentalDurationSelected(days),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? AppColors.primary
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: selected
                                          ? AppColors.primary
                                          : AppColors.divider,
                                    ),
                                  ),
                                  child: Text(
                                    '${days}h',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: selected
                                          ? Colors.white
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(color: AppColors.divider, height: 1),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Deposit dapat dikembalikan',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          _formatRupiah(item.refundableDeposit),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCustomCheckbox({
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: value ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: value ? AppColors.primary : const Color(0xFFD0C4C4),
            width: 1.5,
          ),
        ),
        child: value
            ? const Icon(Icons.check, size: 15, color: Colors.white)
            : null,
      ),
    );
  }
}