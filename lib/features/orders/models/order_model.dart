import 'package:flutter/material.dart';

enum OrderStatus { dibuat, dibayar, dikirim, selesai }
enum OrderType { beli, jual, sewa }

class OrderModel {
  final String id;
  final String productName;
  final String shopName;
  final String counterpartName;
  final String description;
  final double price;
  final String imageUrl;
  final OrderStatus status;
  final OrderType type;

  OrderModel({
    required this.id,
    required this.productName,
    required this.shopName,
    required this.counterpartName,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.status,
    required this.type,
  });

  String get statusText {
    switch (status) {
      case OrderStatus.dibuat:
        return 'Dibuat';
      case OrderStatus.dibayar:
        return 'Dibayar';
      case OrderStatus.dikirim:
        return 'Dikirim';
      case OrderStatus.selesai:
        return 'Selesai';
    }
  }

  Color get statusColor {
    if (status == OrderStatus.selesai) {
      return const Color(0xFF4CAF50);
    }
    return const Color(0xFFF2A63B);
  }

  Color get statusBackgroundColor {
    if (status == OrderStatus.selesai) {
      return const Color(0xFFE8F5E9);
    }
    return const Color(0xFFFFF8ED);
  }
}