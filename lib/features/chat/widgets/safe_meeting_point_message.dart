
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_text_styles.dart';

class SafeMeetingPointMessage extends StatelessWidget {
  final List<Map<String, dynamic>> locations;
  final String time;
  final bool isMe;

  const SafeMeetingPointMessage({
    super.key,
    required this.locations,
    required this.time,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 285),
        margin: EdgeInsets.only(
          left: isMe ? 70 : 12,
          right: isMe ? 12 : 70,
          bottom: 8,
        ),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFFFCE4B8) : AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(AppRadius.lg),
            topRight: const Radius.circular(AppRadius.lg),
            bottomLeft: Radius.circular(isMe ? AppRadius.lg : 4),
            bottomRight: Radius.circular(isMe ? 4 : AppRadius.lg),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Sistem Keamanan Reloved: Titik temu disepakati di:',
              style: AppTextStyles.body.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            ...locations.map((location) {
              final imageUrl = location['image_url']?.toString() ?? '';

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (imageUrl.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageUrl,
                          width: 220,
                          height: 110,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _imagePlaceholder(),
                        ),
                      )
                    else
                      _imagePlaceholder(),
                    const SizedBox(height: 6),
                    Text(
                      location['name']?.toString() ?? '',
                      style: AppTextStyles.body.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      location['full_address']?.toString() ?? '',
                      style: AppTextStyles.body.copyWith(
                        fontSize: 11,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              );
            }),
            Text(
              time,
              style: AppTextStyles.caption.copyWith(
                fontSize: 10,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 220,
      height: 110,
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.location_on,
        size: 35,
        color: Colors.grey,
      ),
    );
  }
}
