import 'dart:ui';

import 'package:flutter/material.dart';

class PageIndicator extends StatelessWidget {
  final PageController controller;

  const PageIndicator({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        double page = 0;

        if (controller.hasClients) {
          page = controller.page ?? controller.initialPage.toDouble();
        }

        return Row(
          children: List.generate(
            3,
            (index) {
              final progress =
                  (1 - (page - index).abs()).clamp(0.0, 1.0);

              final width = lerpDouble(8, 22, progress)!;

              return Container(
                margin: const EdgeInsets.only(right: 8),
                width: width,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100),
                ),
              );
            },
          ),
        );
      },
    );
  }
}