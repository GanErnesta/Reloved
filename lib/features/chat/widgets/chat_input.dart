
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_text_styles.dart';

class ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onAdd;
  final VoidCallback? onSend;
  final VoidCallback? onRemoveImage;
  final XFile? selectedImage;
  final bool isSending;

  const ChatInput({
    super.key,
    required this.controller,
    this.onAdd,
    this.onSend,
    this.onRemoveImage,
    this.selectedImage,
    this.isSending = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (selectedImage != null)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(selectedImage!.path),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: isSending ? null : onRemoveImage,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              GestureDetector(
                onTap: isSending ? null : onAdd,
                child: Icon(
                  Icons.camera_alt_outlined,
                  color: isSending
                      ? Colors.grey
                      : AppColors.primary,
                  size: 29,
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
                  alignment: Alignment.center,
                  child: TextField(
                    controller: controller,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) {
                      if (!isSending) onSend?.call();
                    },
                    maxLines: 1,
                    enabled: !isSending,
                    cursorColor: AppColors.primary,
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
                  final canSend =
                      (value.text.trim().isNotEmpty ||
                          selectedImage != null) &&
                      !isSending;

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
                            : const Icon(
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
        ],
      ),
    );
  }
}
