import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_text_styles.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final String time;
  final bool isMe;
  final bool isRead;
  final String? imageUrl;

  const ChatBubble({
    super.key,
    required this.message,
    required this.time,
    required this.isMe,
    this.isRead = false,
    this.imageUrl,
  });

  void _showFullImage(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) return;

    showDialog(
      context: context,
      barrierColor: Colors.black,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 4,
                  child: Image.network(
                    imageUrl!,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;

                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.broken_image_outlined,
                        color: Colors.white,
                        size: 50,
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                top: 35,
                right: 20,
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isImage = imageUrl != null && imageUrl!.isNotEmpty;
    final hasCaption =
        message.trim().isNotEmpty && message.trim() != 'Foto lokasi';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 215),
        margin: EdgeInsets.only(
          left: isMe ? 70 : 10,
          right: isMe ? 12 : 70,
          bottom: 8,
        ),
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 7),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFFFCE4B8) : const Color(0xFFFFF1E8),
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
            if (isImage) ...[
              GestureDetector(
                onTap: () => _showFullImage(context),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    imageUrl!,
                    width: 250,
                    height: 190,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;

                      return const SizedBox(
                        width: 250,
                        height: 190,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const SizedBox(
                        width: 250,
                        height: 150,
                        child: Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              if (hasCaption)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 4,
                      right: 4,
                      top: 8,
                      bottom: 2,
                    ),
                    child: Text(
                      message,
                      style: AppTextStyles.body.copyWith(
                        fontSize: 14,
                        height: 1.3,
                      ),
                    ),
                  ),
                ),
            ] else
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  child: Text(
                    message,
                    style: AppTextStyles.body.copyWith(
                      fontSize: 14,
                      height: 1.3,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 4),
            Padding(
              padding: EdgeInsets.only(left: isMe ? 5 : 0, right: 5),
              child: Row(
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
                    Icon(
                      Icons.done_all,
                      color: isRead ? AppColors.primary : Colors.grey,
                      size: 15,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
