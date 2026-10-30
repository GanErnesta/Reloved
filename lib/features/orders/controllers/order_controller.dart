import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../models/safe_meeting_point_model.dart';

class OrderController extends ChangeNotifier {
  static final OrderController instance = OrderController._internal();
  factory OrderController() => instance;
  OrderController._internal();

  final List<OrderModel> _orders = [
    OrderModel(
      id: 'ORD-001',
      shopId: 'SHOP-FILKOM',
      shopName: 'FilkomShop',
      shopAvatarPath: 'assets/images/shop_avatar.png',
      orderType: OrderType.beli,
      status: OrderStatus.menunggu,
      items: const [
        OrderItemModel(
          id: 'ITM-1',
          productName: 'Kemeja Putih Lengan Panjang',
          imagePath: 'assets/images/kemeja_putih.png',
          price: 102900,
          quantity: 1,
          variant: 'Putih, L',
        ),
        OrderItemModel(
          id: 'ITM-2',
          productName: 'Celana Bahan Hitam Formal',
          imagePath: 'assets/images/celana_hitam.png',
          price: 100000,
          quantity: 1,
          variant: 'Hitam, XL',
        ),
      ],
      orderDateText: 'Rabu, 23 September 2026, 09:15 WIB',
      receivedDateText: 'Sabtu, 26 September 2026, 14:20 WIB',
      pickupAddress:
      'Area Ketawanggede, Kecamatan Lowokwaru, Kota Malang, Provinsi Jawa Timur.',
      safeMeetingPoint: SafeMeetingPointModel.campusPoints[0],
      buyerAccountInfo: 'falishakeyrani - falishakeyrani@student.ub.ac.id',
      productSubtotal: 202900,
      shippingFee: 5000,
      discount: 0,
      paymentMethod: 'QRIS',
    ),
    OrderModel(
      id: 'ORD-002',
      shopId: 'SHOP-FILKOM',
      shopName: 'FilkomShop',
      shopAvatarPath: 'assets/images/shop_avatar.png',
      orderType: OrderType.sewa,
      status: OrderStatus.dikirim,
      items: const [
        OrderItemModel(
          id: 'ITM-4',
          productName: 'Kemeja Putih',
          imagePath: 'assets/images/kemeja_putih.png',
          price: 49900,
          quantity: 1,
          variant: 'Putih, M',
        ),
      ],
      orderDateText: 'Rabu, 23 September 2026',
      receivedDateText: 'Sabtu, 26 September 2026',
      rentalDurationDays: 3,
      rentalRemainingText: '1 hari lagi',
      rentalReturnDateText: 'Sabtu, 26 September 2026',
      pickupAddress:
      'Area Ketawanggede, Kecamatan Lowokwaru, Kota Malang, Provinsi Jawa Timur.',
      safeMeetingPoint: SafeMeetingPointModel.campusPoints[0],
      buyerAccountInfo: 'falishakeyrani - falishakeyrani@student.ub.ac.id',
      productSubtotal: 49900,
      shippingFee: 5000,
      discount: 0,
      paymentMethod: 'QRIS',
    ),
  ];

  List<OrderModel> getOrdersByType(OrderType type) {
    return _orders
        .where((o) => o.orderType == type && o.status != OrderStatus.dibatalkan)
        .toList();
  }

  void addOrder(OrderModel newOrder) {
    _orders.insert(0, newOrder);
    notifyListeners();
  }

  Future<void> cancelOrder(String orderId) async {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1 && _orders[index].status == OrderStatus.menunggu) {
      _orders[index].status = OrderStatus.dibatalkan;
      notifyListeners();
    }
  }

  /// Mengubah Safe Meeting Point (Hanya jika status == menunggu)
  Future<void> updateSafeMeetingPoint(
      String orderId,
      SafeMeetingPointModel newPoint,
      ) async {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1 && _orders[index].status == OrderStatus.menunggu) {
      _orders[index].safeMeetingPoint = newPoint;
      notifyListeners();
    }
  }
}