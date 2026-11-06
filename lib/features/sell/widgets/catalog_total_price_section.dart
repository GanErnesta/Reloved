
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class CatalogTotalPriceSection extends StatelessWidget {
  final TextEditingController totalPriceController;
  final int rentalDuration;
  final String? selectedPeriod;
  final ValueChanged<int> onDurationChanged;
  final ValueChanged<String?> onPeriodChanged;

  const CatalogTotalPriceSection({
    super.key,
    required this.totalPriceController,
    required this.rentalDuration,
    required this.selectedPeriod,
    required this.onDurationChanged,
    required this.onPeriodChanged,
  });

  final List<String> periods = const [
    'Hari',
    'Minggu',
    'Bulan',
  ];

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
            'Informasi Harga Total',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),

          _label('Harga Total'),
          TextField(
            controller: totalPriceController,
            keyboardType: TextInputType.number,
            decoration: _decoration('Masukkan harga total'),
          ),

          const SizedBox(height: 20),

          _label('Waktu Sewa'),
          Row(
            children: [
              Expanded(
                child: _buildDurationStepper(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedPeriod,
                  isExpanded: true,
                  hint: const Text(
                    'Pilih Rentang',
                    style: TextStyle(fontSize: 12),
                  ),
                  decoration: _decoration(''),
                  items: periods.map((period) {
                    return DropdownMenuItem<String>(
                      value: period,
                      child: Text(
                        period,
                        style: const TextStyle(fontSize: 13),
                      ),
                    );
                  }).toList(),
                  onChanged: onPeriodChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDurationStepper() {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: () {
              if (rentalDuration > 1) {
                onDurationChanged(rentalDuration - 1);
              }
            },
            icon: const Icon(Icons.remove, size: 19),
          ),
          Text(
            '$rentalDuration',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: () {
              onDurationChanged(rentalDuration + 1);
            },
            icon: const Icon(Icons.add, size: 19),
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
          fontSize: 12,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  InputDecoration _decoration(String hint) {
    return InputDecoration(
      hintText: hint.isEmpty ? null : hint,
      hintStyle: const TextStyle(
        fontSize: 12,
        color: AppColors.textSecondary,
      ),
      filled: true,
      fillColor: const Color(0xFFFFFCFC),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
    );
  }
}
