import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

class ProfileInfoCard extends StatelessWidget {
  final Map<String, dynamic> profile;

  const ProfileInfoCard({
    super.key,
    required this.profile,
  });

  Widget buildItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 22,
          ),

          const SizedBox(width: AppSpacing.md),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.caption,
                ),

                const SizedBox(height: 4),

                Text(
                  value,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final campus = profile['campuses'];

    return Container(
      margin: const EdgeInsets.only(
        top: AppSpacing.md,
      ),
      padding: const EdgeInsets.all(
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppRadius.lg,
        ),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Informasi Mahasiswa",
            style: AppTextStyles.title,
          ),

          const SizedBox(height: AppSpacing.md),

          buildItem(
            icon: Icons.badge_outlined,
            title: "NIM",
            value: profile['nim'] ?? "-",
          ),

          const Divider(),

          buildItem(
            icon: Icons.school_outlined,
            title: "Kampus",
            value: campus?['name'] ?? "-",
          ),

          const Divider(),

          buildItem(
            icon: Icons.account_balance_outlined,
            title: "Fakultas",
            value: profile['fakultas'] ?? "-",
          ),

          const Divider(),

          buildItem(
            icon: Icons.menu_book_outlined,
            title: "Program Studi",
            value: profile['program_studi'] ?? "-",
          ),
        ],
      ),
    );
  }
}