class Product {
  final String id;
  final String sellerId;
  final String categoryId;
  final String name;
  final String description;
  final double price;
  final String condition;
  final String imageUrl;
  final List<String> imageUrls;
  final String locationName;
  final double? latitude;
  final double? longitude;
  final String status;
  final DateTime createdAt;

  final String transactionType;
  final int stock;
  final int minPurchase;
  final double? rentalPrice;
  final String? rentalPeriod;
  final int minRentalDuration;

  final String sellerName;
  final String sellerEmail;
  final String sellerNim;
  final String sellerCampus;
  final String sellerFaculty;
  final String sellerStudyProgram;
  final String categoryName;

  const Product({
    required this.id,
    required this.sellerId,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.price,
    required this.condition,
    required this.imageUrl,
    this.imageUrls = const [],
    required this.locationName,
    this.latitude,
    this.longitude,
    required this.status,
    required this.createdAt,
    this.transactionType = 'sale',
    this.stock = 1,
    this.minPurchase = 1,
    this.rentalPrice,
    this.rentalPeriod,
    this.minRentalDuration = 1,
    required this.sellerName,
    required this.sellerEmail,
    required this.sellerNim,
    required this.sellerCampus,
    required this.sellerFaculty,
    required this.sellerStudyProgram,
    required this.categoryName,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    final profile = map['profiles'] as Map<String, dynamic>? ?? {};
    final category = map['categories'] as Map<String, dynamic>? ?? {};
    

    return Product(
      id: map['id'] as String,
      sellerId: map['seller_id'] as String,
      categoryId: map['category_id'] as String,
      name: map['name'] as String,
      description: map['description'] ?? '',
      price: (map['price'] as num).toDouble(),
      condition: map['condition'] ?? '',
      imageUrl: map['image_url'] ?? '',
      imageUrls: List<String>.from(map['image_urls'] ?? []),
      locationName: map['location_name'] ?? '',
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      status: map['status'] ?? 'available',
      createdAt: DateTime.parse(map['created_at'] as String),

      transactionType: map['transaction_type'] ?? 'sale',
      stock: (map['stock'] as num?)?.toInt() ?? 1,
      minPurchase: (map['min_purchase'] as num?)?.toInt() ?? 1,
      rentalPrice: (map['rental_price'] as num?)?.toDouble(),
      rentalPeriod: map['rental_period'],
      minRentalDuration: (map['min_rental_duration'] as num?)?.toInt() ?? 1,

      sellerName: profile['nama'] ?? '',
      sellerEmail: profile['email'] ?? '',
      sellerNim: profile['nim'] ?? '',
      sellerCampus: profile['kampus'] ?? '',
      sellerFaculty: profile['fakultas'] ?? '',
      sellerStudyProgram: profile['program_studi'] ?? '',
      categoryName: category['name'] ?? '',
    );
  }
}
