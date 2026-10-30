import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/safe_meeting_point_model.dart';

class OrderLocationCard extends StatelessWidget {
  final String pickupAddress;
  final SafeMeetingPointModel safeMeetingPoint;
  final String buyerAccountInfo;
  final bool canEditMeetingPoint;
  final VoidCallback? onTapMeetingPoint;

  const OrderLocationCard({
    super.key,
    required this.pickupAddress,
    required this.safeMeetingPoint,
    required this.buyerAccountInfo,
    this.canEditMeetingPoint = false,
    this.onTapMeetingPoint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Diambil dari (Alamat Seller)
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.statusWarning,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Diambil dari',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            pickupAddress,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),

          // 2. Diantar ke (Safe Meeting Point Buyer)
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.statusSuccess,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Diantar ke',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          InkWell(
            onTap: canEditMeetingPoint ? onTapMeetingPoint : null,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${safeMeetingPoint.name} — ${safeMeetingPoint.fullAddress}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textPrimary,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          buyerAccountInfo,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: canEditMeetingPoint
                        ? AppColors.textPrimary
                        : AppColors.disabledText,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}