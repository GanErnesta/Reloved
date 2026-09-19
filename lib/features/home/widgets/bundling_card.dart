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
      padding: const EdgeInsets.fromLTRB(
        9,
        22,
        9,
        8,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                bundle.title,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                bundle.description,
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  Text(
                    bundle.price,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    bundle.oldPrice,
                    style: AppTextStyles.caption.copyWith(
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            top: -18,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                bundle.badge,
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white,
                  fontSize: 10,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}