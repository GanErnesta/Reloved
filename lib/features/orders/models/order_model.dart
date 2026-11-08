import 'safe_meeting_point_model.dart';

enum OrderType { beli, sewa }

enum OrderStatus {
  menunggu,
  dikirim,
  terkirim,
  selesai,
  dibatalkan,
}

// -----------------------------------------------------------------------------
// Helper parsing aman terhadap tipe data tak terduga dari Supabase
// -----------------------------------------------------------------------------

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

class OrderItemModel {
  final String id;
  final String productName;

  /// Nilai mentah gambar (URL / path storage / path asset). Kosong jika tidak ada.
  /// Tampilkan lewat `SmartImage(source: imagePath)`.
  final String imagePath;

  final int price;
  final int quantity;
  final String? variant;

  const OrderItemModel({
    required this.id,
    required this.productName,
    required this.imagePath,
    required this.price,
    required this.quantity,
    this.variant,
  });

  factory OrderItemModel.fromSupabaseMap(Map<String, dynamic> map) {
    // Prioritas: snapshot saat pesanan dibuat. Jika snapshot kosong (misalnya
    // fungsi RPC di database tidak mengisinya), pakai gambar produk aslinya
    // (butuh `products(image_url)` di select order_items pada repository).
    final product = _asMap(map['products']);
    final snapshot = _cleanText(map['product_image_snapshot']);

    return OrderItemModel(
      id: _cleanText(map['id']),
      productName: _cleanText(map['product_name_snapshot']).isNotEmpty
          ? _cleanText(map['product_name_snapshot'])
          : (_cleanText(product['name']).isNotEmpty
          ? _cleanText(product['name'])
          : 'Produk'),
      imagePath:
      snapshot.isNotEmpty ? snapshot : _cleanText(product['image_url']),
      price: _toInt(map['unit_price']),
      quantity: _toInt(map['quantity'], 1),
      variant: map['variant_snapshot']?.toString(),
    );
  }
}

class OrderModel {
  final String id;
  final String shopId;
  final String shopName;
  final String shopAvatarPath;
  final OrderType orderType;
  OrderStatus status;
  final List<OrderItemModel> items;

  final String orderDateText;
  final String receivedDateText;

  final int? rentalDurationDays;
  final String? rentalRemainingText;
  final String? rentalReturnDateText;

  final String pickupAddress;
  SafeMeetingPointModel safeMeetingPoint;
  final String buyerAccountInfo;

  final int productSubtotal;
  final int shippingFee;
  final int discount;
  final String paymentMethod;

  final String? supabaseTransactionId;
  final String? midtransOrderId;
  final String? midtransSnapToken;

  OrderModel({
    required this.id,
    required this.shopId,
    required this.shopName,
    required this.shopAvatarPath,
    required this.orderType,
    required this.status,
    required this.items,
    required this.orderDateText,
    required this.receivedDateText,
    this.rentalDurationDays,
    this.rentalRemainingText,
    this.rentalReturnDateText,
    required this.pickupAddress,
    required this.safeMeetingPoint,
    required this.buyerAccountInfo,
    required this.productSubtotal,
    required this.shippingFee,
    this.discount = 0,
    required this.paymentMethod,
    this.supabaseTransactionId,
    this.midtransOrderId,
    this.midtransSnapToken,
  });

  int get totalProductPrice =>
      items.fold(0, (sum, item) => sum + (item.price * item.quantity));

  int get grandTotal => productSubtotal + shippingFee - discount;

  static OrderStatus _parseStatus(String raw) {
    switch (raw.toLowerCase()) {
      case 'dikirim':
        return OrderStatus.dikirim;
      case 'terkirim':
        return OrderStatus.terkirim;
      case 'selesai':
        return OrderStatus.selesai;
      case 'dibatalkan':
        return OrderStatus.dibatalkan;
      default:
        return OrderStatus.menunggu;
    }
  }

  static String _formatDateTime(String? isoString,
      {required bool includeTime}) {
    if (isoString == null || isoString.isEmpty) return '-';
    final dt = DateTime.tryParse(isoString)?.toLocal();
    if (dt == null) return isoString;

    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    final dayName = days[dt.weekday - 1];
    final monthName = months[dt.month - 1];

    if (!includeTime) {
      return '$dayName, ${dt.day} $monthName ${dt.year}';
    }
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$dayName, ${dt.day} $monthName ${dt.year}, $hh:$mm WIB';
  }

  factory OrderModel.fromSupabaseMap(Map<String, dynamic> map) {
    final seller = _asMap(map['seller']);
    final buyer = _asMap(map['buyer']);
    final smpRaw = map['safe_meeting_points'];
    final rawItems = map['order_items'] as List<dynamic>? ?? [];

    final rawType = (map['order_type'] ?? 'beli').toString().toLowerCase();
    final bool isSewa = rawType == 'sewa' || rawType == 'rent';

    final parsedItems = rawItems
        .map(
          (e) => OrderItemModel.fromSupabaseMap(
        Map<String, dynamic>.from(e as Map),
      ),
    )
        .toList();

    final int? durationDays = (map['rental_duration_days'] as num?)?.toInt();
    final DateTime? rentalEnd = map['rental_end_at'] != null
        ? DateTime.tryParse(map['rental_end_at'].toString())?.toLocal()
        : null;

    String? remainingText;
    if (isSewa && durationDays != null) {
      if (rentalEnd != null) {
        final diffDays = rentalEnd.difference(DateTime.now()).inDays;
        remainingText = diffDays > 0 ? '$diffDays hari lagi' : 'Hari terakhir';
      } else {
        remainingText = '$durationDays hari lagi';
      }
    }

    final buyerName = _cleanText(buyer['nama']).isNotEmpty
        ? _cleanText(buyer['nama'])
        : 'Mahasiswa';
    final buyerEmail = _cleanText(buyer['email']).isNotEmpty
        ? _cleanText(buyer['email'])
        : 'student@student.ub.ac.id';

    // Avatar toko: coba beberapa nama kolom yang umum dipakai.
    // Sesuaikan dengan nama kolom foto di tabel profiles milikmu.
    final avatarRaw = _cleanText(
      seller['foto_profil'] ?? seller['avatar_url'] ?? seller['photo_url'],
    );

    return OrderModel(
      id: _cleanText(map['id']),
      shopId: _cleanText(map['seller_id']),
      shopName: _cleanText(seller['nama']).isNotEmpty
          ? _cleanText(seller['nama'])
          : 'Toko Mahasiswa',
      shopAvatarPath:
      avatarRaw.isNotEmpty ? avatarRaw : 'assets/images/shop_avatar.png',
      orderType: isSewa ? OrderType.sewa : OrderType.beli,
      status: _parseStatus((map['buyer_status'] ?? 'menunggu').toString()),
      items: parsedItems.isNotEmpty
          ? parsedItems
          : const [
        OrderItemModel(
          id: 'EMPTY',
          productName: 'Produk',
          imagePath: '',
          price: 0,
          quantity: 1,
        ),
      ],
      orderDateText:
      _formatDateTime(map['ordered_at']?.toString(), includeTime: !isSewa),
      receivedDateText: map['received_at'] != null
          ? _formatDateTime(map['received_at']?.toString(),
          includeTime: !isSewa)
          : 'Menunggu konfirmasi penerimaan',
      rentalDurationDays: durationDays,
      rentalRemainingText: remainingText,
      rentalReturnDateText: rentalEnd != null
          ? _formatDateTime(rentalEnd.toIso8601String(), includeTime: false)
          : null,
      pickupAddress: _cleanText(map['pickup_address']).isNotEmpty
          ? _cleanText(map['pickup_address'])
          : 'Area Ketawanggede, Malang',
      safeMeetingPoint: smpRaw is Map
          ? SafeMeetingPointModel.fromMap(Map<String, dynamic>.from(smpRaw))
          : SafeMeetingPointModel.campusPoints.first,
      buyerAccountInfo: '$buyerName - $buyerEmail',
      productSubtotal: _toInt(map['product_subtotal']),
      shippingFee: _toInt(map['shipping_fee'], 5000),
      discount: _toInt(map['discount']),
      paymentMethod: _cleanText(map['payment_method']).isNotEmpty
          ? _cleanText(map['payment_method'])
          : 'QRIS',
      supabaseTransactionId: map['transaction_code']?.toString(),
    );
  }
}