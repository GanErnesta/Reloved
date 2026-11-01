import 'package:flutter/material.dart';

class CommunityCommentInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const CommunityCommentInput({
    super.key,
    required this.controller,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 3,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1E1E1E),
                ),
                decoration: const InputDecoration(
                  hintText: 'Kirim pesan disini',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6E6E6E),
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
                onSubmitted: (_) => onSend(),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: onSend,
              borderRadius: BorderRadius.circular(20),
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(
                  Icons.send_outlined,
                  size: 20,
                  color: Color(0xFF424242),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}