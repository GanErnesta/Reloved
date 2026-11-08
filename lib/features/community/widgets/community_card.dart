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
    return Container(
      height: 156,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFEEEEEE),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            spreadRadius: 0.5,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Material(
          color: Colors.white,
          child: InkWell(
            onTap: onTap,
            child: Stack(
              children: [
                // Gambar background di sisi kanan dengan ShaderMask
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  width: 230,
                  child: ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.15),
                          Colors.black.withValues(alpha: 0.65),
                          Colors.black,
                        ],
                        stops: const [0.0, 0.25, 0.55, 0.85],
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.dstIn,
                    child: Image.asset(
                      community.backgroundAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0xFF8BB8F8),
                                Color(0xFFC7DDFB),
                              ],
                            ),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 24),
                          child: const Icon(
                            Icons.account_balance_rounded,
                            size: 64,
                            color: Colors.white70,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Lapisan gradasi tambahan
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.white,
                          Colors.white.withValues(alpha: 0.92),
                          Colors.white.withValues(alpha: 0.35),
                          Colors.white.withValues(alpha: 0.0),
                        ],
                        stops: const [0.0, 0.42, 0.68, 0.92],
                      ),
                    ),
                  ),
                ),
                // Konten Utama
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
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
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
        ),
      ),
    );
  }
}