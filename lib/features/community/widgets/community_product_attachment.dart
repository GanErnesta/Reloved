import 'package:flutter/material.dart';
import '../models/community_post_model.dart';

class CommunityProductAttachment extends StatelessWidget {
  final AttachedProductModel product;
  final VoidCallback? onTap;

  const CommunityProductAttachment({
    super.key,
    required this.product,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF9EC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE09F41),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.shopping_cart_outlined,
              color: Color(0xFFE59428),
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFA62B38),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.price,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFE59428),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFE59428),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}