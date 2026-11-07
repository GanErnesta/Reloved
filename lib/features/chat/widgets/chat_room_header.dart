
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

class ChatRoomHeader extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  final VoidCallback onBack;
  final VoidCallback onMore;

  const ChatRoomHeader({
    super.key,
    required this.name,
    this.avatarUrl,
    required this.onBack,
    required this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    final hasAvatar = avatarUrl != null && avatarUrl!.isNotEmpty;

    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: onBack,
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.primary,
                size: 21,
              ),
            ),
            const SizedBox(width: 18),
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFF1E4E7),
              backgroundImage:
                  hasAvatar ? NetworkImage(avatarUrl!) : null,
              child: hasAvatar
                  ? null
                  : const Icon(
                      Icons.person,
                      color: AppColors.primary,
                      size: 20,
                    ),
            ),
            
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 11,
              height: 11,
              decoration: const BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: onMore,
              child: const Icon(
                Icons.more_vert,
                color: Colors.black,
                size: 25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
