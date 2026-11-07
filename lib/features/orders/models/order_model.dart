import 'safe_meeting_point_model.dart';

enum OrderType { beli, sewa }

enum OrderStatus {
  menunggu,
  dikirim,
  terkirim,
  selesai,
  dibatalkan,
}

class OrderItemModel {
  final String id;
  final String productName;
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
    return OrderItemModel(
      id: (map['id'] ?? '').toString(),
      productName: (map['product_name_snapshot'] ?? 'Produk').toString(),
      imagePath: (map['product_image_snapshot'] ?? 'assets/images/kemeja_putih.png').toString(),
      price: ((map['unit_price'] ?? 0) as num).toInt(),
      quantity: ((map['quantity'] ?? 1) as num).toInt(),
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

  static String _formatDateTime(String? isoString, {required bool includeTime}) {
    if (isoString == null || isoString.isEmpty) return '-';
    final dt = DateTime.tryParse(isoString)?.toLocal();
    if (dt == null) return isoString;

    const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
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
    final seller = map['seller'] as Map<String, dynamic>? ?? {};
    final buyer = map['buyer'] as Map<String, dynamic>? ?? {};
    final smpMap = map['safe_meeting_points'] as Map<String, dynamic>?;
    final rawItems = map['order_items'] as List<dynamic>? ?? [];

    final rawType = (map['order_type'] ?? 'beli').toString().toLowerCase();
    final bool isSewa = rawType == 'sewa' || rawType == 'rent';

    final parsedItems = rawItems
        .map((e) => OrderItemModel.fromSupabaseMap(Map<String, dynamic>.from(e as Map)))
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

    final buyerName = (buyer['nama'] ?? 'Mahasiswa').toString();
    final buyerEmail = (buyer['email'] ?? 'student@student.ub.ac.id').toString();

    return OrderModel(
      id: (map['id'] ?? '').toString(),
      shopId: (map['seller_id'] ?? '').toString(),
      shopName: (seller['nama'] ?? 'Toko Mahasiswa').toString(),
      shopAvatarPath: (seller['foto_profil'] ?? 'assets/images/shop_avatar.png').toString(),
      orderType: isSewa ? OrderType.sewa : OrderType.beli,
      status: _parseStatus((map['buyer_status'] ?? 'menunggu').toString()),
      items: parsedItems.isNotEmpty
          ? parsedItems
          : const [
        OrderItemModel(
          id: 'EMPTY',
          productName: 'Produk',
          imagePath: 'assets/images/kemeja_putih.png',
          price: 0,
          quantity: 1,
        ),
      ],
      orderDateText: _formatDateTime(map['ordered_at']?.toString(), includeTime: !isSewa),
      receivedDateText: map['received_at'] != null
          ? _formatDateTime(map['received_at']?.toString(), includeTime: !isSewa)
          : 'Menunggu konfirmasi penerimaan',
      rentalDurationDays: durationDays,
      rentalRemainingText: remainingText,
      rentalReturnDateText: rentalEnd != null
          ? _formatDateTime(rentalEnd.toIso8601String(), includeTime: false)
          : null,
      pickupAddress: (map['pickup_address'] ?? 'Area Ketawanggede, Malang').toString(),
      safeMeetingPoint: smpMap != null
          ? SafeMeetingPointModel.fromMap(smpMap)
          : SafeMeetingPointModel.campusPoints.first,
      buyerAccountInfo: '$buyerName - $buyerEmail',
      productSubtotal: ((map['product_subtotal'] ?? 0) as num).toInt(),
      shippingFee: ((map['shipping_fee'] ?? 5000) as num).toInt(),
      discount: ((map['discount'] ?? 0) as num).toInt(),
      paymentMethod: (map['payment_method'] ?? 'QRIS').toString(),
      supabaseTransactionId: map['transaction_code']?.toString(),
    );
  }
}