import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

class OnboardingPage1 extends StatelessWidget {
  const OnboardingPage1({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            //--------------------------------------------------
            // BACKGROUND
            //--------------------------------------------------
            Positioned.fill(child: Container(color: AppColors.primary)),

            //--------------------------------------------------
            // ELLIPSE BESAR PUTIH
            //--------------------------------------------------
            Positioned(
              left: -220,
              bottom: 150,
              top: size.height * .38,
              child: Container(
                width: 560,
                height: 200,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),

            //--------------------------------------------------
            // LINGKARAN MERAH KECIL
            //--------------------------------------------------
            Positioned(
              right: -55,
              top: 115,
              child: Container(
                width: 95,
                height: 95,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red.shade200.withOpacity(.35),
                ),
              ),
            ),

            //--------------------------------------------------
            // LINGKARAN MERAH BESAR
            //--------------------------------------------------
            Positioned(
              right: -130,
              top: 165,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red.shade200.withOpacity(.15),
                ),
              ),
            ),

            //--------------------------------------------------
            // TITLE
            //--------------------------------------------------
            Positioned(
              left: AppSpacing.lg + 4,
              top: 100,
              child: SizedBox(
                width: 400,
                child: Text(
                  "Setiap Barang Punya Cerita",
                  style: AppTextStyles.heading.copyWith(
                    color: Colors.white,
                    fontSize: 30,
                    height: 1.12,
                  ),
                ),
              ),
            ),

            //--------------------------------------------------
            // DESCRIPTION
            //--------------------------------------------------
            Positioned(
              left: 28,
              top: 175,
              child: SizedBox(
                width: 285,
                child: Text(
                  "Barang lamamu masih berharga. "
                  "Jual, beli, atau sewa bareng sesama"
                  "\nmahasiswa.",
                  style: AppTextStyles.body.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            //--------------------------------------------------
            // IMAGE (sementara)
            //--------------------------------------------------
            Positioned(
              right: 30,
              bottom: 150,
              child: SizedBox(
                width: 255,
                child: Image.asset(
                  "assets/images/Rack.png",
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
