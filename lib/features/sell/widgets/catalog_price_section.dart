
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class CatalogPriceSection extends StatelessWidget {
  final TextEditingController priceController;
  final TextEditingController stockController;

  const CatalogPriceSection({
    super.key,
    required this.priceController,
    required this.stockController,
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
            'Detail Penjualan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          _label('Harga Jual (Rp)'),
          _field(
            controller: priceController,
            hint: 'Masukkan harga jual',
          ),

          const SizedBox(height: 16),

          _label('Jumlah Stok'),
          _field(
            controller: stockController,
            hint: 'Masukkan jumlah stok',
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
        filled: true,
        fillColor: const Color(0xFFFFFCFC),
        contentPadding: const EdgeInsets.all(14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      ),
    );
  }
}
