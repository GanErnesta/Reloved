import 'package:flutter/material.dart';

class CommunityEmptySearch extends StatelessWidget {
  final String imageAsset;
  final String message;

  const CommunityEmptySearch({
    super.key,
    this.imageAsset = 'assets/images/community_empty_search.png',
    this.message = 'Komunitas yang kamu cari\ntidak ada nih, yuk cari lagi!',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              imageAsset,
              width: 170,
              height: 170,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 150,
                  height: 150,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFDF6EE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.sentiment_dissatisfied_rounded,
                    size: 72,
                    color: Color(0xFFC47B83),
                  ),
                );
              },
            ),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
                fontWeight: FontWeight.w400,
                color: Color(0xFF6E6E6E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}