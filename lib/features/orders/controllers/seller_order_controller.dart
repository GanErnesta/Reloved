import 'package:flutter/material.dart';
import '../models/seller_order_model.dart';
import '../repositories/order_repository.dart';

class SellerOrderController extends ChangeNotifier {
  final OrderRepository _repository = OrderRepository();

  SellerOrderMode _currentMode = SellerOrderMode.penjualan;
  SellerOrderMode get currentMode => _currentMode;

  int _selectedFilterIndex = 0;
  int get selectedFilterIndex => _selectedFilterIndex;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List< SellerOrderModel > _sellerOrders = [];

  SellerOrderController() {
    loadSellerOrders();
  }

  Future< void > loadSellerOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Memanggil fetchSellerOrders sesuai nama di OrderRepository beserta argumennya
      final rawPenjualan = await _repository.fetchSellerOrders('beli');
      final rawPenyewaan = await _repository.fetchSellerOrders('sewa');

      final rawList = < Map< String, dynamic > >[
        ...rawPenjualan,
        ...rawPenyewaan,
      ];

      _sellerOrders = rawList
          .map((row) => SellerOrderModel.fromSupabaseMap(row))
          .toList();
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error loadSellerOrders: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void switchMode(SellerOrderMode newMode) {
    if (_currentMode != newMode) {
      _currentMode = newMode;
      _selectedFilterIndex = 0;
      notifyListeners();
    }
  }

  void selectFilter(int index) {
    _selectedFilterIndex = index;
    notifyListeners();
  }

  int getPendingCountByMode(SellerOrderMode mode) {
    return _sellerOrders
        .where((o) => o.mode == mode && o.isPendingAction)
        .length;
  }

  int get otherModePendingCount {
    final otherMode = _currentMode == SellerOrderMode.penjualan
        ? SellerOrderMode.penyewaan
        : SellerOrderMode.penjualan;
    return getPendingCountByMode(otherMode);
  }

  List< SellerOrderModel > get filteredOrders {
    final modeOrders =
    _sellerOrders.where((o) => o.mode == _currentMode).toList();

    if (_currentMode == SellerOrderMode.penjualan) {
      switch (_selectedFilterIndex) {
        case 1:
          return modeOrders
              .where((o) => o.saleStatus == SellerSaleStatus.baru)
              .toList();
        case 2:
          return modeOrders
              .where((o) => o.saleStatus == SellerSaleStatus.siapCod)
              .toList();
        case 3:
          return modeOrders
              .where((o) => o.saleStatus == SellerSaleStatus.selesai)
              .toList();
        default:
          return modeOrders;
      }
    } else {
      switch (_selectedFilterIndex) {
        case 1:
          return modeOrders
              .where((o) => o.rentalStatus == SellerRentalStatus.permintaan)
              .toList();
        case 2:
          return modeOrders
              .where((o) => o.rentalStatus == SellerRentalStatus.aktif)
              .toList();
        case 3:
          return modeOrders
              .where((o) => o.rentalStatus == SellerRentalStatus.kembali)
              .toList();
        case 4:
          return modeOrders
              .where((o) => o.rentalStatus == SellerRentalStatus.selesai)
              .toList();
        default:
          return modeOrders;
      }
    }
  }

  Future< void > acceptOrder(String orderId) async {
    final index = _sellerOrders.indexWhere((o) => o.id == orderId);
    if (index == -1) return;

    final order = _sellerOrders[index];
    final String orderType =
    order.mode == SellerOrderMode.penyewaan ? 'sewa' : 'beli';

    try {
      await _repository.acceptOrderBySeller(
        orderId: orderId,
        orderType: orderType,
      );
      await loadSellerOrders();
    } catch (e) {
      debugPrint('Error acceptOrder: $e');
    }
  }

  Future< void > rejectOrder(String orderId) async {
    try {
      await _repository.rejectOrderBySeller(orderId);
      await loadSellerOrders();
    } catch (e) {
      debugPrint('Error rejectOrder: $e');
    }
  }

  Future< void > markSaleCompleted(String orderId) async {
    try {
      await _repository.completeOrderBySeller(orderId);
      await loadSellerOrders();
    } catch (e) {
      debugPrint('Error markSaleCompleted: $e');
    }
  }

  Future< void > verifyRentalReturn(String orderId) async {
    try {
      await _repository.completeOrderBySeller(orderId);
      await loadSellerOrders();
    } catch (e) {
      debugPrint('Error verifyRentalReturn: $e');
    }
  }
}