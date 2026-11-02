import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class CategoryMenu extends StatelessWidget {
  const CategoryMenu({super.key});

  static const List<_CategoryItem> categories = [
    _CategoryItem(
      icon: Icons.menu_book_outlined,
      title: 'Buku Kuliah',
    ),
    _CategoryItem(
      icon: Icons.bed_outlined,
      title: 'Barang Kost',
    ),
    _CategoryItem(
      icon: Icons.checkroom_outlined,
      title: 'Fashion\nKampus',
    ),
    _CategoryItem(
      icon: Icons.science_outlined,
      title: 'Alat\nPraktikum',
    ),
    _CategoryItem(
      icon: Icons.restaurant_outlined,
      title: 'Bumbu\nMakanan',
    ),
    _CategoryItem(
      icon: Icons.tv_outlined,
      title: 'Alat\nElektronik',
    ),
    _CategoryItem(
      icon: Icons.face_retouching_natural_outlined,
      title: 'Makeup &\nSkincare',
    ),
    _CategoryItem(
      icon: Icons.tune,
      title: 'Lihat Semua',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: categories.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 16,
          crossAxisSpacing: 8,
          childAspectRatio: 0.88,
        ),
        itemBuilder: (context, index) {
          final category = categories[index];

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: AppColors.primary,
                    width: 1.6,
                  ),
                ),
                child: Icon(
                  category.icon,
                  color: AppColors.primary,
                  size: 26,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                category.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontSize: 11,
                  height: 1.15,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CategoryItem {
  final IconData icon;
  final String title;

  const _CategoryItem({
    required this.icon,
    required this.title,
  });
}