import 'package:flutter/material.dart';
import '../../orders/controllers/order_controller.dart';
import '../../orders/models/order_model.dart';
import '../../orders/models/safe_meeting_point_model.dart';
import '../models/cart_model.dart';

class CartController extends ChangeNotifier {
  static final CartController instance = CartController._internal();
  factory CartController() => instance;
  CartController._internal();

  // Sesi pembayaran aktif yang menahan user di layar Pembayaran (Stuck Screen)
  PendingPaymentSession? _activePaymentSession;
  PendingPaymentSession? get activePaymentSession => _activePaymentSession;

  bool get hasPendingPayment {
    if (_activePaymentSession == null) return false;
    return true;
  }

  // Daftar item di keranjang
  final List<CartItemModel> _items = [
    CartItemModel(
      id: 'CART-1',
      productId: 'PRD-101',
      shopId: 'SHOP-MIKKO',
      shopName: 'Mikkoo32_',
      sellerCity: 'Malang',
      sellerPickupAddress:
      'Area Ketawanggede, Kecamatan Lowokwaru, Kota Malang, Provinsi Jawa Timur.',
      type: OrderType.beli,
      productName: 'Classic Denim Jacket',
      imagePath: 'assets/images/denim_jacket.png',
      subtitleInfo: 'Ukuran M · Kondisi sangat baik',
      unitPrice: 70000,
      addedAt: DateTime.now().subtract(const Duration(minutes: 5)),
      quantity: 1,
    ),
    CartItemModel(
      id: 'CART-2',
      productId: 'PRD-102',
      shopId: 'SHOP-MIKKO',
      shopName: 'Mikkoo32_',
      sellerCity: 'Malang',
      sellerPickupAddress:
      'Area Ketawanggede, Kecamatan Lowokwaru, Kota Malang, Provinsi Jawa Timur.',
      type: OrderType.sewa,
      productName: 'Vintage Brown Loafers',
      imagePath: 'assets/images/brown_loafers.png',
      subtitleInfo: 'Ukuran 43 · Mulai 30 Okt',
      unitPrice: 30000,
      addedAt: DateTime.now().subtract(const Duration(minutes: 15)),
      selectedRentalDays: 3,
      rentalStartDate: DateTime(2025, 10, 30),
      refundableDeposit: 100000,
    ),
    CartItemModel(
      id: 'CART-3',
      productId: 'PRD-103',
      shopId: 'SHOP-NONA',
      shopName: 'Nona Studio',
      sellerCity: 'Jakarta Selatan',
      sellerPickupAddress:
      'Jl. Soekarno Hatta, Kec. Lowokwaru, Kota Malang, Provinsi Jawa Timur.',
      type: OrderType.sewa,
      productName: 'Vintage Brown Loafers',
      imagePath: 'assets/images/brown_loafers.png',
      subtitleInfo: 'Ukuran 38 · Mulai 12 Jun',
      unitPrice: 30000,
      addedAt: DateTime.now().subtract(const Duration(minutes: 30)),
      selectedRentalDays: 3,
      rentalStartDate: DateTime(2025, 6, 12),
      refundableDeposit: 100000,
    ),
  ];

  /// Menambahkan barang baru ke paling atas keranjang (seperti Shopee/e-commerce)
  void addItemToCart(CartItemModel newItem) {
    _items.insert(0, newItem);
    notifyListeners();
  }

  /// Mengambil daftar item berdasarkan tab (null = Semua, OrderType.beli, OrderType.sewa)
  /// Diurutkan berdasarkan waktu ditambahkan terbaru di paling atas
  List<CartItemModel> getFilteredItems(OrderType? filterType) {
    final filtered = filterType == null
        ? List<CartItemModel>.from(_items)
        : _items.where((i) => i.type == filterType).toList();

    filtered.sort((a, b) => b.addedAt.compareTo(a.addedAt));
    return filtered;
  }

  /// Mengelompokkan item per toko dengan mempertahankan urutan barang terbaru di paling atas
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
    }
    notifyListeners();
  }

  void toggleShopSelection(
      String shopId, OrderType? filterType, bool value) {
    final list = getFilteredItems(filterType)
        .where((item) => item.shopId == shopId);
    for (final item in list) {
      item.isSelected = value;
    }
    notifyListeners();
  }

  void toggleItemSelection(String itemId, bool value) {
    final index = _items.indexWhere((i) => i.id == itemId);
    if (index != -1) {
      _items[index].isSelected = value;
      notifyListeners();
    }
  }

  void updateQuantity(String itemId, int delta) {
    final index = _items.indexWhere((i) => i.id == itemId);
    if (index != -1) {
      final newQty = _items[index].quantity + delta;
      if (newQty >= 1 && newQty <= _items[index].availableStock) {
        _items[index].quantity = newQty;
        notifyListeners();
      }
    }
  }

  void updateRentalDuration(String itemId, int days) {
    final index = _items.indexWhere((i) => i.id == itemId);
    if (index != -1) {
      _items[index].selectedRentalDays = days;
      notifyListeners();
    }
  }

  void removeItem(String itemId) {
    _items.removeWhere((i) => i.id == itemId);
    notifyListeners();
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

  // ===========================================================================
  // MEKANISME PEMBAYARAN TERTAHAN (STUCK PAYMENT SESSION) & MIDTRANS / SUPABASE
  // ===========================================================================

  /// Memulai sesi pembayaran (Stuck selama 30 menit hingga bayar / batal / expired)
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

    // Mengeluarkan sementara barang dari keranjang aktif (akan dikembalikan jika batal/expired)
    final ids = itemsToCheckout.map((e) => e.id).toSet();
    _items.removeWhere((item) => ids.contains(item.id));

    _activePaymentSession = PendingPaymentSession(
      sessionId: 'PAY-${DateTime.now().millisecondsSinceEpoch}',
      checkedOutItems: itemsToCheckout,
      safeMeetingPoint: safeMeetingPoint,
      pickupAddress: itemsToCheckout.first.sellerPickupAddress,
      buyerAccountInfo: 'falishakeyrani - falishakeyrani@student.ub.ac.id',
      paymentMethod: paymentMethod,
      productSubtotal: subtotal,
      shippingFee: shippingFee,
      discount: discount,
      expiresAt: DateTime.now().add(timeoutDuration),
      midtransOrderId: 'MID-${DateTime.now().millisecondsSinceEpoch}',
    );

    notifyListeners();
    return _activePaymentSession!;
  }

  /// Dipanggil saat waktu habis (30 menit) atau user membatalkan pembayaran:
  /// Sesi dihapus seolah pesanan tidak pernah ada & barang/stok kembali ke keranjang.
  Future<void> cancelOrExpirePaymentSession() async {
    if (_activePaymentSession == null) return;

    // TODO: Panggil API Supabase & Midtrans cancel transaction + restore product stock
    final restoredItems = _activePaymentSession!.checkedOutItems;
    for (final item in restoredItems.reversed) {
      _items.insert(0, item);
    }

    _activePaymentSession = null;
    notifyListeners();
  }

  /// Dipanggil saat tombol "Konfirmasi Pembayaran" diklik & status Midtrans Settlement
  Future<bool> confirmPaymentSuccess() async {
    if (_activePaymentSession == null) return false;
    final session = _activePaymentSession!;

    // TODO: Cek status transaksi ke backend Supabase / Midtrans
    final beliItems = session.checkedOutItems
        .where((i) => i.type == OrderType.beli)
        .toList();
    final sewaItems = session.checkedOutItems
        .where((i) => i.type == OrderType.sewa)
        .toList();

    if (beliItems.isNotEmpty) {
      OrderController.instance.addOrder(
        OrderModel(
          id: 'ORD-${DateTime.now().millisecondsSinceEpoch}-B',
          shopId: beliItems.first.shopId,
          shopName: beliItems.first.shopName,
          shopAvatarPath: 'assets/images/shop_avatar.png',
          orderType: OrderType.beli,
          status: OrderStatus.menunggu,
          items: beliItems
              .map(
                (c) => OrderItemModel(
              id: c.id,
              productName: c.productName,
              imagePath: c.imagePath,
              price: c.unitPrice,
              quantity: c.quantity,
              variant: c.subtitleInfo,
            ),
          )
              .toList(),
          orderDateText: 'Jumat, 30 Oktober 2026, 15:30 WIB',
          receivedDateText: 'Senin, 2 November 2026, 13:00 WIB',
          pickupAddress: session.pickupAddress,
          safeMeetingPoint: session.safeMeetingPoint,
          buyerAccountInfo: session.buyerAccountInfo,
          productSubtotal:
          beliItems.fold(0, (s, i) => s + i.subtotalPrice),
          shippingFee: session.shippingFee,
          discount: session.discount,
          paymentMethod: session.paymentMethod,
        ),
      );
    }

    if (sewaItems.isNotEmpty) {
      final firstSewa = sewaItems.first;
      OrderController.instance.addOrder(
        OrderModel(
          id: 'ORD-${DateTime.now().millisecondsSinceEpoch}-S',
          shopId: firstSewa.shopId,
          shopName: firstSewa.shopName,
          shopAvatarPath: 'assets/images/shop_avatar.png',
          orderType: OrderType.sewa,
          status: OrderStatus.menunggu,
          items: sewaItems
              .map(
                (c) => OrderItemModel(
              id: c.id,
              productName: c.productName,
              imagePath: c.imagePath,
              price: c.subtotalPrice,
              quantity: c.quantity,
              variant: c.subtitleInfo,
            ),
          )
              .toList(),
          orderDateText: 'Jumat, 30 Oktober 2026',
          receivedDateText: 'Senin, 2 November 2026',
          rentalDurationDays: firstSewa.selectedRentalDays,
          rentalRemainingText: '${firstSewa.selectedRentalDays} hari lagi',
          rentalReturnDateText: firstSewa.rentalDateRangeText,
          pickupAddress: session.pickupAddress,
          safeMeetingPoint: session.safeMeetingPoint,
          buyerAccountInfo: session.buyerAccountInfo,
          productSubtotal:
          sewaItems.fold(0, (s, i) => s + i.subtotalPrice),
          shippingFee: session.shippingFee,
          discount: session.discount,
          paymentMethod: session.paymentMethod,
        ),
      );
    }

    _activePaymentSession = null;
    notifyListeners();
    return true;
  }
}