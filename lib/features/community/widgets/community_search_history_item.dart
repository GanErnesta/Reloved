import 'package:flutter/material.dart';

class CommunitySearchHistoryItem extends StatelessWidget {
  final String keyword;
  final VoidCallback onTap;

  const CommunitySearchHistoryItem({
    super.key,
    required this.keyword,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Row(
          children: [
            const Icon(
              Icons.history_rounded,
              size: 26,
              color: Color(0xFF1E1E1E),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                keyword,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF1E1E1E),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}