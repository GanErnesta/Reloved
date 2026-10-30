import 'package:flutter/material.dart';

class BuyerTrustScoreBadge extends StatelessWidget {
  final int score;

  const BuyerTrustScoreBadge({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFE4F6E8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.shield_outlined,
            size: 13,
            color: Color(0xFF2E9B4F),
          ),
          const SizedBox(width: 4),
          Text(
            '$score',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2E9B4F),
            ),
          ),
        ],
      ),
    );
  }
}