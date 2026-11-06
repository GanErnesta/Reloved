import 'package:flutter/material.dart';

class CommunitySearchLoading extends StatefulWidget {
  final String message;

  const CommunitySearchLoading({
    super.key,
    this.message = 'Sedang mencari...',
  });

  @override
  State<CommunitySearchLoading> createState() => _CommunitySearchLoadingState();
}

class _CommunitySearchLoadingState extends State<CommunitySearchLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const Color _primaryMaroon = Color(0xFF9B2335);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (index) {
                  final double phase = (_controller.value * 3 - index) % 3;
                  final double scale =
                  phase >= 0 && phase < 1 ? 0.75 + (0.25 * (1 - (phase - 0.5).abs() * 2)) : 0.85;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: _primaryMaroon,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                }),
              );
            },
          ),
          const SizedBox(height: 12),
          Text(
            widget.message,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Color(0xFF2C2C2C),
            ),
          ),
        ],
      ),
    );
  }
}