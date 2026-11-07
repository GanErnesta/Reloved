import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class ProfileHeader extends StatelessWidget {
  final Map<String, dynamic> profile;

  const ProfileHeader({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final photo = profile['foto_profil']?.toString();
    final campus = profile['campuses'];

    final nama = profile['nama']?.toString() ?? '-';
    final email = profile['email']?.toString() ?? '-';
    final fakultas = profile['fakultas']?.toString() ?? '';
    final prodi = profile['program_studi']?.toString() ?? '';

    // Angkatan dapat ditambahkan ke kolom profiles jika tersedia.
    final angkatan = profile['angkatan']?.toString();

    final campusName = campus is Map
        ? campus['name']?.toString() ?? '-'
        : profile['kampus']?.toString() ?? '-';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.border,
              ),
              child: CircleAvatar(
                radius: 34,
                backgroundColor: AppColors.background,
                backgroundImage:
                    photo != null && photo.isNotEmpty
                        ? NetworkImage(photo)
                        : null,
                child: photo == null || photo.isEmpty
                    ? const Icon(
                        Icons.person,
                        size: 36,
                        color: AppColors.textSecondary,
                      )
                    : null,
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatistic('0', 'Transaksi'),
                  _buildDivider(),
                  _buildStatistic('0', 'Pengikut'),
                  _buildDivider(),
                  _buildStatistic('0', 'Mengikuti'),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        Text(
          nama,
          style: AppTextStyles.title.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 4),

        Row(
          children: [
            const Icon(
              Icons.location_on_outlined,
              size: 14,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                campusName,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        if (prodi.isNotEmpty || angkatan != null)
          Wrap(
            spacing: 5,
            children: [
              if (prodi.isNotEmpty)
                _buildBadge(prodi),
              if (angkatan != null && angkatan.isNotEmpty)
                _buildBadge(angkatan),
            ],
          ),

        if (fakultas.isNotEmpty) ...[
          const SizedBox(height: 5),
          Text(
            fakultas,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],

        const SizedBox(height: 8),

        Text(
          email,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatistic(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.title.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 32,
      width: 1,
      color: AppColors.border,
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}