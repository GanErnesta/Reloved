import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

class HomeHeader extends StatelessWidget {
  final VoidCallback onLocationTap;

  const HomeHeader({
    super.key,
    required this.onLocationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        12,
        AppSpacing.md,
        8,
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            child: const Icon(
              Icons.shopping_bag,
              color: AppColors.primary,
              size: 30,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onLocationTap,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 4,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: AppColors.primary,
                    size: 19,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Lokasi gagal',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontSize: 12,
                    ),
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