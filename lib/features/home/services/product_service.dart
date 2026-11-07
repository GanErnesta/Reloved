import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/product.dart';

class ProductService {
  final SupabaseClient _supabase;

  ProductService({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  static const String _bucketName = 'product-images';
  static const int _maxImages = 5;

  Future<List<Product>> _mapProductsWithProfiles(List<dynamic> rows) async {
    final products = rows
        .map((row) => Map<String, dynamic>.from(row as Map))
        .toList();

    if (products.isEmpty) return [];

    final sellerIds = products
        .map((item) => item['seller_id']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();

    if (sellerIds.isEmpty) {
      return products.map(Product.fromMap).toList();
    }

    final profileResponse = await _supabase
        .from('public_profiles')
        .select('id, nama, kampus, fakultas, program_studi')
        .inFilter('id', sellerIds);

    final Map<String, Map<String, dynamic>> profileMap = {};

    for (final profile in profileResponse) {
      final data = Map<String, dynamic>.from(profile);
      profileMap[data['id'].toString()] = data;
    }

    for (final product in products) {
      final sellerId = product['seller_id']?.toString() ?? '';
      product['profiles'] = profileMap[sellerId] ?? {};
    }

    return products.map(Product.fromMap).toList();
  }

  Future<List<String>> uploadProductImages({
    required List<XFile> images,
  }) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('Pengguna belum login.');
    }

    if (images.isEmpty) {
      throw Exception('Pilih minimal satu foto produk.');
    }

    if (images.length > _maxImages) {
      throw Exception('Maksimal hanya 5 foto produk.');
    }

    final List<String> uploadedPaths = [];
    final List<String> imageUrls = [];

    try {
      for (int i = 0; i < images.length; i++) {
        final image = images[i];

        final extension = image.name.contains('.')
            ? image.name.split('.').last.toLowerCase()
            : 'jpg';

        const allowedExtensions = ['jpg', 'jpeg', 'png', 'webp'];

        if (!allowedExtensions.contains(extension)) {
          throw Exception('Format foto tidak didukung: $extension');
        }

        final contentType = switch (extension) {
          'png' => 'image/png',
          'webp' => 'image/webp',
          _ => 'image/jpeg',
        };

        final Uint8List bytes = await image.readAsBytes();

        if (bytes.isEmpty) {
          throw Exception('File foto kosong.');
        }

        if (bytes.length > 5 * 1024 * 1024) {
          throw Exception('Ukuran foto ${image.name} melebihi 5 MB.');
        }

        final fileName =
            '${DateTime.now().microsecondsSinceEpoch}_$i.$extension';

        final filePath = '${user.id}/$fileName';

        await _supabase.storage
            .from(_bucketName)
            .uploadBinary(
              filePath,
              bytes,
              fileOptions: FileOptions(contentType: contentType, upsert: false),
            );

        uploadedPaths.add(filePath);

        final publicUrl = _supabase.storage
            .from(_bucketName)
            .getPublicUrl(filePath);

        imageUrls.add(publicUrl);
      }

      return imageUrls;
    } catch (e) {
      if (uploadedPaths.isNotEmpty) {
        try {
          await _supabase.storage.from(_bucketName).remove(uploadedPaths);
        } catch (_) {}
      }

      rethrow;
    }
  }

  Future<String> createProduct({
    required String categoryId,
    required String name,
    required String description,
    required double price,
    required String condition,
    required List<XFile> images,
    required String transactionType,
    int stock = 1,
    int minPurchase = 1,
    double? rentalPrice,
    String? rentalPeriod,
    int minRentalDuration = 1,
    String locationName = '',
    double? latitude,
    double? longitude,
  }) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('Pengguna belum login.');
    }

    if (name.trim().isEmpty) {
      throw Exception('Nama produk wajib diisi.');
    }

    if (categoryId.isEmpty) {
      throw Exception('Kategori produk wajib dipilih.');
    }

    if (images.isEmpty || images.length > _maxImages) {
      throw Exception('Pilih 1 sampai 5 foto produk.');
    }

    final dbTransactionType = switch (transactionType) {
      'jual' => 'sale',
      'sewa' => 'rent',
      'sale' => 'sale',
      'rent' => 'rent',
      _ => throw Exception('Jenis transaksi tidak valid.'),
    };

    if (dbTransactionType == 'sale' && (price <= 0 || stock <= 0)) {
      throw Exception('Harga dan stok harus lebih dari 0.');
    }

    if (dbTransactionType == 'rent') {
      if (rentalPrice == null || rentalPrice <= 0) {
        throw Exception('Harga sewa harus lebih dari 0.');
      }

      if (rentalPeriod == null || rentalPeriod.isEmpty) {
        throw Exception('Periode sewa wajib dipilih.');
      }

      if (minRentalDuration <= 0) {
        throw Exception('Durasi sewa tidak valid.');
      }
    }

    List<String> uploadedPaths = [];

    try {
      final imageUrls = await uploadProductImages(images: images);

      uploadedPaths = imageUrls.map((url) {
        return url.split('/$_bucketName/').last;
      }).toList();

      final productData = <String, dynamic>{
        'seller_id': user.id,
        'category_id': categoryId,
        'name': name.trim(),
        'description': description.trim(),
        'price': dbTransactionType == 'sale' ? price : rentalPrice!,
        'condition': condition,
        'image_url': imageUrls.first,
        'image_urls': imageUrls,
        'transaction_type': dbTransactionType,
        'stock': dbTransactionType == 'sale' ? stock : 1,
        'min_purchase': dbTransactionType == 'sale' ? minPurchase : 1,
        'status': 'available',
        'location_name': locationName,
      };

      if (dbTransactionType == 'rent') {
        productData.addAll({
          'rental_price': rentalPrice,
          'rental_period': rentalPeriod,
          'min_rental_duration': minRentalDuration,
        });
      }

      final response = await _supabase
          .from('products')
          .insert(productData)
          .select('id')
          .single();

      return response['id'].toString();
    } catch (e) {
      if (uploadedPaths.isNotEmpty) {
        try {
          await _supabase.storage.from(_bucketName).remove(uploadedPaths);
        } catch (_) {}
      }

      rethrow;
    }
  }

  Future<List<Product>> getLatestProducts() async {
    final response = await _supabase
        .from('products')
        .select('''
          *,
          categories (
            id,
            name
          )
        ''')
        .eq('status', 'available')
        .order('created_at', ascending: false)
        .limit(10);

    return _mapProductsWithProfiles(response);
  }

  Future<List<Product>> getMabaProducts() async {
    final response = await _supabase
        .from('products')
        .select('''
          *,
          categories (
            id,
            name
          )
        ''')
        .eq('status', 'available')
        .order('created_at', ascending: false);

    final products = await _mapProductsWithProfiles(response);

    const mabaKeywords = [
      'almamater',
      'ospek',
      'kemeja',
      'putih',
      'hitam',
      'pantofel',
      'sepatu',
      'tas',
      'buku',
      'alat tulis',
      'jas',
      'celana',
      'rok',
      'dasi',
    ];

    return products.where((product) {
      final searchableText = '${product.name} ${product.categoryName}'
          .toLowerCase();

      return mabaKeywords.any((keyword) => searchableText.contains(keyword));
    }).toList();
  }

  Future<List<Product>> searchProducts(String keyword) async {
    final query = keyword.trim();

    if (query.isEmpty) return [];

    final searchPattern = '%$query%';

    final responses = await Future.wait([
      _supabase
          .from('products')
          .select('''
            *,
            categories (
              id,
              name
            )
          ''')
          .eq('status', 'available')
          .or('name.ilike.$searchPattern,description.ilike.$searchPattern')
          .order('created_at', ascending: false),
      _supabase.from('categories').select('id').ilike('name', searchPattern),
    ]);

    final productResults = responses[0] as List;
    final categoryResults = responses[1] as List;

    final categoryIds = categoryResults
        .map((item) => item['id'].toString())
        .toList();

    List<dynamic> categoryProducts = [];

    if (categoryIds.isNotEmpty) {
      categoryProducts = await _supabase
          .from('products')
          .select('''
            *,
            categories (
              id,
              name
            )
          ''')
          .eq('status', 'available')
          .inFilter('category_id', categoryIds);
    }

    final Map<String, dynamic> uniqueProducts = {};

    for (final item in [...productResults, ...categoryProducts]) {
      uniqueProducts[item['id'].toString()] = item;
    }

    final products = await _mapProductsWithProfiles(
      uniqueProducts.values.toList(),
    );

    products.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return products;
  }

  Future<Product> getProductById(String id) async {
    final response = await _supabase
        .from('products')
        .select('''
          *,
          categories (
            id,
            name
          )
        ''')
        .eq('id', id)
        .single();

    final products = await _mapProductsWithProfiles([response]);

    return products.first;
  }

  Future<List<Product>> getMyProducts() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('Pengguna belum login.');
    }

    final response = await _supabase
        .from('products')
        .select('''
          *,
          categories (
            id,
            name
          )
        ''')
        .eq('seller_id', user.id)
        .order('created_at', ascending: false);

    return _mapProductsWithProfiles(response);
  }

  Future<List<Product>> getProductsByCategory(String categoryName) async {
    final normalizedName = categoryName.replaceAll('\n', ' ').trim();

    final categoryResponse = await _supabase
        .from('categories')
        .select('id')
        .ilike('name', normalizedName)
        .maybeSingle();

    if (categoryResponse == null) {
      return [];
    }

    final response = await _supabase
        .from('products')
        .select('''
          *,
          categories (
            id,
            name
          )
        ''')
        .eq('status', 'available')
        .eq('category_id', categoryResponse['id'])
        .order('created_at', ascending: false);

    return _mapProductsWithProfiles(response);
  }

  Future<List<Product>> getRentalProducts() async {
    final response = await _supabase
        .from('products')
        .select('''
        *,
        categories (
          id,
          name
        )
      ''')
        .eq('status', 'available')
        .eq('transaction_type', 'rent')
        .order('created_at', ascending: false);

    return _mapProductsWithProfiles(response);
  }
}
