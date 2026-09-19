import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/order_model.dart';

class OrderStatusTimeline extends StatelessWidget {
  final OrderModel order;
  final String chatLabel;

  const OrderStatusTimeline({
    super.key,
    required this.order,
    required this.chatLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: order.statusBackgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.statusText,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: order.statusColor,
                  ),
                ),
                SvgPicture.asset(
                  _getStatusHeaderIconPath(),
                  width: 32,
                  height: 32,
                  colorFilter: ColorFilter.mode(order.statusColor, BlendMode.srcIn),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildTimelineVisual(),
          const SizedBox(height: 20),
          const Divider(thickness: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey.shade300,
                radius: 18,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  chatLabel,
                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.chat_bubble_outline, color: Colors.black87),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getStatusHeaderIconPath() {
    switch (order.status) {
      case OrderStatus.dibuat:
        return 'assets/images/ic_inbox.svg';
      case OrderStatus.dibayar:
        return 'assets/images/ic_receipt.svg';
      case OrderStatus.dikirim:
        return 'assets/images/ic_truck.svg';
      case OrderStatus.selesai:
        return 'assets/images/ic_check.svg';
    }
  }

  Widget _buildTimelineVisual() {
    final int currentIndex = order.status.index;
    final Color activeColor = order.statusColor;
    final Color inactiveColor = Colors.grey.shade400;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          _buildTimelineSvg('assets/images/ic_inbox.svg', currentIndex >= 0 ? activeColor : inactiveColor),
          _buildTimelineLine(currentIndex >= 1 ? activeColor : inactiveColor),
          _buildTimelineSvg('assets/images/ic_receipt.svg', currentIndex >= 1 ? activeColor : inactiveColor),
          _buildTimelineLine(currentIndex >= 2 ? activeColor : inactiveColor),
          _buildTimelineSvg('assets/images/ic_truck.svg', currentIndex >= 2 ? activeColor : inactiveColor),
          _buildTimelineLine(currentIndex >= 3 ? activeColor : inactiveColor),
          _buildTimelineSvg('assets/images/ic_check.svg', currentIndex >= 3 ? activeColor : inactiveColor),
        ],
      ),
    );
  }

  Widget _buildTimelineSvg(String assetPath, Color color) {
    return SvgPicture.asset(
      assetPath,
      width: 20,
      height: 20,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }

  Widget _buildTimelineLine(Color color) {
    return Expanded(
      child: Container(
        height: 2,
        color: color,
        margin: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }
}