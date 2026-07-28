import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class AuthLogo extends StatelessWidget {
  const AuthLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          "assets/images/LogoReloved.png",
          width: 145,
          fit: BoxFit.contain,
        ),

        const SizedBox(height: 8),

        Text(
          "Reloved",
          style: AppTextStyles.heading.copyWith(
            color: AppColors.primary,
            fontSize: 54,
            fontWeight: FontWeight.w700,
            letterSpacing: -2,
          ),
        ),
      ],
    );
  }
}