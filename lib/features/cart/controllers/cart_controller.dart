import 'package:flutter/material.dart';
import '../../orders/controllers/order_controller.dart';
import '../../orders/models/order_model.dart';
import '../../orders/models/safe_meeting_point_model.dart';
import '../models/cart_model.dart';
import '../repositories/cart_repository.dart';

class CartController extends ChangeNotifier {
  static final CartController instance = CartController._internal();
  factory CartController() => instance;

  CartController._internal() {
    loadCartFromSupabase();
  }

  final CartRepository _repository = CartRepository();

  PendingPaymentSession? _activePaymentSession;
  PendingPaymentSession? get activePaymentSession => _activePaymentSession;

  bool get hasPendingPayment => _activePaymentSession != null;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<CartItemModel> _items = [];
  List<SafeMeetingPointModel> _meetingPoints =
      SafeMeetingPointModel.campusPoints;
  List<SafeMeetingPointModel> get meetingPoints => _meetingPoints;

  Future<void> loadCartFromSupabase() async {
    _isLoading = true;
    notifyListeners();

    // 1. Ambil daftar titik temu (Safe Meeting Points) secara independen
    try {
      final dbPoints = await _repository.fetchSafeMeetingPoints();
      if (dbPoints.isNotEmpty) {
        _meetingPoints = dbPoints;
      }
    } catch (e) {
      debugPrint('Info fetchSafeMeetingPoints: $e');
    }

    // 2. Cek sesi pembayaran pending secara independen
    try {
      final pendingMap = await _repository.fetchActivePaymentSession();
      if (pendingMap != null) {
        final expiresAt =
            DateTime.tryParse(pendingMap['expires_at'].toString())?.toLocal() ??
                DateTime.now().add(const Duration(minutes: 30));

        if (DateTime.now().isAfter(expiresAt)) {
          await _repository.cancelOrExpireSession(pendingMap['id'].toString());
          _activePaymentSession = null;
        } else {
          final smpData =
          pendingMap['safe_meeting_points'] as Map<String, dynamic>?;
          _activePaymentSession = PendingPaymentSession(
            sessionId: pendingMap['id'].toString(),
            checkedOutItems: const [],
            safeMeetingPoint: smpData != null
                ? SafeMeetingPointModel.fromMap(smpData)
                : _meetingPoints.first,
            pickupAddress: 'Area Ketawanggede, Malang',
            buyerAccountInfo: 'Mahasiswa UB',
            paymentMethod: (pendingMap['payment_method'] ?? 'QRIS').toString(),
            productSubtotal:
            ((pendingMap['product_subtotal'] ?? 0) as num).toInt(),
            shippingFee: ((pendingMap['shipping_fee'] ?? 5000) as num).toInt(),
            discount: ((pendingMap['discount'] ?? 0) as num).toInt(),
            expiresAt: expiresAt,
            midtransOrderId: pendingMap['midtrans_order_id']?.toString(),
          );
        }
      }
    } catch (e) {
      debugPrint('Info fetchActivePaymentSession: $e');
    }

    // 3. Ambil daftar barang di keranjang (Selalu dijalankan)
    try {
      _items = await _repository.fetchCartItems();
    } catch (e) {
      debugPrint('Error fetchCartItems: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<CartItemModel> getFilteredItems(OrderType? filterType) {
    final filtered = filterType == null
        ? List<CartItemModel>.from(_items)
        : _items.where((i) => i.type == filterType).toList();

    filtered.sort((a, b) => b.addedAt.compareTo(a.addedAt));
    return filtered;
  }

  List<CartShopGroup> getShopGroups(OrderType? filterType) {
    final filteredItems = getFilteredItems(filterType);
    final Map<String, List<CartItemModel>> grouped = {};
    final List<String> shopOrder = [];

    for (final item in filteredItems) {
      if (!grouped.containsKey(item.shopId)) {
        grouped[item.shopId] = [];
        shopOrder.add(item.shopId);
      }
      grouped[item.shopId]!.add(item);
    }

    return shopOrder.map((shopId) {
      final shopItems = grouped[shopId]!;
      return CartShopGroup(
        shopId: shopId,
        shopName: shopItems.first.shopName,
        sellerCity: shopItems.first.sellerCity,
        items: shopItems,
      );
    }).toList();
  }

  bool isAllSelectedInTab(OrderType? filterType) {
    final list = getFilteredItems(filterType);
    return list.isNotEmpty && list.every((i) => i.isSelected);
  }

  void toggleSelectAll(OrderType? filterType, bool value) {
    final list = getFilteredItems(filterType);
    for (final item in list) {
      item.isSelected = value;
      _repository.updateCartItem(item.id, isSelected: value);
    }
    notifyListeners();
  }

  void toggleShopSelection(String shopId, OrderType? filterType, bool value) {
    final list =
    getFilteredItems(filterType).where((item) => item.shopId == shopId);
    for (final item in list) {
      item.isSelected = value;
      _repository.updateCartItem(item.id, isSelected: value);
    }
    notifyListeners();
  }

  void toggleItemSelection(String itemId, bool value) {
    final index = _items.indexWhere((i) => i.id == itemId);
    if (index != -1) {
      _items[index].isSelected = value;
      notifyListeners();
      _repository.updateCartItem(itemId, isSelected: value);
    }
  }

  void updateQuantity(String itemId, int delta) {
    final index = _items.indexWhere((i) => i.id == itemId);
    if (index != -1) {
      final newQty = _items[index].quantity + delta;
      if (newQty >= 1 && newQty <= _items[index].availableStock) {
        _items[index].quantity = newQty;
        notifyListeners();
        _repository.updateCartItem(itemId, quantity: newQty);
      }
    }
  }

  void updateRentalDuration(String itemId, int days) {
    final index = _items.indexWhere((i) => i.id == itemId);
    if (index != -1) {
      _items[index].selectedRentalDays = days;
      notifyListeners();
      _repository.updateCartItem(itemId, rentalDuration: days);
    }
  }

  Future<void> removeItem(String itemId) async {
    _items.removeWhere((i) => i.id == itemId);
    notifyListeners();
    try {
      await _repository.deleteCartItem(itemId);
    } catch (e) {
      debugPrint('Error removeItem: $e');
    }
  }

  List<CartItemModel> getSelectedItems(OrderType? filterType) {
    return getFilteredItems(filterType).where((i) => i.isSelected).toList();
  }

  int getSelectedTotalAmount(OrderType? filterType) {
    return getSelectedItems(filterType)
        .fold(0, (sum, item) => sum + item.subtotalPrice);
  }

  int getSelectedCount(OrderType? filterType) {
    return getSelectedItems(filterType).length;
  }

  PendingPaymentSession startPaymentSession({
    required List<CartItemModel> itemsToCheckout,
    required SafeMeetingPointModel safeMeetingPoint,
    required String paymentMethod,
    int shippingFee = 5000,
    int discount = 0,
    Duration timeoutDuration = const Duration(minutes: 30),
  }) {
    final subtotal =
    itemsToCheckout.fold(0, (sum, item) => sum + item.subtotalPrice);

    final ids = itemsToCheckout.map((e) => e.id).toSet();
    _items.removeWhere((item) => ids.contains(item.id));

    _activePaymentSession = PendingPaymentSession(
      sessionId: 'PENDING-SYNC',
      checkedOutItems: itemsToCheckout,
      safeMeetingPoint: safeMeetingPoint,
      pickupAddress: itemsToCheckout.first.sellerPickupAddress,
      buyerAccountInfo: 'Mahasiswa UB',
      paymentMethod: paymentMethod,
      productSubtotal: subtotal,
      shippingFee: shippingFee,
      discount: discount,
      expiresAt: DateTime.now().add(timeoutDuration),
    );
    notifyListeners();

    _syncStartSessionToSupabase(
      itemsToCheckout: itemsToCheckout,
      safeMeetingPoint: safeMeetingPoint,
      paymentMethod: paymentMethod,
      subtotal: subtotal,
      shippingFee: shippingFee,
      discount: discount,
      timeoutDuration: timeoutDuration,
    );

    return _activePaymentSession!;
  }

  Future<void> _syncStartSessionToSupabase({
    required List<CartItemModel> itemsToCheckout,
    required SafeMeetingPointModel safeMeetingPoint,
    required String paymentMethod,
    required int subtotal,
    required int shippingFee,
    required int discount,
    required Duration timeoutDuration,
  }) async {
    try {
      String smpId = safeMeetingPoint.id;
      if (smpId.startsWith('SMP-')) {
        final dbPoints = await _repository.fetchSafeMeetingPoints();
        if (dbPoints.isNotEmpty) {
          smpId = dbPoints.first.id;
        }
      }

      final realSessionId = await _repository.startCheckoutSession(
        safeMeetingPointId: smpId,
        paymentMethod: paymentMethod,
        cartItemIds: itemsToCheckout.map((e) => e.id).toList(),
      );

      _activePaymentSession = PendingPaymentSession(
        sessionId: realSessionId,
        checkedOutItems: itemsToCheckout,
        safeMeetingPoint: safeMeetingPoint,
        pickupAddress: itemsToCheckout.first.sellerPickupAddress,
        buyerAccountInfo: 'Mahasiswa UB',
        paymentMethod: paymentMethod,
        productSubtotal: subtotal,
        shippingFee: shippingFee,
        discount: discount,
        expiresAt: DateTime.now().add(timeoutDuration),
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error _syncStartSessionToSupabase: $e');
    }
  }

  Future<void> cancelOrExpirePaymentSession() async {
    if (_activePaymentSession == null) return;
    final sessionId = _activePaymentSession!.sessionId;

    try {
      if (sessionId != 'PENDING-SYNC') {
        await _repository.cancelOrExpireSession(sessionId);
      }
    } catch (e) {
      debugPrint('Error cancelOrExpirePaymentSession: $e');
    } finally {
      _activePaymentSession = null;
      await loadCartFromSupabase();
    }
  }

  Future<bool> confirmPaymentSuccess() async {
    if (_activePaymentSession == null) return false;
    final sessionId = _activePaymentSession!.sessionId;

    try {
      if (sessionId != 'PENDING-SYNC') {
        await _repository.confirmPaymentSession(sessionId);
      }
      _activePaymentSession = null;
      await loadCartFromSupabase();
      await OrderController.instance.loadBuyerOrders();
      return true;
    } catch (e) {
      debugPrint('Error confirmPaymentSuccess: $e');
      return false;
    }
  }
}