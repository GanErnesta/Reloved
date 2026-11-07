import '../../orders/models/order_model.dart';
import '../../orders/models/safe_meeting_point_model.dart';

class CartItemModel {
  final String id;
  final String productId;
  final String shopId;
  final String shopName;
  final String sellerCity;
  final String sellerPickupAddress;
  final OrderType type;
  final String productName;
  final String imagePath;
  final String subtitleInfo;
  final int unitPrice;
  final int availableStock;
  final DateTime addedAt;

  bool isSelected;
  int quantity;

  int selectedRentalDays;
  final DateTime? rentalStartDate;
  final int refundableDeposit;

  CartItemModel({
    required this.id,
    required this.productId,
    required this.shopId,
    required this.shopName,
    required this.sellerCity,
    required this.sellerPickupAddress,
    required this.type,
    required this.productName,
    required this.imagePath,
    required this.subtitleInfo,
    required this.unitPrice,
    this.availableStock = 5,
    required this.addedAt,
    this.isSelected = false,
    this.quantity = 1,
    this.selectedRentalDays = 3,
    this.rentalStartDate,
    this.refundableDeposit = 100000,
  });

  factory CartItemModel.fromSupabaseMap(Map<String, dynamic> map) {
    final product = map['products'] as Map<String, dynamic>? ?? {};
    final seller = product['profiles'] as Map<String, dynamic>? ?? {};
    final rawType = (map['transaction_type'] ?? product['transaction_type'] ?? 'sale')
        .toString()
        .toLowerCase();
    final bool isSewa = rawType == 'rent' || rawType == 'sewa';

    final int unitPrice = isSewa
        ? ((product['rental_price'] ?? product['price'] ?? 0) as num).toInt()
        : ((product['price'] ?? 0) as num).toInt();

    return CartItemModel(
      id: (map['id'] ?? '').toString(),
      productId: (map['product_id'] ?? '').toString(),
      shopId: (product['seller_id'] ?? '').toString(),
      shopName: (seller['nama'] ?? 'Toko Mahasiswa').toString(),
      sellerCity: (seller['city'] ?? 'Malang').toString(),
      sellerPickupAddress: (seller['address'] ??
          'Area Ketawanggede, Kecamatan Lowokwaru, Kota Malang.')
          .toString(),
      type: isSewa ? OrderType.sewa : OrderType.beli,
      productName: (product['name'] ?? '').toString(),
      imagePath:
      (product['image_url'] ?? 'assets/images/kemeja_putih.png').toString(),
      subtitleInfo: (product['variant'] ??
          'Kondisi ${product['condition'] ?? 'sangat baik'}')
          .toString(),
      unitPrice: unitPrice,
      availableStock: (product['stock'] as num?)?.toInt() ?? 1,
      addedAt: DateTime.tryParse((map['created_at'] ?? '').toString()) ??
          DateTime.now(),
      isSelected: (map['is_selected'] as bool?) ?? true,
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
      selectedRentalDays: (map['rental_duration'] as num?)?.toInt() ?? 3,
      rentalStartDate: map['rental_start_date'] != null
          ? DateTime.tryParse(map['rental_start_date'].toString())
          : DateTime.now(),
      refundableDeposit: ((product['deposit_amount'] ?? 0) as num).toInt(),
    );
  }

  int get subtotalPrice {
    if (type == OrderType.sewa) {
      return unitPrice * selectedRentalDays * quantity;
    }
    return unitPrice * quantity;
  }

  String get rentalDateRangeText {
    final start = rentalStartDate ?? DateTime.now();
    final end = start.add(Duration(days: selectedRentalDays - 1));
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
    if (start.month == end.month && start.year == end.year) {
      if (start.day == end.day) {
        return '${start.day} ${months[start.month - 1]} ${start.year}';
      }
      return '${start.day} - ${end.day} ${months[start.month - 1]} ${start.year}';
    }
    return '${start.day} ${months[start.month - 1]} - ${end.day} ${months[end.month - 1]} ${end.year}';
  }
}

class CartShopGroup {
  final String shopId;
  final String shopName;
  final String sellerCity;
  final List<CartItemModel> items;

  CartShopGroup({
    required this.shopId,
    required this.shopName,
    required this.sellerCity,
    required this.items,
  });

  String get shopInitial =>
      shopName.isNotEmpty ? shopName[0].toUpperCase() : 'S';

  bool get isAllSelected =>
      items.isNotEmpty && items.every((item) => item.isSelected);
}

class PendingPaymentSession {
  final String sessionId;
  final List<CartItemModel> checkedOutItems;
  final SafeMeetingPointModel safeMeetingPoint;
  final String pickupAddress;
  final String buyerAccountInfo;
  final String paymentMethod;
  final int productSubtotal;
  final int shippingFee;
  final int discount;
  final DateTime expiresAt;
  final String? midtransOrderId;
  final String? qrisString;

  PendingPaymentSession({
    required this.sessionId,
    required this.checkedOutItems,
    required this.safeMeetingPoint,
    required this.pickupAddress,
    required this.buyerAccountInfo,
    required this.paymentMethod,
    required this.productSubtotal,
    required this.shippingFee,
    this.discount = 0,
    required this.expiresAt,
    this.midtransOrderId,
    this.qrisString,
  });

  int get grandTotal => productSubtotal + shippingFee - discount;

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}