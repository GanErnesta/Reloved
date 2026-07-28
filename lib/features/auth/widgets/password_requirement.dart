import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class PasswordRequirement extends StatelessWidget {
  final String password;

  const PasswordRequirement({
    super.key,
    required this.password,
  });

  Widget buildItem(bool valid, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            valid
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked,
            color: valid
                ? AppColors.success
                : Colors.grey.shade400,
            size: 18,
          ),

          const SizedBox(width: 8),

          Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(
              color: valid
                  ? AppColors.success
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildItem(
          password.length >= 8,
          "Minimal 8 karakter",
        ),

        buildItem(
          RegExp(r'[A-Z]').hasMatch(password),
          "Mengandung huruf besar",
        ),

        buildItem(
          RegExp(r'[a-z]').hasMatch(password),
          "Mengandung huruf kecil",
        ),

        buildItem(
          RegExp(r'[0-9]').hasMatch(password),
          "Mengandung angka",
        ),
      ],
    );
  }
}