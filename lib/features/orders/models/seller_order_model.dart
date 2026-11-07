import 'safe_meeting_point_model.dart';

enum SellerOrderMode { penjualan, penyewaan }

enum SellerSaleStatus { baru, siapCod, selesai }

enum SellerRentalStatus { permintaan, aktif, kembali, selesai }

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

int _toInt(dynamic value, [int fallback = 0]) {
  if (value is num) return value.toInt();
  if (value is String) {
    return int.tryParse(value) ?? double.tryParse(value)?.toInt() ?? fallback;
  }
  return fallback;
}

String _cleanText(dynamic value) {
  final text = (value ?? '').toString().trim();
  return text == 'null' ? '' : text;
}

/// Satu baris produk di dalam pesanan (pesanan bisa berisi lebih dari satu).
class SellerOrderItemModel {
  final String id;
  final String productName;

  /// Nilai mentah gambar (URL / path storage / path asset). Kosong jika tidak ada.
  final String imagePath;

  final int quantity;
  final int unitPrice;
  final int? rentalDays;
  final int? depositAmount;

  const SellerOrderItemModel({
    required this.id,
    required this.productName,
    required this.imagePath,
    this.quantity = 1,
    required this.unitPrice,
    this.rentalDays,
    this.depositAmount,
  });

  factory SellerOrderItemModel.fromSupabaseMap(Map<String, dynamic> map) {
    final product = _asMap(map['products']);
    final snapshot = _cleanText(map['product_image_snapshot']);

    final name = _cleanText(map['product_name_snapshot']).isNotEmpty
        ? _cleanText(map['product_name_snapshot'])
        : (_cleanText(product['name']).isNotEmpty
        ? _cleanText(product['name'])
        : 'Produk Reloved');

    return SellerOrderItemModel(
      id: _cleanText(map['id']),
      productName: name,
      imagePath:
      snapshot.isNotEmpty ? snapshot : _cleanText(product['image_url']),
      quantity: _toInt(map['quantity'], 1),
      unitPrice: _toInt(map['unit_price']),
      rentalDays: (map['rental_duration_days'] as num?)?.toInt(),
      depositAmount: (map['deposit_amount'] as num?)?.toInt(),
    );
  }
}

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

  /// Nilai mentah gambar (URL / path storage / path asset). Kosong jika tidak ada.
  /// Tampilkan lewat `SmartImage(source: productImagePath)`.
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

  /// Semua produk dalam pesanan ini. Gunakan [displayItems] di UI.
  final List<SellerOrderItemModel> items;

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
    this.items = const [],
  });

  /// Daftar produk untuk ditampilkan. Jika [items] kosong (data lama),
  /// dibuat satu item dari field produk pertama.
  List<SellerOrderItemModel> get displayItems {
    if (items.isNotEmpty) return items;

    return [
      SellerOrderItemModel(
        id: 'single',
        productName: productName,
        imagePath: productImagePath,
        quantity: quantity,
        unitPrice: unitPrice,
        rentalDays: rentalDays,
        depositAmount: depositAmount,
      ),
    ];
  }

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
    final buyer = _asMap(map['buyer']);
    final smpRaw = map['safe_meeting_points'];
    final rawItems = map['order_items'] as List<dynamic>? ?? [];
    final firstItem = rawItems.isNotEmpty
        ? Map<String, dynamic>.from(rawItems.first as Map)
        : <String, dynamic>{};
    final firstProduct = _asMap(firstItem['products']);

    final parsedItems = rawItems
        .whereType<Map>()
        .map(
          (e) => SellerOrderItemModel.fromSupabaseMap(
        Map<String, dynamic>.from(e),
      ),
    )
        .toList();

    final rawType = (map['order_type'] ?? 'beli').toString().toLowerCase();
    final bool isRental = rawType == 'sewa' || rawType == 'rent';
    final rawSellerStatus = (map['seller_status'] ?? 'baru').toString();

    // Prioritas snapshot; jika kosong pakai gambar produk asli
    // (butuh `products(image_url)` di select order_items pada repository).
    final snapshotImage = _cleanText(firstItem['product_image_snapshot']);
    final productImage = snapshotImage.isNotEmpty
        ? snapshotImage
        : _cleanText(firstProduct['image_url']);

    final buyerAvatar = _cleanText(
      buyer['foto_profil'] ?? buyer['avatar_url'] ?? buyer['photo_url'],
    );

    return SellerOrderModel(
      id: _cleanText(map['id']),
      transactionCode: _cleanText(map['transaction_code']).isNotEmpty
          ? _cleanText(map['transaction_code'])
          : 'TRX-000',
      relativeTimeText: _formatRelativeTime(map['ordered_at']?.toString()),
      mode: isRental ? SellerOrderMode.penyewaan : SellerOrderMode.penjualan,
      saleStatus: isRental ? null : _parseSaleStatus(rawSellerStatus),
      rentalStatus: isRental ? _parseRentalStatus(rawSellerStatus) : null,
      buyerName: _cleanText(buyer['nama']).isNotEmpty
          ? _cleanText(buyer['nama'])
          : 'Mahasiswa UB',
      buyerAvatarPath:
      buyerAvatar.isNotEmpty ? buyerAvatar : 'assets/images/buyer_arine.png',
      buyerTrustScore: _toInt(buyer['trust_score'], 100),
      buyerCampus: _cleanText(buyer['kampus']).isNotEmpty
          ? _cleanText(buyer['kampus'])
          : 'Universitas Brawijaya',
      productName: _cleanText(firstItem['product_name_snapshot']).isNotEmpty
          ? _cleanText(firstItem['product_name_snapshot'])
          : (_cleanText(firstProduct['name']).isNotEmpty
          ? _cleanText(firstProduct['name'])
          : 'Produk Reloved'),
      productImagePath: productImage,
      quantity: _toInt(firstItem['quantity'], 1),
      unitPrice: _toInt(firstItem['unit_price'] ?? map['product_subtotal']),
      rentalDays: (map['rental_duration_days'] as num?)?.toInt() ?? 1,
      depositAmount: _toInt(map['deposit_total']),
      remainingRentalTimeText: isRental
          ? _formatCountdown(map['rental_end_at']?.toString())
          : null,
      totalPayment: _toInt(map['product_subtotal'] ?? map['grand_total']),
      paymentMethod: _cleanText(map['payment_method']).isNotEmpty
          ? _cleanText(map['payment_method'])
          : 'QRIS',
      acceptDeadlineText:
      _formatCountdown(map['accept_deadline_at']?.toString()),
      safeMeetingPoint: smpRaw is Map
          ? SafeMeetingPointModel.fromMap(Map<String, dynamic>.from(smpRaw))
          : SafeMeetingPointModel.campusPoints.first,
      supabaseOrderId: _cleanText(map['id']),
      items: parsedItems,
    );
  }
}