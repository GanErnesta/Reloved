import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/order_model.dart';

class OrderStatusBadge extends StatelessWidget {
  final OrderStatus status;

  const OrderStatusBadge({super.key, required this.status});

  String get _label {
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

  Color get _backgroundColor {
    if (status == OrderStatus.selesai) {
      return AppColors.statusSuccess;
    }
    // Menunggu, Dikirim, dan Terkirim berwarna kuning sesuai spesifikasi
    return AppColors.statusWarning;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}