
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class CatalogTransactionSection extends StatelessWidget {
  final String selectedTransaction;
  final ValueChanged<String> onTransactionChanged;

  const CatalogTransactionSection({
    super.key,
    required this.selectedTransaction,
    required this.onTransactionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEDE8E8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Jenis Transaksi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Pilih jenis transaksi untuk produk yang kamu tawarkan.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _transactionOption(
                  value: 'jual',
                  title: 'Jual',
                  subtitle: 'Produk dijual',
                  icon: Icons.sell_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _transactionOption(
                  value: 'sewa',
                  title: 'Sewa',
                  subtitle: 'Produk disewakan',
                  icon: Icons.key_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _transactionOption({
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = selectedTransaction == value;

    return InkWell(
      onTap: () => onTransactionChanged(value),
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 12,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.06)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
