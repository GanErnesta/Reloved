import 'package:flutter/material.dart';
import '../models/community_comment_model.dart';

class CommunityCommentItem extends StatelessWidget {
  final CommunityCommentModel comment;
  final VoidCallback onLikeToggle;

  const CommunityCommentItem({
    super.key,
    required this.comment,
    required this.onLikeToggle,
  });

  static const Color _primaryMaroon = Color(0xFF9B2335);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipOval(
            child: Image.asset(
              comment.authorAvatar,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 40,
                  height: 40,
                  color: const Color(0xFFEEEEEE),
                  child: const Icon(
                    Icons.person,
                    color: Colors.grey,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.authorName,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  comment.content,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.35,
                    color: Color(0xFF2C2C2C),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onLikeToggle,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  comment.isLiked
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: _primaryMaroon,
                  size: 26,
                ),
                const SizedBox(height: 2),
                Text(
                  '${comment.likeCount}',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}