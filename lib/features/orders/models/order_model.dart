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
  final String? variant; // Kosongkan (null / '') jika tidak ada variasi warna/ukuran

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

  // Informasi Waktu
  // Untuk Beli: berisi tanggal + jam rinci. Untuk Sewa: berisi hari & tanggal saja.
  final String orderDateText;
  final String receivedDateText;

  // Khusus Tipe Sewa
  final int? rentalDurationDays;
  final String? rentalRemainingText;
  final String? rentalReturnDateText;

  // Informasi Lokasi
  final String pickupAddress;
  final String deliveryAddress;
  final String buyerAccountInfo;

  // Rincian Pembayaran
  final int productSubtotal;
  final int shippingFee;
  final int discount;
  String paymentMethod;

  // Slot Integrasi Backend (Supabase) & Payment Gateway (Midtrans)
  final String? supabaseTransactionId;
  final String? midtransOrderId;
  final String? midtransSnapToken;
  final String? midtransRedirectUrl;

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
    required this.deliveryAddress,
    required this.buyerAccountInfo,
    required this.productSubtotal,
    required this.shippingFee,
    this.discount = 0,
    required this.paymentMethod,
    this.supabaseTransactionId,
    this.midtransOrderId,
    this.midtransSnapToken,
    this.midtransRedirectUrl,
  });

  int get totalProductPrice =>
      items.fold(0, (sum, item) => sum + (item.price * item.quantity));

  int get grandTotal => productSubtotal + shippingFee - discount;
}