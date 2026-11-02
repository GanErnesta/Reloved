import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/seller_order_model.dart';

class SellerFilterChips extends StatelessWidget {
  final SellerOrderMode mode;
  final int selectedIndex;
  final int pendingCount;
  final ValueChanged<int> onSelected;

  const SellerFilterChips({
    super.key,
    required this.mode,
    required this.selectedIndex,
    required this.pendingCount,
    required this.onSelected,
  });

  List<String> get _tabs {
    if (mode == SellerOrderMode.penjualan) {
      return const ['Semua', 'Baru', 'Siap COD', 'Selesai'];
    } else {
      return const ['Semua', 'Permintaan', 'Aktif', 'Kembali', 'Selesai'];
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabs = _tabs;

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final bool isSelected = selectedIndex == index;
          final bool showBadge = index == 1 && pendingCount > 0;

          return GestureDetector(
            onTap: () => onSelected(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFDCC3C6)
                    : const Color(0xFFF2ECEB),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tabs[index],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isSelected
                          ? AppColors.primary
                          : const Color(0xFF4A4A4A),
                    ),
                  ),
                  if (showBadge) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1.5,
                      ),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE53935),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$pendingCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}