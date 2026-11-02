import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_text_styles.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final String time;
  final bool isMe;

  const ChatBubble({
    super.key,
    required this.message,
    required this.time,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment:
          isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 285,
        ),
        margin: EdgeInsets.only(
          left: isMe ? 70 : 12,
          right: isMe ? 12 : 70,
          bottom: 8,
        ),
        padding: const EdgeInsets.fromLTRB(
          16,
          10,
          14,
          7,
        ),
        decoration: BoxDecoration(
          color: isMe
              ? const Color(0xFFFCE4B8)
              : AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(
              AppRadius.lg,
            ),
            topRight: const Radius.circular(
              AppRadius.lg,
            ),
            bottomLeft: Radius.circular(
              isMe ? AppRadius.lg : 4,
            ),
            bottomRight: Radius.circular(
              isMe ? 4 : AppRadius.lg,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                message,
                style: AppTextStyles.body.copyWith(
                  fontSize: 14,
                  height: 1.3,
                ),
              ),
            ),
            const SizedBox(height: 3),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 10,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.done_all,
                    color: Color(0xFFFFA000),
                    size: 15,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}