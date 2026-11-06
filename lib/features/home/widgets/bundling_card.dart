import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_text_styles.dart';

class BundleItem {
  final String title;
  final String description;
  final String price;
  final String oldPrice;
  final String badge;

  const BundleItem({
    required this.title,
    required this.description,
    required this.price,
    required this.oldPrice,
    required this.badge,
  });
}

class BundlingCard extends StatelessWidget {
  final BundleItem bundle;

  const BundlingCard({
    super.key,
    required this.bundle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 270,
      height: 106,
      padding: const EdgeInsets.fromLTRB(9, 23, 9, 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF5E9EA),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: const Color(0xFFE8DADB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                bundle.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                bundle.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    bundle.price,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    bundle.oldPrice,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            top: -23,
            right: -9,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 9,
                vertical: 4,
              ),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(AppRadius.md),
                  bottomLeft: Radius.circular(8),
                ),
              ),
              child: Text(
                bundle.badge,
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}