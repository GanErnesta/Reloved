import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/order_model.dart';

class OrderActionButtons extends StatelessWidget {
  final OrderStatus status;
  final VoidCallback onCancelPressed;
  final VoidCallback onReorderPressed;

  const OrderActionButtons({
    super.key,
    required this.status,
    required this.onCancelPressed,
    required this.onReorderPressed,
  });

  @override
  Widget build(BuildContext context) {
    final bool canCancel = status == OrderStatus.menunggu;
    final bool canReorder = status == OrderStatus.selesai;

    return Row(
      children: [
        // Tombol Batalkan (Hanya aktif jika status == menunggu)
        Expanded(
          child: SizedBox(
            height: 38,
            child: OutlinedButton(
              onPressed: canCancel ? onCancelPressed : null,
              style: OutlinedButton.styleFrom(
                backgroundColor:
                canCancel ? Colors.white : AppColors.disabledBg,
                foregroundColor:
                canCancel ? AppColors.primary : AppColors.disabledText,
                disabledForegroundColor: AppColors.disabledText,
                disabledBackgroundColor: AppColors.disabledBg,
                side: BorderSide(
                  color: canCancel ? AppColors.primary : AppColors.disabledBg,
                  width: 1.2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text(
                'Batalkan',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Tombol Pesan Lagi (Hanya aktif jika status == selesai)
        Expanded(
          child: SizedBox(
            height: 38,
            child: ElevatedButton(
              onPressed: canReorder ? onReorderPressed : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                canReorder ? AppColors.primary : AppColors.disabledBg,
                foregroundColor:
                canReorder ? Colors.white : AppColors.disabledText,
                disabledBackgroundColor: AppColors.disabledBg,
                disabledForegroundColor: AppColors.disabledText,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text(
                'Pesan Lagi',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}