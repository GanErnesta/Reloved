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
      title: 'Kebutuhan\nKos',
    ),
    _CategoryItem(
      icon: Icons.checkroom_outlined,
      title: 'Fashion\nKampus',
    ),
    _CategoryItem(
      icon: Icons.science_outlined,
      title: 'Alat\nPraktikum',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: categories.map((category) {
          return SizedBox(
            width: 78,
            child: Column(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.background,
                    border: Border.all(
                      color: AppColors.primary,
                    ),
                  ),
                  child: Icon(
                    category.icon,
                    color: AppColors.primary,
                    size: 27,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  category.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    height: 1.2,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
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