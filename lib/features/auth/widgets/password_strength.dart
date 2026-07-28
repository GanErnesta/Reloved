import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class PasswordStrength extends StatelessWidget {
  final String password;

  const PasswordStrength({
    super.key,
    required this.password,
  });

  int get score {
    int value = 0;

    if (password.length >= 8) value++;
    if (RegExp(r'[A-Z]').hasMatch(password)) value++;
    if (RegExp(r'[a-z]').hasMatch(password)) value++;
    if (RegExp(r'[0-9]').hasMatch(password)) value++;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password)) value++;

    return value;
  }

  Color get color {
    if (score <= 2) return AppColors.danger;
    if (score == 3 || score == 4) return Colors.orange;
    return AppColors.success;
  }

  String get label {
    if (score <= 2) return "Password Lemah";
    if (score == 3 || score == 4) return "Password Sedang";
    return "Password Kuat";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: LinearProgressIndicator(
            value: score / 5,
            minHeight: 8,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),

        const SizedBox(height: 8),

        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}