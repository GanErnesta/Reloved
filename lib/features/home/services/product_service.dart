
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

  // ============================================================
  // UPLOAD PRODUCT IMAGES
  // ============================================================

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
          throw Exception(
            'Ukuran foto ${image.name} melebihi 5 MB.',
          );
        }

        final fileName =
            '${DateTime.now().microsecondsSinceEpoch}_$i.$extension';

        // Folder pertama harus sama dengan ID user
        // sesuai Storage Policy yang sudah dibuat.
        final filePath = '${user.id}/$fileName';

        await _supabase.storage.from(_bucketName).uploadBinary(
              filePath,
              bytes,
              fileOptions: FileOptions(
                contentType: contentType,
                upsert: false,
              ),
            );

        uploadedPaths.add(filePath);

        final publicUrl = _supabase.storage
            .from(_bucketName)
            .getPublicUrl(filePath);

        imageUrls.add(publicUrl);
      }

      return imageUrls;
    } catch (e) {
      // Hapus foto yang sudah terunggah jika ada kegagalan.
      if (uploadedPaths.isNotEmpty) {
        try {
          await _supabase.storage
              .from(_bucketName)
              .remove(uploadedPaths);
        } catch (_) {
          // Pertahankan error upload utama.
        }
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

    // Samakan nilai transaksi dari UI dengan database.
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
      // 1. Upload foto ke Supabase Storage.
      final imageUrls = await uploadProductImages(images: images);

      // Simpan path file untuk keperluan rollback.
      uploadedPaths = imageUrls.map((url) {
        return url.split('/$_bucketName/').last;
      }).toList();

      // 2. Siapkan data produk.
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

      // 3. Tambahkan informasi sewa jika transaksi Sewa.
      if (dbTransactionType == 'rent') {
        productData.addAll({
          'rental_price': rentalPrice,
          'rental_period': rentalPeriod,
          'min_rental_duration': minRentalDuration,
        });
      }

      // 4. Simpan produk ke database.
      final response = await _supabase
          .from('products')
          .insert(productData)
          .select('id')
          .single();

      return response['id'].toString();
    } catch (e) {
      // 5. Rollback foto jika penyimpanan produk gagal.
      if (uploadedPaths.isNotEmpty) {
        try {
          await _supabase.storage
              .from(_bucketName)
              .remove(uploadedPaths);
        } catch (_) {
          // Pertahankan error utama.
        }
      }

      rethrow;
    }
  }

  // ============================================================
  // GET LATEST PRODUCTS
  // ============================================================

  Future<List<Product>> getLatestProducts() async {
    final response = await _supabase
        .from('products')
        .select('''
          *,
          profiles (
            id,
            nama,
            email,
            nim,
            kampus,
            fakultas,
            program_studi
          ),
          categories (
            id,
            name
          )
        ''')
        .eq('status', 'available')
        .order('created_at', ascending: false)
        .limit(10);

    return response.map<Product>((item) => Product.fromMap(item)).toList();
  }

  // ============================================================
  // GET MABA PRODUCTS
  // ============================================================

  Future<List<Product>> getMabaProducts() async {
    final response = await _supabase
        .from('products')
        .select('''
          *,
          profiles (
            id,
            nama,
            email,
            nim,
            kampus,
            fakultas,
            program_studi
          ),
          categories (
            id,
            name
          )
        ''')
        .eq('status', 'available')
        .order('created_at', ascending: false);

    final products = response
        .map<Product>((item) => Product.fromMap(item))
        .toList();

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
      final searchableText =
          '${product.name} ${product.categoryName}'.toLowerCase();

      return mabaKeywords.any((keyword) => searchableText.contains(keyword));
    }).toList();
  }

  // ============================================================
  // SEARCH PRODUCTS
  // ============================================================

  Future<List<Product>> searchProducts(String keyword) async {
    final query = keyword.trim();

    if (query.isEmpty) return [];

    final searchPattern = '%$query%';

    final responses = await Future.wait([
      _supabase
          .from('products')
          .select('''
            *,
            profiles (
              id,
              nama,
              email,
              nim,
              kampus,
              fakultas,
              program_studi
            ),
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
            profiles (
              id,
              nama,
              email,
              nim,
              kampus,
              fakultas,
              program_studi
            ),
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

    final products = uniqueProducts.values
        .map((item) => Product.fromMap(item))
        .toList();

    products.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return products;
  }

  // ============================================================
  // GET PRODUCT BY ID
  // ============================================================

  Future<Product> getProductById(String id) async {
    final response = await _supabase
        .from('products')
        .select('''
          *,
          profiles (
            id,
            nama,
            email,
            nim,
            kampus,
            fakultas,
            program_studi
          ),
          categories (
            id,
            name
          )
        ''')
        .eq('id', id)
        .single();

    return Product.fromMap(response);
  }

  // ============================================================
  // GET MY PRODUCTS
  // ============================================================

  Future<List<Product>> getMyProducts() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('Pengguna belum login.');
    }

    final response = await _supabase
        .from('products')
        .select('''
          *,
          profiles (
            id,
            nama,
            email,
            nim,
            kampus,
            fakultas,
            program_studi
          ),
          categories (
            id,
            name
          )
        ''')
        .eq('seller_id', user.id)
        .order('created_at', ascending: false);

    return response.map<Product>((item) => Product.fromMap(item)).toList();
  }
}
