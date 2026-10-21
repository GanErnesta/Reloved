import 'package:flutter/material.dart';
import '../models/community_model.dart';

class CommunityCard extends StatelessWidget {
  final CommunityModel community;
  final VoidCallback onTap;
  final VoidCallback? onJoinTap;

  const CommunityCard({
    super.key,
    required this.community,
    required this.onTap,
    this.onJoinTap,
  });

  static const Color _primaryMaroon = Color(0xFF9B2335);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 154,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Background Image di sisi kanan
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 190,
              child: Image.asset(
                community.backgroundAsset,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFFB3D4FC),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(
                      Icons.location_city_rounded,
                      size: 64,
                      color: Colors.white70,
                    ),
                  );
                },
              ),
            ),
            // Gradient Putih dari kiri ke kanan agar teks tetap terbaca jelas
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.white,
                      Colors.white,
                      Colors.white.withValues(alpha: 0.75),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                    stops: const [0.0, 0.48, 0.65, 1.0],
                  ),
                ),
              ),
            ),
            // Konten Utama Card
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          community.thumbnailAsset,
                          width: 74,
                          height: 74,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 74,
                              height: 74,
                              color: const Color(0xFF3E4E3A),
                              child: const Icon(
                                Icons.groups_rounded,
                                color: Colors.white,
                                size: 36,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                community.name,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1E1E1E),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                community.memberCountText,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF2C2C2C),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 38,
                    child: ElevatedButton(
                      onPressed: onJoinTap ?? onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryMaroon,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(19),
                        ),
                      ),
                      child: const Text(
                        'Gabung',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}