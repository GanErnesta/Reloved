import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

import '../widgets/auth_logo.dart';
import '../widgets/password_field.dart';
import '../widgets/password_requirement.dart';
import '../widgets/password_strength.dart';
import '../widgets/primary_button.dart';

class CreatePasswordScreen extends StatefulWidget {
  const CreatePasswordScreen({super.key});

  @override
  State<CreatePasswordScreen> createState() =>
      _CreatePasswordScreenState();
}

class _CreatePasswordScreenState
    extends State<CreatePasswordScreen> {
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  @override
  void dispose() {
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  bool get isMatch =>
      passwordController.text == confirmController.text;

  bool get isValidPassword {
    final password = passwordController.text;

    return password.length >= 8 &&
        RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
          ),
          child: Column(
            children: [
              const SizedBox(height: 28),

              const AuthLogo(),

              const SizedBox(height: 36),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: const Color(0xffF5E8EA),
                  borderRadius:
                      BorderRadius.circular(AppRadius.lg),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Buat Password",
                      style: AppTextStyles.title.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Buat password yang kuat untuk melindungi akunmu.",
                      style: AppTextStyles.body,
                    ),

                    const SizedBox(height: 24),

                    PasswordField(
                      controller: passwordController,
                      label: "Password",
                      hintText: "Masukkan password",
                      onChanged: (_) {
                        setState(() {});
                      },
                    ),

                    const SizedBox(height: 18),

                    PasswordField(
                      controller: confirmController,
                      label: "Konfirmasi Password",
                      hintText: "Masukkan ulang password",
                      onChanged: (_) {
                        setState(() {});
                      },
                    ),

                    const SizedBox(height: 24),

                    PasswordStrength(
                      password: passwordController.text,
                    ),

                    const SizedBox(height: 20),

                    PasswordRequirement(
                      password: passwordController.text,
                    ),

                    if (confirmController.text.isNotEmpty &&
                        !isMatch)
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 12),
                        child: Text(
                          "Password tidak sama.",
                          style:
                              AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.danger,
                          ),
                        ),
                      ),

                    const SizedBox(height: 28),

                    PrimaryButton(
                      text: "Buat Password",
                      onPressed: () {
                        if (!isValidPassword) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Password belum memenuhi syarat.",
                              ),
                            ),
                          );
                          return;
                        }

                        if (!isMatch) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Konfirmasi password tidak sesuai.",
                              ),
                            ),
                          );
                          return;
                        }

                        // TODO:
                        // Simpan password ke Supabase

                        context.go('/setup-profile');
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}