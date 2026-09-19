import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_text_styles.dart';

class LocationPermissionModal extends StatelessWidget {
  const LocationPermissionModal({
    super.key,
    required this.onAllowLocation,
  });

  final VoidCallback onAllowLocation;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 24,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF9EDEF),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: AppColors.primary,
            width: 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                12,
                14,
                12,
                8,
              ),
              child: Text(
                'Aktifkan Jangkauan Sekitar\nKampusmu 📍',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
              ),
              child: Text(
                'Males COD-an jauh-jauh sampai keluar area\nkampus atau area kosan?',
                style: AppTextStyles.caption.copyWith(
                  fontSize: 12,
                  height: 1.35,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 184,
              child: Image.asset(
                'assets/images/location_map.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.background,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.map_outlined,
                      size: 48,
                      color: AppColors.textSecondary,
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                12,
                10,
                12,
                4,
              ),
              child: Text(
                'Reloved bekerja secara hyperlocal. Dengan '
                'mengizinkan akses lokasi, sistem kami '
                'otomatis mengunci koordinatmu agar kamu '
                'hanya melihat barang pre-loved yang dijual '
                'oleh teman satu fakultas atau kosan tetangga '
                'sebelumnya.',
                style: AppTextStyles.caption.copyWith(
                  fontSize: 12,
                  height: 1.35,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                12,
                8,
                12,
                12,
              ),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onAllowLocation,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 0,
                      vertical: 4,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize:
                        MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Izinkan Lokasi',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}