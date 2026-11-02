import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class RentalInfoBadge extends StatelessWidget {
  final int durationDays;
  final String remainingText;

  const RentalInfoBadge({
    super.key,
    required this.durationDays,
    required this.remainingText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Sewa $durationDays hari',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          width: 5,
          height: 5,
          decoration: const BoxDecoration(
            color: AppColors.rentalBadgeBg,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.rentalBadgeBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            remainingText,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.rentalBadgeText,
            ),
          ),
        ),
      ],
    );
  }
}