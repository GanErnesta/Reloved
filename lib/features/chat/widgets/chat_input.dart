import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_text_styles.dart';

class ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onAdd;
  final VoidCallback? onEmoji;

  const ChatInput({
    super.key,
    required this.controller,
    this.onAdd,
    this.onEmoji,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        16,
        8,
        16,
        12,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onAdd,
            child: const Icon(
              Icons.add_circle_outline,
              color: AppColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF2DDE1),
                borderRadius: BorderRadius.circular(
                  AppRadius.xl,
                ),
              ),
              child: TextField(
                controller: controller,
                style: AppTextStyles.body.copyWith(
                  fontSize: 13,
                ),
                decoration: InputDecoration(
                  hintText: 'Mulai percakapan...',
                  hintStyle: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary.withValues(
                      alpha: 0.55,
                    ),
                    fontSize: 13,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onEmoji,
            child: const Icon(
              Icons.sentiment_satisfied_alt_outlined,
              color: AppColors.primary,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }
}