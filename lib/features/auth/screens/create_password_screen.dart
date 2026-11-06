import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

import '../../profile/repository/profile_repository.dart';

import '../services/auth_service.dart';
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

class _CreatePasswordScreenState extends State<CreatePasswordScreen> {
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  final ProfileRepository _profileRepository = ProfileRepository();

  bool isLoading = false;

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

  bool isSamePasswordError(Object error) {
    final message = error.toString().toLowerCase();

    return message.contains('different from the old password') ||
        message.contains('same password') ||
        message.contains('should be different');
  }

  Future<void> createPassword() async {
    if (isLoading) return;

    if (!isValidPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password belum memenuhi syarat.'),
        ),
      );
      return;
    }

    if (!isMatch) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Konfirmasi password tidak sesuai.'),
        ),
      );
      return;
    }

    try {
      setState(() => isLoading = true);

      final user = AuthService.currentUser;

      if (user == null) {
        throw Exception(
          'Sesi pengguna tidak ditemukan. Silakan verifikasi OTP kembali.',
        );
      }

      debugPrint('========== REGISTRATION DEBUG ==========');
      debugPrint('USER ID: ${user.id}');
      debugPrint('USER EMAIL: ${user.email}');
      debugPrint('USER METADATA: ${user.userMetadata}');
      debugPrint('=========================================');

      // 1. Simpan data pendaftaran ke tabel profiles.
      // Proses ini menggunakan upsert sehingga aman dicoba ulang.
      await _profileRepository.saveProfileFromMetadata();

      debugPrint('PROFILE SAVED SUCCESSFULLY');

      // 2. Simpan password ke Supabase Auth.
      try {
        await AuthService.setPassword(
          passwordController.text,
        );

        debugPrint('PASSWORD SAVED SUCCESSFULLY');
      } catch (e) {
        // Jika password sudah berhasil disimpan pada percobaan
        // sebelumnya, Supabase dapat menolak password yang sama.
        if (isSamePasswordError(e)) {
          debugPrint('PASSWORD ALREADY SET PREVIOUSLY');
        } else {
          rethrow;
        }
      }

      if (!mounted) return;

      // 3. Arahkan ke halaman verifikasi berhasil.
      context.go('/verification-success');
    } catch (e, stackTrace) {
      debugPrint('CREATE PASSWORD ERROR: $e');
      debugPrint('STACK TRACE: $stackTrace');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
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
                  borderRadius: BorderRadius.circular(
                    AppRadius.lg,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Buat Password',
                      style: AppTextStyles.title.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Buat password yang kuat untuk melindungi akunmu.',
                      style: AppTextStyles.body,
                    ),

                    const SizedBox(height: 24),

                    PasswordField(
                      controller: passwordController,
                      label: 'Password',
                      hintText: 'Masukkan password',
                      onChanged: (_) => setState(() {}),
                    ),

                    const SizedBox(height: 18),

                    PasswordField(
                      controller: confirmController,
                      label: 'Konfirmasi Password',
                      hintText: 'Masukkan ulang password',
                      onChanged: (_) => setState(() {}),
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
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          'Password tidak sama.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.danger,
                          ),
                        ),
                      ),

                    const SizedBox(height: 28),

                    PrimaryButton(
                      text: 'Buat Password',
                      loading: isLoading,
                      onPressed: isLoading
                          ? null
                          : createPassword,
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