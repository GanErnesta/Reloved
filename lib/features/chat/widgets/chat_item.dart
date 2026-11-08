
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

class ChatItem extends StatelessWidget {
  final String name;
  final String message;
  final String date;
  final String? avatarUrl;
  final int unreadCount;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool selected;
  final bool selectionMode;
  final bool isLastMessageMine;
  final bool isLastMessageRead;

  const ChatItem({
    super.key,
    required this.name,
    required this.message,
    required this.date,
    this.avatarUrl,
    this.unreadCount = 0,
    this.onTap,
    this.onLongPress,
    this.selected = false,
    this.selectionMode = false,
    this.isLastMessageMine = false,
    this.isLastMessageRead = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? const Color(0xFF9F283A).withValues(alpha: 0.08)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 8,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (selectionMode) ...[
                _buildSelectionIndicator(),
                const SizedBox(width: 12),
              ],
              _buildAvatar(),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          date,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        if (isLastMessageMine) ...[
                          Icon(
                            Icons.done_all,
                            color: isLastMessageRead
                                ? const Color(0xFF9F283A)
                                : Colors.grey,
                            size: 15,
                          ),
                          const SizedBox(width: 4),
                        ],
                        Expanded(
                          child: Text(
                            message,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.body.copyWith(
                              fontSize: 12,
                              height: 1.2,
                            ),
                          ),
                        ),
                        if (unreadCount > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            constraints: const BoxConstraints(
                              minWidth: 20,
                              minHeight: 20,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: Color(0xFF9F283A),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              unreadCount > 99
                                  ? '99+'
                                  : unreadCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionIndicator() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? const Color(0xFF9F283A) : Colors.transparent,
        border: Border.all(
          color: selected
              ? const Color(0xFF9F283A)
              : AppColors.textSecondary.withValues(alpha: 0.6),
          width: 1.5,
        ),
      ),
      child: selected
          ? const Icon(
              Icons.check,
              color: Colors.white,
              size: 15,
            )
          : null,
    );
  }

  Widget _buildAvatar() {
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 28,
        backgroundImage: NetworkImage(avatarUrl!),
      );
    }

    return const CircleAvatar(
      radius: 28,
      backgroundColor: Color(0xFFD9D9D9),
    );
  }
}
