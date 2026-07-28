import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

import '../widgets/auth_logo.dart';
import '../widgets/otp_field.dart';
import '../widgets/primary_button.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String email;

  const VerifyOtpScreen({
    super.key,
    required this.email,
  });

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  String otp = "";

  int seconds = 60;

  Timer? timer;

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

    timer = Timer.periodic(
      const Duration(seconds: 1),
      (t) {
        if (seconds == 0) {
          t.cancel();
        } else {
          setState(() {
            seconds--;
          });
        }
      },
    );
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
              const SizedBox(height: 30),

              const AuthLogo(),

              const SizedBox(height: 40),

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
                      "Verifikasi OTP",
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
                                "Masukkan 6 digit kode yang telah dikirim ke\n",
                          ),
                          TextSpan(
                            text: widget.email,
                            style:
                                const TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    OtpField(
                      onCompleted: (value) {
                        otp = value;
                      },
                    ),

                    const SizedBox(height: 24),

                    Center(
                      child: seconds == 0
                          ? TextButton(
                              onPressed: () {
                                startTimer();

                                // TODO
                                // resend otp
                              },
                              child: Text(
                                "Kirim Ulang OTP",
                                style:
                                    AppTextStyles.bodyMedium
                                        .copyWith(
                                  color:
                                      AppColors.primary,
                                ),
                              ),
                            )
                          : Text(
                              "Kirim ulang dalam ${seconds}s",
                              style:
                                  AppTextStyles.caption,
                            ),
                    ),

                    const SizedBox(height: 26),

                    PrimaryButton(
                      text: "Verifikasi",
                      onPressed: () {
                        if (otp.length != 6) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            const SnackBar(
                              content: Text(
                                  "OTP belum lengkap"),
                            ),
                          );
                          return;
                        }

                        // TODO
                        // verify otp

                        context.go('/create-password');
                      },
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