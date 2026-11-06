import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_text_styles.dart';

class ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onAdd;
  final VoidCallback? onSend;
  final bool isSending;

  const ChatInput({
    super.key,
    required this.controller,
    this.onAdd,
    this.onSend,
    this.isSending = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: const BoxDecoration(color: AppColors.surface),
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
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF2DDE1),
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              alignment: Alignment.center,
              child: TextField(
                controller: controller,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend?.call(),
                maxLines: 1,
                cursorColor: AppColors.primary,
                style: AppTextStyles.body.copyWith(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Mulai percakapan...',
                  hintStyle: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary.withValues(alpha: 0.55),
                    fontSize: 13,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  filled: false,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, child) {
              final canSend = value.text.trim().isNotEmpty && !isSending;

              return GestureDetector(
                onTap: canSend ? onSend : null,
                child: SizedBox(
                  width: 36,
                  height: 36,
                  child: Center(
                    child: isSending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          )
                        : Icon(
                            Icons.send_rounded,
                            color: AppColors.primary,
                            size: 23,
                          ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
