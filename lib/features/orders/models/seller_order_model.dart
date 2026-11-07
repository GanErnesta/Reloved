import 'safe_meeting_point_model.dart';

enum SellerOrderMode { penjualan, penyewaan }

enum SellerSaleStatus { baru, siapCod, selesai }

enum SellerRentalStatus { permintaan, aktif, kembali, selesai }

class SellerOrderModel {
  final String id;
  final String transactionCode;
  final String relativeTimeText;
  final SellerOrderMode mode;

  SellerSaleStatus? saleStatus;
  SellerRentalStatus? rentalStatus;

  final String buyerName;
  final String buyerAvatarPath;
  final int buyerTrustScore;
  final String buyerCampus;

  final String productName;
  final String productImagePath;
  final int quantity;
  final int unitPrice;

  final int? rentalDays;
  final int? depositAmount;
  String? remainingRentalTimeText;

  final int totalPayment;
  final String paymentMethod;
  final String? acceptDeadlineText;

  final SafeMeetingPointModel safeMeetingPoint;

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

  bool get isPendingAction {
    if (mode == SellerOrderMode.penjualan) {
      return saleStatus == SellerSaleStatus.baru;
    } else {
      return rentalStatus == SellerRentalStatus.permintaan;
    }
  }

  static SellerSaleStatus _parseSaleStatus(String raw) {
    switch (raw.toLowerCase()) {
      case 'siap_cod':
        return SellerSaleStatus.siapCod;
      case 'selesai':
        return SellerSaleStatus.selesai;
      default:
        return SellerSaleStatus.baru;
    }
  }

  static SellerRentalStatus _parseRentalStatus(String raw) {
    switch (raw.toLowerCase()) {
      case 'aktif':
        return SellerRentalStatus.aktif;
      case 'kembali':
        return SellerRentalStatus.kembali;
      case 'selesai':
        return SellerRentalStatus.selesai;
      default:
        return SellerRentalStatus.permintaan;
    }
  }

  static String _formatRelativeTime(String? isoString) {
    if (isoString == null) return 'Baru saja';
    final dt = DateTime.tryParse(isoString)?.toLocal();
    if (dt == null) return 'Baru saja';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit yang lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam yang lalu';
    return '${diff.inDays} hari yang lalu';
  }

  static String _formatCountdown(String? targetIso) {
    if (targetIso == null) return '23 Jam 59 Menit 00 Det';
    final target = DateTime.tryParse(targetIso)?.toLocal();
    if (target == null) return '23 Jam 59 Menit 00 Det';
    final diff = target.difference(DateTime.now());
    if (diff.isNegative) return '00 Jam 00 Menit 00 Det';
    final hours = diff.inHours.toString().padLeft(2, '0');
    final mins = diff.inMinutes.remainder(60).toString().padLeft(2, '0');
    final secs = diff.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$hours Jam $mins Menit $secs Det';
  }

  factory SellerOrderModel.fromSupabaseMap(Map<String, dynamic> map) {
    final buyer = map['buyer'] as Map<String, dynamic>? ?? {};
    final smpMap = map['safe_meeting_points'] as Map<String, dynamic>?;
    final rawItems = map['order_items'] as List<dynamic>? ?? [];
    final firstItem = rawItems.isNotEmpty
        ? Map<String, dynamic>.from(rawItems.first as Map)
        : <String, dynamic>{};

    final rawType = (map['order_type'] ?? 'beli').toString().toLowerCase();
    final bool isRental = rawType == 'sewa' || rawType == 'rent';
    final rawSellerStatus = (map['seller_status'] ?? 'baru').toString();

    return SellerOrderModel(
      id: (map['id'] ?? '').toString(),
      transactionCode: (map['transaction_code'] ?? 'TRX-000').toString(),
      relativeTimeText: _formatRelativeTime(map['ordered_at']?.toString()),
      mode: isRental ? SellerOrderMode.penyewaan : SellerOrderMode.penjualan,
      saleStatus: isRental ? null : _parseSaleStatus(rawSellerStatus),
      rentalStatus: isRental ? _parseRentalStatus(rawSellerStatus) : null,
      buyerName: (buyer['nama'] ?? 'Mahasiswa UB').toString(),
      buyerAvatarPath: (buyer['foto_profil'] ?? 'assets/images/buyer_arine.png').toString(),
      buyerTrustScore: ((buyer['trust_score'] ?? 100) as num).toInt(),
      buyerCampus: (buyer['kampus'] ?? 'Universitas Brawijaya').toString(),
      productName: (firstItem['product_name_snapshot'] ?? 'Produk Reloved').toString(),
      productImagePath: (firstItem['product_image_snapshot'] ?? 'assets/images/buku_algoritma.png').toString(),
      quantity: ((firstItem['quantity'] ?? 1) as num).toInt(),
      unitPrice: ((firstItem['unit_price'] ?? map['product_subtotal'] ?? 0) as num).toInt(),
      rentalDays: (map['rental_duration_days'] as num?)?.toInt() ?? 1,
      depositAmount: ((map['deposit_total'] ?? 0) as num).toInt(),
      remainingRentalTimeText: isRental
          ? _formatCountdown(map['rental_end_at']?.toString())
          : null,
      totalPayment: ((map['product_subtotal'] ?? map['grand_total'] ?? 0) as num).toInt(),
      paymentMethod: (map['payment_method'] ?? 'QRIS').toString(),
      acceptDeadlineText: _formatCountdown(map['accept_deadline_at']?.toString()),
      safeMeetingPoint: smpMap != null
          ? SafeMeetingPointModel.fromMap(smpMap)
          : SafeMeetingPointModel.campusPoints.first,
      supabaseOrderId: (map['id'] ?? '').toString(),
    );
  }
}