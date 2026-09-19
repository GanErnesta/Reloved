import 'package:application_reloved/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_text_styles.dart';

class OnboardingPage2 extends StatelessWidget {
  const OnboardingPage2({super.key});

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
            // Judul
            //--------------------------------------------------
            Positioned(
              left: 28,
              top: 82,
              child: SizedBox(
                width: 400,
                child: Text(
                  "Dekat, Hemat, dan \nTepat",
                  style: AppTextStyles.heading.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                  ),
                ),
              ),
            ),

            //--------------------------------------------------
            // Deskripsi
            //--------------------------------------------------
            Positioned(
              left: 28,
              top: 165,
              child: SizedBox(
                width: 300,
                child: Text(
                  "Butuh sesuatu? Cari, sewa, atau jual —\n"
                  "tinggal filter jarak dan harga.",
                  style: AppTextStyles.body.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            //--------------------------------------------------
            // Comments Tag
            //--------------------------------------------------
            Positioned(
              right: 15,
              top: size.height * .30,
              child: Image.asset("assets/images/comments.png", width: 300),
            ),

            //--------------------------------------------------
            // Shopping Bag
            //--------------------------------------------------
            Positioned(
              left: -65,
              bottom: 100,
              child: Image.asset("assets/images/Bags.png", width: 400),
            ),
          ],
        ),
      ),
    );
  }
}
