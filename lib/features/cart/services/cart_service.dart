import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/supabase_config.dart';
import '../controllers/cart_controller.dart';
import '../models/cart_model.dart';

/// Dipakai oleh ProductDetailScreen:
///  - [addToCart]         -> tombol "+ Keranjang" (qty digabung jika sudah ada)
///  - [createBuyNowItem]  -> tombol "Beli" (baris keranjang terpisah, langsung
///                           dibawa ke CheckoutScreen)
class CartService {
  SupabaseClient get _supabase => SupabaseConfig.client;

  /// Select yang sama dengan CartRepository.fetchCartItems, supaya hasilnya
  /// bisa langsung di-parse oleh CartItemModel.fromSupabaseMap.
  static const String _cartItemSelect = '''
    *,
    products (
      *,
      profiles!products_seller_id_fkey (
        id, nama, city, address
      )
    )
  ''';

  String get _userId {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('Pengguna belum login');
    }

    return user.id;
  }

  // ---------------------------------------------------------------------------
  // Validasi bersama
  // ---------------------------------------------------------------------------

  /// Memvalidasi permintaan dan mengembalikan stok produk saat ini.
  Future<int> _validateRequest(
      String productId, {
        required String transactionType,
        required int quantity,
        int? rentalDuration,
        String? rentalPeriod,
      }) async {
    if (transactionType != 'sale' && transactionType != 'rent') {
      throw Exception('Jenis transaksi tidak valid');
    }

    if (quantity <= 0) {
      throw Exception('Jumlah barang tidak valid');
    }

    if (transactionType == 'rent') {
      if (rentalDuration == null || rentalDuration <= 0) {
        throw Exception('Durasi sewa tidak valid');
      }

      if (!['daily', 'weekly', 'monthly'].contains(rentalPeriod)) {
        throw Exception('Periode sewa tidak valid');
      }
    }

    final product = await _supabase
        .from('products')
        .select('stock, min_purchase, status')
        .eq('id', productId)
        .single();

    final stock = (product['stock'] as num?)?.toInt() ?? 1;
    final minimum = (product['min_purchase'] as num?)?.toInt() ?? 1;

    if (product['status'] != 'available') {
      throw Exception('Produk tidak tersedia');
    }

    if (stock <= 0 || quantity > stock) {
      throw Exception('Jumlah melebihi stok yang tersedia');
    }

    if (quantity < minimum) {
      throw Exception('Jumlah kurang dari minimum pembelian');
    }

    return stock;
  }

  // ---------------------------------------------------------------------------
  // "+ Keranjang"
  // ---------------------------------------------------------------------------

  Future<void> addToCart(
      String productId, {
        String transactionType = 'sale',
        int quantity = 1,
        int? rentalDuration,
        String? rentalPeriod,
      }) async {
    final userId = _userId;

    final stock = await _validateRequest(
      productId,
      transactionType: transactionType,
      quantity: quantity,
      rentalDuration: rentalDuration,
      rentalPeriod: rentalPeriod,
    );

    var existingQuery = _supabase
        .from('cart_items')
        .select('id, quantity')
        .eq('user_id', userId)
        .eq('product_id', productId)
        .eq('transaction_type', transactionType);

    if (transactionType == 'rent') {
      existingQuery = existingQuery
          .eq('rental_duration', rentalDuration!)
          .eq('rental_period', rentalPeriod!);
    }

    final existing = await existingQuery.maybeSingle();

    if (existing != null) {
      final currentQuantity = (existing['quantity'] as num).toInt();
      final newQuantity = currentQuantity + quantity;

      if (newQuantity > stock) {
        throw Exception('Jumlah barang melebihi stok yang tersedia');
      }

      await _supabase
          .from('cart_items')
          .update({'quantity': newQuantity})
          .eq('id', existing['id'])
          .eq('user_id', userId);
    } else {
      await _supabase.from('cart_items').insert(
        _buildInsertPayload(
          userId: userId,
          productId: productId,
          transactionType: transactionType,
          quantity: quantity,
          rentalDuration: rentalDuration,
          rentalPeriod: rentalPeriod,
        ),
      );
    }

    // Segarkan keranjang di memori supaya item baru langsung muncul
    // saat user membuka layar Keranjang.
    unawaited(CartController.instance.loadCartFromSupabase());
  }

  // ---------------------------------------------------------------------------
  // "Beli" (langsung ke checkout)
  // ---------------------------------------------------------------------------

  /// Membuat baris keranjang BARU (tidak digabung dengan baris yang sudah ada)
  /// berisi qty yang dipilih user, lalu mengembalikannya sebagai
  /// [CartItemModel] untuk dikirim ke CheckoutScreen.
  ///
  /// Baris ini diperlukan karena fungsi checkout di database
  /// (start_checkout_payment_session) bekerja berdasarkan id cart_items.
  /// Jika user membatalkan checkout, panggil [deleteCartItem] agar tidak
  /// tertinggal di keranjang.
  ///
  /// Catatan: CartController sengaja TIDAK di-refresh di sini, supaya baris
  /// sementara ini tidak sempat muncul di layar Keranjang.
  Future<CartItemModel> createBuyNowItem(
      String productId, {
        String transactionType = 'sale',
        int quantity = 1,
        int? rentalDuration,
        String? rentalPeriod,
      }) async {
    final userId = _userId;

    await _validateRequest(
      productId,
      transactionType: transactionType,
      quantity: quantity,
      rentalDuration: rentalDuration,
      rentalPeriod: rentalPeriod,
    );

    final inserted = await _supabase
        .from('cart_items')
        .insert(
      _buildInsertPayload(
        userId: userId,
        productId: productId,
        transactionType: transactionType,
        quantity: quantity,
        rentalDuration: rentalDuration,
        rentalPeriod: rentalPeriod,
      ),
    )
        .select('id')
        .single();

    final cartItemId = inserted['id'].toString();

    try {
      final row = await _supabase
          .from('cart_items')
          .select(_cartItemSelect)
          .eq('id', cartItemId)
          .eq('user_id', userId)
          .single();

      return CartItemModel.fromSupabaseMap(Map<String, dynamic>.from(row));
    } catch (e) {
      // Gagal membaca kembali: bersihkan baris yang baru dibuat.
      try {
        await deleteCartItem(cartItemId);
      } catch (cleanupError) {
        debugPrint('[CartService] gagal membersihkan cart item: $cleanupError');
      }
      rethrow;
    }
  }

  Future<void> deleteCartItem(String cartItemId) async {
    await _supabase
        .from('cart_items')
        .delete()
        .eq('id', cartItemId)
        .eq('user_id', _userId);
  }

  // ---------------------------------------------------------------------------

  Map<String, dynamic> _buildInsertPayload({
    required String userId,
    required String productId,
    required String transactionType,
    required int quantity,
    int? rentalDuration,
    String? rentalPeriod,
  }) {
    final bool isRent = transactionType == 'rent';

    return {
      'user_id': userId,
      'product_id': productId,
      'quantity': quantity,
      'transaction_type': transactionType,
      'rental_duration': isRent ? rentalDuration : null,
      'rental_period': isRent ? rentalPeriod : null,
      'rental_start_date':
      isRent ? DateTime.now().toIso8601String().split('T').first : null,
      'is_selected': true,
    };
  }
}