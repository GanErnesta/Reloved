import 'package:flutter/material.dart';

class LocationPermissionModal extends StatelessWidget {
  final VoidCallback onAllowLocation;

  const LocationPermissionModal({super.key, required this.onAllowLocation});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Aktifkan Jangkauan Sekitar Kampusmu 📍',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF9F283A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Males COD-an jauh-jauh sampai keluar area kampus atau area kosan?',
              style: TextStyle(
                fontSize: 12,
                height: 1.4,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/images/imgmaps.png',
                width: double.infinity,
                height: 170,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 170,
                    width: double.infinity,
                    color: const Color(0xFFF0F0F0),
                    child: const Icon(
                      Icons.map_outlined,
                      size: 55,
                      color: Color(0xFF9F283A),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Reloved bekerja secara hyperlocal. Dengan mengizinkan akses lokasi, sistem kami otomatis mengikuti koordinat agar kamu hanya melihat barang pre-loved yang ada di sekitar fakultas atau kosan tetanggamu.',
              style: TextStyle(
                fontSize: 11,
                height: 1.45,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onAllowLocation,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF9F283A),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                ),
                child: const Text(
                  'Izinkan Lokasi',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
