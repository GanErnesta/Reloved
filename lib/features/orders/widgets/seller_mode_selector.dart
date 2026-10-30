import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/seller_order_model.dart';

class SellerModeSelector extends StatelessWidget {
  final SellerOrderMode currentMode;
  final int salePendingCount;
  final int rentalPendingCount;
  final ValueChanged<SellerOrderMode> onModeSelected;

  const SellerModeSelector({
    super.key,
    required this.currentMode,
    required this.salePendingCount,
    required this.rentalPendingCount,
    required this.onModeSelected,
  });

  int get _otherModeCount => currentMode == SellerOrderMode.penjualan
      ? rentalPendingCount
      : salePendingCount;

  String get _currentModeLabel => currentMode == SellerOrderMode.penjualan
      ? 'Mode: Penjualan'
      : 'Mode: Penyewaan';

  String get _otherModeShortName =>
      currentMode == SellerOrderMode.penjualan ? 'Sewa' : 'Jual';

  @override
  Widget build(BuildContext context) {
    final bool hasOtherPending = _otherModeCount > 0;

    return GestureDetector(
      onTap: () => _showModePickerSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFE2E6EE),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            // Titik Maroon Kiri
            Container(
              width: 9,
              height: 9,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),

            // Teks Mode Aktif
            Expanded(
              child: Text(
                _currentModeLabel,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),

            // Indikator Tanda Seru (!) jika ada permintaan di mode seberang
            if (hasOtherPending) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFECEB),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFE53935).withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE53935),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        '!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '$_otherModeCount $_otherModeShortName',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFD32F2F),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
            ],

            // Ikon Swap Panah Atas-Bawah
            const Icon(
              Icons.swap_vert_rounded,
              color: Color(0xFF7C8698),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  void _showModePickerSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Pilih Mode Kelola Pesanan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                _buildModeOptionTile(
                  context: ctx,
                  mode: SellerOrderMode.penjualan,
                  title: 'Mode: Penjualan',
                  subtitle: 'Kelola pesanan beli & COD mahasiswa',
                  pendingCount: salePendingCount,
                ),
                const SizedBox(height: 10),
                _buildModeOptionTile(
                  context: ctx,
                  mode: SellerOrderMode.penyewaan,
                  title: 'Mode: Penyewaan',
                  subtitle: 'Kelola permintaan sewa, masa aktif & pengembalian',
                  pendingCount: rentalPendingCount,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModeOptionTile({
    required BuildContext context,
    required SellerOrderMode mode,
    required String title,
    required String subtitle,
    required int pendingCount,
  }) {
    final bool isSelected = currentMode == mode;

    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        onModeSelected(mode);
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.grey.shade400,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (pendingCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE53935),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$pendingCount Baru',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}