import '../../orders/models/order_model.dart';
import '../../orders/models/safe_meeting_point_model.dart';

class CartItemModel {
  final String id;
  final String productId;
  final String shopId;
  final String shopName;
  final String sellerCity; // Didapat dari alamat seller
  final String sellerPickupAddress;
  final OrderType type;
  final String productName;
  final String imagePath;
  final String subtitleInfo; // Contoh: "Ukuran M · Kondisi sangat baik" atau "Ukuran 43 · Mulai 30 Okt"
  final int unitPrice; // Harga beli satuan atau harga sewa per hari
  final int availableStock;
  final DateTime addedAt; // Untuk mengurutkan barang terbaru di paling atas

  bool isSelected;
  int quantity;

  // Khusus Produk Sewa
  int selectedRentalDays; // Pilihan: 1, 3, atau 7 hari
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

  /// Total harga item:
  /// - Jika Beli: unitPrice * quantity
  /// - Jika Sewa: unitPrice (per hari) * selectedRentalDays * quantity
  int get subtotalPrice {
    if (type == OrderType.sewa) {
      return unitPrice * selectedRentalDays * quantity;
    }
    return unitPrice * quantity;
  }

  /// Menghasilkan teks rentang tanggal sewa dinamis berdasarkan durasi (1h / 3h / 7h)
  String get rentalDateRangeText {
    final start = rentalStartDate ?? DateTime(2026, 10, 30);
    final end = start.add(Duration(days: selectedRentalDays - 1));
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    if (start.month == end.month && start.year == end.year) {
      if (start.day == end.day) {
        return '${start.day} ${months[start.month - 1]} ${start.year}';
      }
      return '${start.day} – ${end.day} ${months[start.month - 1]} ${start.year}';
    }
    return '${start.day} ${months[start.month - 1]} – ${end.day} ${months[end.month - 1]} ${end.year}';
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

/// Menyimpan sesi pembayaran yang sedang berjalan (Stuck / Lock Screen)
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
  final DateTime expiresAt; // 30 menit atau 1 jam sejak klik "Bayar Sekarang"

  // Slot Midtrans & Supabase
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