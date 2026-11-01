import 'package:flutter/material.dart';

class SellerSafeMeetingPill extends StatelessWidget {
  final String meetingPointName;

  const SellerSafeMeetingPill({
    super.key,
    required this.meetingPointName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFF6EFE2),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF6E5D4F),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.location_on_rounded,
            size: 16,
            color: Color(0xFF4E3B2B),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              meetingPointName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4E3B2B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}