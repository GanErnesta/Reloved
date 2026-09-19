import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

class InformationCard extends StatelessWidget {
  final String title;
  final String description;

  const InformationCard({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 84,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 3),
          Expanded(
            child: Text(
              description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(
                fontSize: 11,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class InformationSection extends StatelessWidget {
  const InformationSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        8,
        AppSpacing.md,
        0,
      ),
      child: Row(
        children: [
          Expanded(
            child: InformationCard(
              title: 'Sewa Alat Praktikum',
              description:
                  'Sewa harian aman dengan sistem deposit jaminan terproteksi.',
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: InformationCard(
              title: 'Komunitas Sirkular UB',
              description:
                  'Tempat berkumpulnya mahasiswa untuk barter dan diskusi material.',
            ),
          ),
        ],
      ),
    );
  }
}