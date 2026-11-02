
import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';

class PromoBanner extends StatelessWidget {
  final VoidCallback onTap;

  const PromoBanner({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        16,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 74,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFFF5F4),
                  Color(0xFFE8C1C8),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                Positioned(
                  left: 12,
                  top: 0,
                  bottom: 0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'HAH! MUSIM MABA',
                        style: TextStyle(
                          color: Color(0xFFB52D43),
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const SizedBox(
                        width: 185,
                        child: Text(
                          'Lihat barang terbaru mulai dari Agustus hingga September',
                          style: TextStyle(
                            color: Color(0xFFB52D43),
                            fontSize: 10.5,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 35,
                  bottom: -3,
                  child: Image.asset(
                    'assets/images/imgpromomaba.png',
                    width: 90,
                    height: 76,
                    fit: BoxFit.contain,
                  ),
                ),
                const Positioned(
                  right: 8,
                  top: 0,
                  bottom: 0,
                  child: Icon(
                    Icons.arrow_forward,
                    color: Color(0xFFB52D43),
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
