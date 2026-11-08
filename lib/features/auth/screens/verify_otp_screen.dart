import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

import '../services/auth_service.dart';
import '../widgets/auth_logo.dart';
import '../widgets/otp_field.dart';
import '../widgets/primary_button.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String email;
  final Map<String, dynamic> userData;

  const VerifyOtpScreen({
    super.key,
    required this.email,
    required this.userData,
  });

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  String otp = '';

  int seconds = 60;

  Timer? timer;

  bool isLoading = false;
  bool isResending = false;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    timer?.cancel();

    seconds = 60;

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }

      if (seconds <= 1) {
        t.cancel();

        setState(() {
          seconds = 0;
        });
      } else {
        setState(() {
          seconds--;
        });
      }
    });
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> verifyOtp() async {
    if (otp.length != 6) {
      showMessage('Masukkan 6 digit kode OTP.');
      return;
    }

    if (isLoading) return;

    try {
      setState(() {
        isLoading = true;
      });

      // Verifikasi OTP sekaligus memperbarui metadata pengguna.
      final user = await AuthService.verifyOtp(
        email: widget.email,
        otp: otp,
        userData: widget.userData,
      );

      debugPrint('========== OTP VERIFICATION ==========');
      debugPrint('USER ID: ${user.id}');
      debugPrint('USER EMAIL: ${user.email}');
      debugPrint('USER METADATA: ${user.userMetadata}');
      debugPrint('======================================');

      if (!mounted) return;

      showMessage('Verifikasi email berhasil.');

      context.go('/create-password');
    } catch (e) {
      debugPrint('VERIFY OTP ERROR: $e');

      if (!mounted) return;

      showMessage(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> resendOtp() async {
    if (seconds > 0 || isResending) return;

    try {
      setState(() {
        isResending = true;
      });

      await AuthService.resendOtp(widget.email);

      if (!mounted) return;

      startTimer();

      showMessage('Kode OTP berhasil dikirim ulang.');
    } catch (e) {
      debugPrint('RESEND OTP ERROR: $e');

      if (!mounted) return;

      showMessage(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {
          isResending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            children: [
              const SizedBox(height: 30),

              const AuthLogo(),

              const SizedBox(height: 40),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: const Color(0xffF5E8EA),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Verifikasi OTP',
                      style: AppTextStyles.title.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    RichText(
                      text: TextSpan(
                        style: AppTextStyles.body,
                        children: [
                          const TextSpan(
                            text:
                                'Masukkan 6 digit kode yang telah dikirim ke\n',
                          ),
                          TextSpan(
                            text: widget.email,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 26),

                    OtpField(
                      onCompleted: (value) {
                        otp = value;
                      },
                    ),

                    Center(
                      child: seconds == 0
                          ? TextButton(
                              onPressed: isResending ? null : resendOtp,
                              child: Text(
                                isResending
                                    ? 'Mengirim ulang...'
                                    : 'Kirim Ulang OTP',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            )
                          : Text(
                              'Kirim ulang dalam ${seconds}s',
                              style: AppTextStyles.caption,
                            ),
                    ),
                    const SizedBox(height: 20),

                    PrimaryButton(
                      text: 'Verifikasi',
                      loading: isLoading,
                      onPressed: isLoading ? null : verifyOtp,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
