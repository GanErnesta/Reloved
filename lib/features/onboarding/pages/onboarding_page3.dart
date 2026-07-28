import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

class OnboardingPage3 extends StatelessWidget {
  const OnboardingPage3({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: Stack(
          children: [
            //--------------------------------------------------
            // Background
            //--------------------------------------------------
            Positioned.fill(child: Container(color: AppColors.primary)),

            //--------------------------------------------------
            // Title
            //--------------------------------------------------
            Positioned(
              left: AppSpacing.lg,
              top: 170,
              child: SizedBox(
                width: 400,
                child: Text(
                  "Yuk, Mulai dari Sini",
                  style: AppTextStyles.heading.copyWith(
                    color: Colors.white,
                    fontSize: 32,
                  ),
                ),
              ),
            ),

            //--------------------------------------------------
            // Description
            //--------------------------------------------------
            Positioned(
              left: AppSpacing.lg,
              top: 210,
              child: SizedBox(
                width: 305,
                child: Text(
                  "Gabung komunitas pre-loved dan\njadikan barangmu bermanfaat lagi.",
                  style: AppTextStyles.body.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            //--------------------------------------------------
            // Illustration
            //--------------------------------------------------
            // Orang kiri
            Positioned(
              left: 0,
              top: 330,
              child: Image.asset(
                "assets/images/background-complete.png",
                width: 440,
              ),
            ),
            Positioned(
              left: -100,
              top: 100,
              child: Image.asset("assets/images/character-1.png", width: 400),
            ),

            // Orang kanan
            Positioned(
              right: -100,
              top: 90,
              child: Image.asset("assets/images/pana.png", width: 400),
            ),

            // High Five (tengah)
          ],
        ),
      ),
    );
  }
}
