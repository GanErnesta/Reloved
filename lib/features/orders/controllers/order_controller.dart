import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../models/safe_meeting_point_model.dart';
import '../repositories/order_repository.dart';

class OrderController extends ChangeNotifier {
  static final OrderController instance = OrderController._internal();
  factory OrderController() => instance;

  OrderController._internal() {
    loadBuyerOrders();
  }

  final OrderRepository _repository = OrderRepository();

  List< OrderModel > _orders = [];
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future< void > loadBuyerOrders() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Memanggil fetchBuyerOrders dengan argumen 'beli' dan 'sewa'
      final rawBeli = await _repository.fetchBuyerOrders('beli');
      final rawSewa = await _repository.fetchBuyerOrders('sewa');

      final combined = < Map< String, dynamic > >[
        ...rawBeli,
        ...rawSewa,
      ];

      _orders = combined
          .map((row) => OrderModel.fromSupabaseMap(row))
          .toList();
    } catch (e) {
      debugPrint('Error loadBuyerOrders: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List< OrderModel > getOrdersByType(OrderType type) {
    return _orders
        .where((o) => o.orderType == type && o.status != OrderStatus.dibatalkan)
        .toList();
  }

  void addOrder(OrderModel newOrder) {
    _orders.insert(0, newOrder);
    notifyListeners();
  }

  Future< void > cancelOrder(String orderId) async {
    try {
      await _repository.cancelOrderByBuyer(orderId);
      await loadBuyerOrders();
    } catch (e) {
      debugPrint('Error cancelOrder: $e');
    }
  }

  Future< void > updateSafeMeetingPoint(
      String orderId,
      SafeMeetingPointModel newPoint,
      ) async {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1 && _orders[index].status == OrderStatus.menunggu) {
      _orders[index].safeMeetingPoint = newPoint;
      notifyListeners();
      try {
        await _repository.updateOrderSafeMeetingPoint(
          orderId: orderId,
          safeMeetingPointId: newPoint.id,
        );
      } catch (e) {
        debugPrint('Error updateSafeMeetingPoint: $e');
      }
    }
  }
}