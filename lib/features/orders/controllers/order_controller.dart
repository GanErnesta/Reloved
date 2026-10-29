import 'package:flutter/material.dart';
import '../models/order_model.dart';

class OrderController extends ChangeNotifier {
  // Data Dummy Slicing (Nantinya diganti fetch dari Supabase)
  final List<OrderModel> _orders = [
    // 1. Pesanan BELI - Multi Item (Efek Menumpuk) - Status: Menunggu
    OrderModel(
      id: 'ORD-001',
      shopId: 'SHOP-FILKOM',
      shopName: 'FilkomShop',
      shopAvatarPath: 'assets/images/shop_avatar.png',
      orderType: OrderType.beli,
      status: OrderStatus.menunggu,
      items: const [
        OrderItemModel(
          id: 'ITM-1',
          productName: 'Kemeja Putih Lengan Panjang',
          imagePath: 'assets/images/kemeja_putih.png',
          price: 102900,
          quantity: 1,
          variant: 'Putih, L',
        ),
        OrderItemModel(
          id: 'ITM-2',
          productName: 'Celana Bahan Hitam Formal',
          imagePath: 'assets/images/celana_hitam.png',
          price: 100000,
          quantity: 1,
          variant: 'Hitam, XL',
        ),
      ],
      orderDateText: 'Rabu, 23 September 2026, 09:15 WIB',
      receivedDateText: 'Sabtu, 26 September 2026, 14:20 WIB',
      pickupAddress:
      'Area Ketawanggede, Kecamatan Lowokwaru, Kota Malang, Provinsi Jawa Timur.',
      deliveryAddress:
      'Gedung Perpustakaan, Jl. Veteran, Ketawanggede, Kec. Lowokwaru, Kota Malang, Jawa Timur 65145',
      buyerAccountInfo: 'falishakeyrani - falishakeyrani@student.ub.ac.id',
      productSubtotal: 202900,
      shippingFee: 5000,
      discount: 0,
      paymentMethod: 'QRIS',
      midtransOrderId: 'MID-RELOVED-001',
    ),

    // 2. Pesanan BELI - 1 Item Tanpa Variasi - Status: Selesai
    OrderModel(
      id: 'ORD-002',
      shopId: 'SHOP-FILKOM',
      shopName: 'FilkomShop',
      shopAvatarPath: 'assets/images/shop_avatar.png',
      orderType: OrderType.beli,
      status: OrderStatus.selesai,
      items: const [
        OrderItemModel(
          id: 'ITM-3',
          productName: 'Kemeja Putih',
          imagePath: 'assets/images/kemeja_putih.png',
          price: 49900,
          quantity: 1,
          variant: null, // Tanpa variasi
        ),
      ],
      orderDateText: 'Rabu, 23 September 2026, 10:00 WIB',
      receivedDateText: 'Sabtu, 26 September 2026, 16:45 WIB',
      pickupAddress:
      'Area Ketawanggede, Kecamatan Lowokwaru, Kota Malang, Provinsi Jawa Timur.',
      deliveryAddress:
      'Gedung Perpustakaan, Jl. Veteran, Ketawanggede, Kec. Lowokwaru, Kota Malang, Jawa Timur 65145',
      buyerAccountInfo: 'falishakeyrani - falishakeyrani@student.ub.ac.id',
      productSubtotal: 49900,
      shippingFee: 5000,
      discount: 0,
      paymentMethod: 'QRIS',
    ),

    // 3. Pesanan SEWA - Status: Dikirim
    OrderModel(
      id: 'ORD-003',
      shopId: 'SHOP-FILKOM',
      shopName: 'FilkomShop',
      shopAvatarPath: 'assets/images/shop_avatar.png',
      orderType: OrderType.sewa,
      status: OrderStatus.dikirim,
      items: const [
        OrderItemModel(
          id: 'ITM-4',
          productName: 'Kemeja Putih',
          imagePath: 'assets/images/kemeja_putih.png',
          price: 49900,
          quantity: 1,
          variant: 'Putih, M',
        ),
      ],
      orderDateText: 'Rabu, 23 September 2026',
      receivedDateText: 'Sabtu, 26 September 2026',
      rentalDurationDays: 3,
      rentalRemainingText: '1 hari lagi',
      rentalReturnDateText: 'Sabtu, 26 September 2026',
      pickupAddress:
      'Area Ketawanggede, Kecamatan Lowokwaru, Kota Malang, Provinsi Jawa Timur.',
      deliveryAddress:
      'Gedung Perpustakaan, Jl. Veteran, Ketawanggede, Kec. Lowokwaru, Kota Malang, Jawa Timur 65145',
      buyerAccountInfo: 'falishakeyrani - falishakeyrani@student.ub.ac.id',
      productSubtotal: 49900,
      shippingFee: 5000,
      discount: 0,
      paymentMethod: 'QRIS',
    ),

    // 4. Pesanan SEWA - Status: Menunggu
    OrderModel(
      id: 'ORD-004',
      shopId: 'SHOP-FILKOM',
      shopName: 'FilkomShop',
      shopAvatarPath: 'assets/images/shop_avatar.png',
      orderType: OrderType.sewa,
      status: OrderStatus.menunggu,
      items: const [
        OrderItemModel(
          id: 'ITM-5',
          productName: 'Jas Laboratorium Kimia',
          imagePath: 'assets/images/kemeja_putih.png',
          price: 35000,
          quantity: 2,
          variant: 'Putih, L',
        ),
      ],
      orderDateText: 'Kamis, 24 September 2026',
      receivedDateText: 'Minggu, 27 September 2026',
      rentalDurationDays: 3,
      rentalRemainingText: '1 hari lagi',
      rentalReturnDateText: 'Minggu, 27 September 2026',
      pickupAddress:
      'Area Ketawanggede, Kecamatan Lowokwaru, Kota Malang, Provinsi Jawa Timur.',
      deliveryAddress:
      'Gedung Perpustakaan, Jl. Veteran, Ketawanggede, Kec. Lowokwaru, Kota Malang, Jawa Timur 65145',
      buyerAccountInfo: 'falishakeyrani - falishakeyrani@student.ub.ac.id',
      productSubtotal: 70000,
      shippingFee: 5000,
      discount: 0,
      paymentMethod: 'QRIS',
    ),
  ];

  List<OrderModel> getOrdersByType(OrderType type) {
    return _orders
        .where((o) => o.orderType == type && o.status != OrderStatus.dibatalkan)
        .toList();
  }

  // ===========================================================================
  // SLOT INTEGRASI SUPABASE & MIDTRANS (Siap disambungkan setelah slicing)
  // ===========================================================================

  /// Membatalkan pesanan (Hanya bisa dipanggil saat status == menunggu)
  Future<void> cancelOrder(String orderId) async {
    // TODO: Integrasi ke Supabase untuk mengubah status order & memicu refund Midtrans
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1 && _orders[index].status == OrderStatus.menunggu) {
      _orders[index].status = OrderStatus.dibatalkan;
      notifyListeners();
    }
  }

  /// Mengganti metode pembayaran / Membuka Snap Midtrans (Hanya saat status == menunggu)
  Future<void> changePaymentMethod(String orderId, String newMethod) async {
    // TODO: Update metode pembayaran di Supabase & regenerate Snap Token Midtrans
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1 && _orders[index].status == OrderStatus.menunggu) {
      _orders[index].paymentMethod = newMethod;
      notifyListeners();
    }
  }
}