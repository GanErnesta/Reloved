import 'package:flutter/material.dart';
import '../models/community_post_model.dart';
import 'community_product_attachment.dart';

class CommunityPostCard extends StatelessWidget {
  final CommunityPostModel post;
  final VoidCallback? onPostTap;
  final VoidCallback? onCommentTap;
  final VoidCallback? onLikeTap;
  final VoidCallback? onShareTap;
  final VoidCallback? onProductTap;

  const CommunityPostCard({
    super.key,
    required this.post,
    this.onPostTap,
    this.onCommentTap,
    this.onLikeTap,
    this.onShareTap,
    this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPostTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Author
            Row(
              children: [
                CircleAvatar(
                  radius: 21,
                  backgroundColor: const Color(0xFFEEEEEE),
                  backgroundImage: AssetImage(post.authorAvatar),
                  onBackgroundImageError: (_, __) {},
                  child: const Icon(
                    Icons.person,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            post.authorName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                          if (post.isVerified) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.check_circle_outline_rounded,
                              size: 15,
                              color: Color(0xFF8B3A46),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        post.timeAgo,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Konten Teks Postingan
            Text(
              post.content,
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
                color: Color(0xFF42474E),
              ),
            ),
            // Product Attachment ("Keranjang Kuning")
            if (post.attachedProduct != null) ...[
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: CommunityProductAttachment(
                  product: post.attachedProduct!,
                  onTap: onProductTap,
                ),
              ),
            ],
            const SizedBox(height: 10),
            // Baris Aksi (Like, Comment, Share)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                children: [
                  InkWell(
                    onTap: onLikeTap,
                    borderRadius: BorderRadius.circular(12),
                    child: Row(
                      children: [
                        Icon(
                          post.isLiked
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: 16,
                          color: post.isLiked
                              ? const Color(0xFF9B2335)
                              : const Color(0xFF9E9E9E),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${post.likeCount}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9E9E9E),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  InkWell(
                    onTap: onCommentTap ?? onPostTap,
                    borderRadius: BorderRadius.circular(12),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 15,
                          color: Color(0xFF9E9E9E),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${post.commentCount}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9E9E9E),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: onShareTap,
                    borderRadius: BorderRadius.circular(12),
                    child: const Icon(
                      Icons.share_outlined,
                      size: 16,
                      color: Color(0xFF9E9E9E),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Divider(
              height: 1,
              thickness: 1,
              color: Color(0xFFF0F0F0),
            ),
          ],
        ),
      ),
    );
  }
}