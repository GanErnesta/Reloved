import 'safe_meeting_point_model.dart';

enum SellerOrderMode { penjualan, penyewaan }

/// Status untuk Mode Penjualan: Baru, Siap COD, Selesai (Status Batal dihapus)
enum SellerSaleStatus { baru, siapCod, selesai }

/// Status untuk Mode Penyewaan: Permintaan, Aktif (Masa Sewa Aktif), Kembali (Pengembalian), Selesai
enum SellerRentalStatus { permintaan, aktif, kembali, selesai }

class SellerOrderModel {
  final String id;
  final String transactionCode; // Contoh: TRX-2024-001247 atau SEW-2024-000412
  final String relativeTimeText; // Contoh: "2 jam yang lalu"
  final SellerOrderMode mode;

  SellerSaleStatus? saleStatus;
  SellerRentalStatus? rentalStatus;

  // Informasi Pembeli & Campus Trust Score
  final String buyerName;
  final String buyerAvatarPath;
  final int buyerTrustScore; // Skala 0-100
  final String buyerCampus;

  // Informasi Produk
  final String productName;
  final String productImagePath;
  final int quantity;
  final int unitPrice; // Harga per pcs (Penjualan) atau harga sewa per hari (Penyewaan)

  // Khusus Mode Penyewaan
  final int? rentalDays;
  final int? depositAmount;
   String? remainingRentalTimeText; // Contoh: "00 Jam 51 Menit 06 Detik"

  // Pembayaran & Batas Waktu Terima
  final int totalPayment;
  final String paymentMethod;
  final String? acceptDeadlineText; // Contoh: "17 Jam 53 Menit 59 Det"

  // Lokasi Titik Temu Kampus (Safe Meeting Point)
  final SafeMeetingPointModel safeMeetingPoint;

  // Slot Integrasi Backend (Supabase & Midtrans)
  final String? supabaseOrderId;
  final String? midtransTransactionId;

  SellerOrderModel({
    required this.id,
    required this.transactionCode,
    required this.relativeTimeText,
    required this.mode,
    this.saleStatus,
    this.rentalStatus,
    required this.buyerName,
    required this.buyerAvatarPath,
    required this.buyerTrustScore,
    required this.buyerCampus,
    required this.productName,
    required this.productImagePath,
    this.quantity = 1,
    required this.unitPrice,
    this.rentalDays,
    this.depositAmount,
    this.remainingRentalTimeText,
    required this.totalPayment,
    required this.paymentMethod,
    this.acceptDeadlineText,
    required this.safeMeetingPoint,
    this.supabaseOrderId,
    this.midtransTransactionId,
  });

  /// Menentukan apakah pesanan ini merupakan permintaan baru yang butuh respon seller
  bool get isPendingAction {
    if (mode == SellerOrderMode.penjualan) {
      return saleStatus == SellerSaleStatus.baru;
    } else {
      return rentalStatus == SellerRentalStatus.permintaan;
    }
  }
}