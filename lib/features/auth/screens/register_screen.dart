import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';

import '../widgets/auth_card.dart';
import '../widgets/auth_logo.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
            ),
            child: Column(
              children: const [

                SizedBox(height: 20),

                AuthLogo(),

                SizedBox(height: 32),

                AuthCard(),

                SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}