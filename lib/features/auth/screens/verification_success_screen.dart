
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

import '../widgets/auth_logo.dart';
import '../widgets/primary_button.dart';

class VerificationSuccessScreen extends StatelessWidget {
  const VerificationSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AuthLogo(),

                const SizedBox(height: 45),

                Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(
                      alpha: 0.12,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.success,
                    size: 85,
                  ),
                ),

                const SizedBox(height: 30),

                Text(
                  'Verifikasi Berhasil!',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.title.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  'Akun Reloved kamu berhasil dibuat. '
                  'Sekarang kamu bisa mulai menjelajahi '
                  'berbagai produk dari mahasiswa lainnya.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    text: 'Mulai Sekarang',
                    onPressed: () {
                      context.go('/home');
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
