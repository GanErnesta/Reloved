import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class StackedProductImage extends StatelessWidget {
  final String imagePath;
  final bool showStackEffect;
  final double size;

  const StackedProductImage({
    super.key,
    required this.imagePath,
    this.showStackEffect = false,
    this.size = 76,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: showStackEffect ? size + 12 : size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.centerLeft,
        children: [
          // Efek bayangan kartu menumpuk di kanan belakang jika item > 1 & belum di-expand
          if (showStackEffect)
            Positioned(
              left: 12,
              child: Transform.rotate(
                angle: 0.08,
                child: Container(
                  width: size - 8,
                  height: size - 8,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: Opacity(
                      opacity: 0.65,
                      child: _buildImage(),
                    ),
                  ),
                ),
              ),
            ),

          // Gambar Utama di Depan
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.35),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: _buildImage(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        // Fallback placeholder jika asset belum dimasukkan
        return Container(
          color: const Color(0xFFF5F5F5),
          child: const Icon(
            Icons.checkroom_rounded,
            color: AppColors.textSecondary,
            size: 32,
          ),
        );
      },
    );
  }
}