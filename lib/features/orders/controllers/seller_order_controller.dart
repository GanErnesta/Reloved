import 'package:flutter/material.dart';
import '../models/safe_meeting_point_model.dart';
import '../models/seller_order_model.dart';

class SellerOrderController extends ChangeNotifier {
  SellerOrderMode _currentMode = SellerOrderMode.penjualan;
  SellerOrderMode get currentMode => _currentMode;

  // Index filter aktif:
  // Mode Penjualan: 0 = Semua, 1 = Baru, 2 = Siap COD, 3 = Selesai
  // Mode Penyewaan: 0 = Semua, 1 = Permintaan, 2 = Aktif, 3 = Kembali, 4 = Selesai
  int _selectedFilterIndex = 0;
  int get selectedFilterIndex => _selectedFilterIndex;

  final List<SellerOrderModel> _sellerOrders = [
    // ================= DATA DUMMY MODE PENJUALAN =================
    SellerOrderModel(
      id: 'S-ORD-1',
      transactionCode: 'TRX-2024-001247',
      relativeTimeText: '2 jam yang lalu',
      mode: SellerOrderMode.penjualan,
      saleStatus: SellerSaleStatus.baru,
      buyerName: 'Arine Fey',
      buyerAvatarPath: 'assets/images/buyer_arine.png',
      buyerTrustScore: 88,
      buyerCampus: 'Universitas Brawijaya',
      productName: 'Buku Algoritma & Pemrograman Ed.3',
      productImagePath: 'assets/images/buku_algoritma.png',
      quantity: 1,
      unitPrice: 85000,
      totalPayment: 85000,
      paymentMethod: 'Gopay',
      acceptDeadlineText: '17 Jam 53 Menit 59 Det',
      safeMeetingPoint: SafeMeetingPointModel.campusPoints[0], // Perpustakaan Pusat Kampus
    ),
    SellerOrderModel(
      id: 'S-ORD-2',
      transactionCode: 'TRX-2024-001190',
      relativeTimeText: '5 jam yang lalu',
      mode: SellerOrderMode.penjualan,
      saleStatus: SellerSaleStatus.siapCod,
      buyerName: 'Anisa Putri',
      buyerAvatarPath: 'assets/images/buyer_anisa.png',
      buyerTrustScore: 95,
      buyerCampus: 'Universitas Brawijaya',
      productName: 'Laptop Asus VivoBook 14 i5',
      productImagePath: 'assets/images/laptop_asus.png',
      quantity: 1,
      unitPrice: 3200000,
      totalPayment: 3200000,
      paymentMethod: 'Gopay',
      safeMeetingPoint: SafeMeetingPointModel.campusPoints[1], // Lobby Utama Gedung F Filkom UB
    ),
    SellerOrderModel(
      id: 'S-ORD-3',
      transactionCode: 'TRX-2024-001050',
      relativeTimeText: '2 hari yang lalu',
      mode: SellerOrderMode.penjualan,
      saleStatus: SellerSaleStatus.selesai,
      buyerName: 'Budi Santoso',
      buyerAvatarPath: 'assets/images/buyer_budi.png',
      buyerTrustScore: 72,
      buyerCampus: 'Universitas Brawijaya',
      productName: 'Mouse Wireless Logitech M185',
      productImagePath: 'assets/images/mouse_logitech.png',
      quantity: 2,
      unitPrice: 110000,
      totalPayment: 220000,
      paymentMethod: 'Gopay',
      safeMeetingPoint: SafeMeetingPointModel.campusPoints[2], // Gedung Student Center
    ),

    // ================= DATA DUMMY MODE PENYEWAAN =================
    SellerOrderModel(
      id: 'R-ORD-1',
      transactionCode: 'SEW-2024-000412',
      relativeTimeText: '1 jam yang lalu',
      mode: SellerOrderMode.penyewaan,
      rentalStatus: SellerRentalStatus.permintaan,
      buyerName: 'Puput Haryono',
      buyerAvatarPath: 'assets/images/buyer_arine.png',
      buyerTrustScore: 88,
      buyerCampus: 'Universitas Brawijaya',
      productName: 'Kalkulator Casio FX-991ES',
      productImagePath: 'assets/images/kalkulator_casio.png',
      quantity: 1,
      unitPrice: 15000,
      rentalDays: 3,
      depositAmount: 50000,
      totalPayment: 45000,
      paymentMethod: 'Gopay',
      acceptDeadlineText: '17 Jam 53 Menit 59 Det',
      safeMeetingPoint: const SafeMeetingPointModel(
        id: 'SMP-GKM',
        name: 'Gedung Kreativitas Mahasiswa Filkom UB',
        fullAddress: 'GKM FILKOM UB, Jl. Veteran, Malang',
        imagePath: 'assets/images/smp_filkom.png',
      ),
    ),
    SellerOrderModel(
      id: 'R-ORD-2',
      transactionCode: 'SEW-2024-000389',
      relativeTimeText: '3 hari yang lalu',
      mode: SellerOrderMode.penyewaan,
      rentalStatus: SellerRentalStatus.aktif,
      buyerName: 'Nareav',
      buyerAvatarPath: 'assets/images/buyer_anisa.png',
      buyerTrustScore: 95,
      buyerCampus: 'Universitas Brawijaya',
      productName: 'Headset Sony MDR-ZX110',
      productImagePath: 'assets/images/headset_sony.png',
      quantity: 1,
      unitPrice: 20000,
      rentalDays: 7,
      depositAmount: 80000,
      totalPayment: 140000,
      paymentMethod: 'Gopay',
      remainingRentalTimeText: '00 Jam 51 Menit 06 Detik',
      safeMeetingPoint: const SafeMeetingPointModel(
        id: 'SMP-GKM',
        name: 'Gedung Kreativitas Mahasiswa Filkom UB',
        fullAddress: 'GKM FILKOM UB, Jl. Veteran, Malang',
        imagePath: 'assets/images/smp_filkom.png',
      ),
    ),
    SellerOrderModel(
      id: 'R-ORD-3',
      transactionCode: 'SEW-2024-000301',
      relativeTimeText: '10 menit yang lalu',
      mode: SellerOrderMode.penyewaan,
      rentalStatus: SellerRentalStatus.kembali,
      buyerName: 'Budi Santoso',
      buyerAvatarPath: 'assets/images/buyer_budi.png',
      buyerTrustScore: 72,
      buyerCampus: 'Universitas Brawijaya',
      productName: 'Tas Ransel Laptop 15" Aerocase',
      productImagePath: 'assets/images/tas_laptop.png',
      quantity: 1,
      unitPrice: 12000,
      rentalDays: 1,
      totalPayment: 220000,
      paymentMethod: 'Gopay',
      safeMeetingPoint: const SafeMeetingPointModel(
        id: 'SMP-GKM',
        name: 'Gedung Kreativitas Mahasiswa Filkom UB',
        fullAddress: 'GKM FILKOM UB, Jl. Veteran, Malang',
        imagePath: 'assets/images/smp_filkom.png',
      ),
    ),
  ];

  void switchMode(SellerOrderMode newMode) {
    if (_currentMode != newMode) {
      _currentMode = newMode;
      _selectedFilterIndex = 0; // Reset ke tab "Semua" saat ganti mode
      notifyListeners();
    }
  }

  void selectFilter(int index) {
    _selectedFilterIndex = index;
    notifyListeners();
  }

  /// Menghitung jumlah pesanan baru/permintaan pada mode tertentu
  int getPendingCountByMode(SellerOrderMode mode) {
    return _sellerOrders
        .where((o) => o.mode == mode && o.isPendingAction)
        .length;
  }

  /// Menghitung jumlah permintaan di mode SEBERANG (mode yang sedang tidak tampil di layar)
  int get otherModePendingCount {
    final otherMode = _currentMode == SellerOrderMode.penjualan
        ? SellerOrderMode.penyewaan
        : SellerOrderMode.penjualan;
    return getPendingCountByMode(otherMode);
  }

  /// Mengambil daftar pesanan sesuai mode dan chip filter yang dipilih
  List<SellerOrderModel> get filteredOrders {
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

  // ===========================================================================
  // SLOT INTEGRASI SUPABASE & MIDTRANS (Aksi Seller)
  // ===========================================================================

  /// Menerima pesanan baru (Penjualan -> Siap COD, Penyewaan -> Masa Sewa Aktif)
  Future<void> acceptOrder(String orderId) async {
    // TODO: Update status transaksi di Supabase
    final index = _sellerOrders.indexWhere((o) => o.id == orderId);
    if (index == -1) return;

    final order = _sellerOrders[index];
    if (order.mode == SellerOrderMode.penjualan &&
        order.saleStatus == SellerSaleStatus.baru) {
      order.saleStatus = SellerSaleStatus.siapCod;
    } else if (order.mode == SellerOrderMode.penyewaan &&
        order.rentalStatus == SellerRentalStatus.permintaan) {
      order.rentalStatus = SellerRentalStatus.aktif;
      order.remainingRentalTimeText ??=
      '${(order.rentalDays ?? 1) * 24} Jam 00 Menit 00 Detik';
    }
    notifyListeners();
  }

  /// Menolak pesanan baru (Menghapus dari daftar aktif & memicu refund Midtrans / kembalikan stok)
  Future<void> rejectOrder(String orderId) async {
    // TODO: Panggil Supabase RPC & Midtrans refund API, kembalikan stok barang
    _sellerOrders.removeWhere((o) => o.id == orderId);
    notifyListeners();
  }

  /// Menandai pesanan penjualan selesai setelah COD
  Future<void> markSaleCompleted(String orderId) async {
    // TODO: Update status selesai di Supabase & teruskan dana ke saldo Seller
    final index = _sellerOrders.indexWhere((o) => o.id == orderId);
    if (index != -1 &&
        _sellerOrders[index].saleStatus == SellerSaleStatus.siapCod) {
      _sellerOrders[index].saleStatus = SellerSaleStatus.selesai;
      notifyListeners();
    }
  }

  /// Memverifikasi pengembalian barang sewa (Status Kembali -> Selesai & cairkan deposit ke buyer)
  Future<void> verifyRentalReturn(String orderId) async {
    // TODO: Update status sewa selesai di Supabase & kembalikan dana deposit ke Buyer
    final index = _sellerOrders.indexWhere((o) => o.id == orderId);
    if (index != -1 &&
        _sellerOrders[index].rentalStatus == SellerRentalStatus.kembali) {
      _sellerOrders[index].rentalStatus = SellerRentalStatus.selesai;
      notifyListeners();
    }
  }
}