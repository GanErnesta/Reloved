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

  // Khusus Tipe Sewa
  final int? rentalDurationDays;
  final String? rentalRemainingText;
  final String? rentalReturnDateText;

  // Lokasi: Seller memiliki alamat tetap (pickupAddress), Buyer menggunakan Safe Meeting Point
  final String pickupAddress;
  SafeMeetingPointModel safeMeetingPoint;
  final String buyerAccountInfo;

  // Rincian Pembayaran
  final int productSubtotal;
  final int shippingFee;
  final int discount;
  final String paymentMethod;

  // Slot Integrasi Backend (Supabase) & Payment Gateway (Midtrans)
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
}