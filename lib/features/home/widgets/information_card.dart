import 'package:flutter/material.dart';

import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_text_styles.dart';

class InformationCard extends StatelessWidget {
  final String title;
  final String description;
  final Color startColor;
  final Color endColor;
  final String imagePath;
  final VoidCallback? onTap;

  const InformationCard({
    super.key,
    required this.title,
    required this.description,
    required this.startColor,
    required this.endColor,
    required this.imagePath,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [startColor, endColor],
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
              ),
              Positioned(
                left: 10,
                top: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.title.copyWith(
                        color: const Color(0xFF66451F),
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    SizedBox(
                      width: 125,
                      child: Text(
                        description,
                        style: AppTextStyles.caption.copyWith(
                          color: const Color(0xFF33291F),
                          fontSize: 11,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: -5,
                bottom: 0,
                child: Image.asset(
                  imagePath,
                  width: 105,
                  height: 105,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InformationSection extends StatelessWidget {
  final VoidCallback onRentalTap;
  final VoidCallback onCommunityTap;

  const InformationSection({
    super.key,
    required this.onRentalTap,
    required this.onCommunityTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: InformationCard(
              title: 'Sewa Barang',
              description:
                  'Sewa harian aman dengan sistem deposit jaminan terproteksi.',
              startColor: const Color(0xFFFFD99A),
              endColor: const Color(0xFFEBA33E),
              imagePath: 'assets/images/imgtas.png',
              onTap: onRentalTap,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: InformationCard(
              title: 'Komunitas UB',
              description:
                  'Tempat berkumpulnya mahasiswa untuk barter dan diskusi material.',
              startColor: const Color(0xFF9CB9EE),
              endColor: const Color(0xFF2858B5),
              imagePath: 'assets/images/imgub.png',
              onTap: onCommunityTap,
            ),
          ),
        ],
      ),
    );
  }
}