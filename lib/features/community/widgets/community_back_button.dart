import 'package:flutter/material.dart';

class CommunityBackButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Color backgroundColor;
  final Color iconColor;

  const CommunityBackButton({
    super.key,
    this.onTap,
    this.backgroundColor = const Color(0xFFF6EEEE),
    this.iconColor = const Color(0xFF4A4A4A),
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap ?? () => Navigator.of(context).maybePop(),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            Icons.chevron_left_rounded,
            color: iconColor,
            size: 28,
          ),
        ),
      ),
    );
  }
}