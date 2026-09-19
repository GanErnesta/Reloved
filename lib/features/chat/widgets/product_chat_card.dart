import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_text_styles.dart';

class ProductChatCard extends StatelessWidget {
  final String imageUrl;
  final String productName;
  final String price;

  const ProductChatCard({
    super.key,
    required this.imageUrl,
    required this.productName,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        16,
        8,
        16,
        8,
      ),
      padding: const EdgeInsets.fromLTRB(
        16,
        10,
        8,
        8,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppRadius.lg,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kamu bertanya mengenai produk ini',
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF1E5E8),
              borderRadius: BorderRadius.circular(
                AppRadius.sm,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  margin: const EdgeInsets.only(
                    left: 2,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      AppRadius.sm,
                    ),
                    border: Border.all(
                      color: AppColors.primary.withValues(
                        alpha: 0.35,
                      ),
                      width: 2,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return const Icon(
                        Icons.image_outlined,
                        color: AppColors.textSecondary,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        productName,
                        style: AppTextStyles.body.copyWith(
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        price,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontSize: 21,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}