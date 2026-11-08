import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/smart_image.dart';

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
                      child: _buildImage(size - 8),
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
              child: _buildImage(size),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(double boxSize) {
    // SmartImage otomatis memilih Image.network / Image.asset dan
    // menampilkan placeholder jika gambar kosong atau gagal dimuat.
    return SmartImage(
      source: imagePath,
      width: boxSize,
      height: boxSize,
      fit: BoxFit.cover,
      placeholderIcon: Icons.checkroom_rounded,
    );
  }
}