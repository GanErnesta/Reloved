
import '../../home/models/product.dart';

class CartItem {
  final String id;
  final String userId;
  final String productId;
  final int quantity;
  final DateTime createdAt;
  final Product product;

  final String transactionType;
  final int? rentalDuration;
  final String? rentalPeriod;

  const CartItem({
    required this.id,
    required this.userId,
    required this.productId,
    required this.quantity,
    required this.createdAt,
    required this.product,
    this.transactionType = 'sale',
    this.rentalDuration,
    this.rentalPeriod,
  });

  bool get isRent => transactionType == 'rent';

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      productId: map['product_id'] as String,
      quantity: (map['quantity'] as num).toInt(),
      createdAt: DateTime.parse(map['created_at'] as String),
      product: Product.fromMap(
        map['products'] as Map<String, dynamic>,
      ),
      transactionType: map['transaction_type'] ?? 'sale',
      rentalDuration: (map['rental_duration'] as num?)?.toInt(),
      rentalPeriod: map['rental_period'] as String?,
    );
  }

  CartItem copyWith({
    int? quantity,
    String? transactionType,
    int? rentalDuration,
    String? rentalPeriod,
  }) {
    return CartItem(
      id: id,
      userId: userId,
      productId: productId,
      quantity: quantity ?? this.quantity,
      createdAt: createdAt,
      product: product,
      transactionType: transactionType ?? this.transactionType,
      rentalDuration: rentalDuration ?? this.rentalDuration,
      rentalPeriod: rentalPeriod ?? this.rentalPeriod,
    );
  }
}
