import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class HomeHeader extends StatelessWidget {
  final VoidCallback onLocationTap;
  final String locationName;
  final bool isLoadingLocation;
  final bool isLocationDetected;

  const HomeHeader({
    super.key,
    required this.onLocationTap,
    required this.locationName,
    required this.isLoadingLocation,
    required this.isLocationDetected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 7, 20, 8),
      child: Row(
        children: [
          SizedBox(
            width: 38,
            height: 38,
            child: Image.asset(
              'assets/images/LogoReloved.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) {
                return const Icon(
                  Icons.shopping_bag,
                  color: AppColors.primary,
                  size: 30,
                );
              },
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: isLocationDetected || isLoadingLocation
                ? null
                : onLocationTap,
            behavior: HitTestBehavior.opaque,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 230),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AppColors.primary, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.location_on,
                    color: AppColors.primary,
                    size: 17,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      isLoadingLocation ? 'Mencari lokasi...' : locationName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  if (isLoadingLocation) ...[
                    const SizedBox(width: 6),
                    const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
