import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/order_model.dart';

class OrderStatusHeaderCard extends StatelessWidget {
  final OrderStatus status;
  final String shopName;
  final String shopAvatarPath;
  final VoidCallback onChatTap;

  const OrderStatusHeaderCard({
    super.key,
    required this.status,
    required this.shopName,
    required this.shopAvatarPath,
    required this.onChatTap,
  });

  int get _activeStepIndex {
    switch (status) {
      case OrderStatus.menunggu:
        return 0;
      case OrderStatus.dikirim:
        return 1;
      case OrderStatus.terkirim:
        return 2;
      case OrderStatus.selesai:
        return 3;
      case OrderStatus.dibatalkan:
        return -1;
    }
  }

  String get _statusTitle {
    switch (status) {
      case OrderStatus.menunggu:
        return 'Menunggu';
      case OrderStatus.dikirim:
        return 'Dikirim';
      case OrderStatus.terkirim:
        return 'Terkirim';
      case OrderStatus.selesai:
        return 'Selesai';
      case OrderStatus.dibatalkan:
        return 'Dibatalkan';
    }
  }

  IconData get _bannerIcon {
    switch (status) {
      case OrderStatus.menunggu:
        return Icons.access_time_rounded;
      case OrderStatus.dikirim:
        return Icons.local_shipping_outlined;
      case OrderStatus.terkirim:
        return Icons.inventory_2_outlined;
      case OrderStatus.selesai:
        return Icons.check_circle_outline_rounded;
      case OrderStatus.dibatalkan:
        return Icons.cancel_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDone = status == OrderStatus.selesai;
    final Color activeColor =
    isDone ? AppColors.statusSuccess : AppColors.statusWarning;
    final Color bannerBgColor =
    isDone ? AppColors.statusSuccessBg : AppColors.statusWarningBg;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // 1. Banner Status Besar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: bannerBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _statusTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: activeColor,
                  ),
                ),
                Icon(
                  _bannerIcon,
                  size: 34,
                  color: activeColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2. Bar Progress 4 Status: Menunggu -> Dikirim -> Terkirim -> Selesai
          Row(
            children: [
              _buildStepIcon(
                icon: Icons.access_time_rounded,
                stepIndex: 0,
                activeColor: activeColor,
              ),
              _buildConnectorLine(stepIndex: 1, activeColor: activeColor),
              _buildStepIcon(
                icon: Icons.local_shipping_outlined,
                stepIndex: 1,
                activeColor: activeColor,
              ),
              _buildConnectorLine(stepIndex: 2, activeColor: activeColor),
              _buildStepIcon(
                icon: Icons.inventory_2_outlined,
                stepIndex: 2,
                activeColor: activeColor,
              ),
              _buildConnectorLine(stepIndex: 3, activeColor: activeColor),
              _buildStepIcon(
                icon: Icons.check_circle_outline_rounded,
                stepIndex: 3,
                activeColor: activeColor,
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 12),

          // 3. Baris Chat Toko (Hanya 1 yaitu tokonya sendiri)
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primaryLight,
                backgroundImage: AssetImage(shopAvatarPath),
                onBackgroundImageError: (_, __) {},
                child: const Icon(
                  Icons.storefront_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '$shopName (Penjual)',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                onPressed: onChatTap,
                icon: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: AppColors.textPrimary,
                  size: 22,
                ),
                tooltip: 'Chat Toko',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepIcon({
    required IconData icon,
    required int stepIndex,
    required Color activeColor,
  }) {
    final bool isReached = _activeStepIndex >= stepIndex;
    return Icon(
      icon,
      size: 22,
      color: isReached ? activeColor : AppColors.disabledText,
    );
  }

  Widget _buildConnectorLine({
    required int stepIndex,
    required Color activeColor,
  }) {
    final bool isReached = _activeStepIndex >= stepIndex;
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        height: 2.5,
        decoration: BoxDecoration(
          color: isReached ? activeColor : AppColors.disabledBg,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}