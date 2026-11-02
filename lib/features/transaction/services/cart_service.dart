
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/cart_item.dart';

class CartService {
  final SupabaseClient _supabase;

  CartService({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  String get _userId {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('Pengguna belum login');
    }

    return user.id;
  }

  Future<void> addToCart(
    String productId, {
    String transactionType = 'sale',
    int quantity = 1,
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

    var existingQuery = _supabase
        .from('cart_items')
        .select('id, quantity')
        .eq('user_id', _userId)
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
          .update({
            'quantity': newQuantity,
          })
          .eq('id', existing['id'])
          .eq('user_id', _userId);
    } else {
      await _supabase.from('cart_items').insert({
        'user_id': _userId,
        'product_id': productId,
        'quantity': quantity,
        'transaction_type': transactionType,
        'rental_duration': transactionType == 'rent'
            ? rentalDuration
            : null,
        'rental_period': transactionType == 'rent'
            ? rentalPeriod
            : null,
      });
    }
  }

  Future<List<CartItem>> getCartItems() async {
    final response = await _supabase
        .from('cart_items')
        .select('''
          *,
          products (
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
          )
        ''')
        .eq('user_id', _userId)
        .order('created_at', ascending: false);

    return response
        .map<CartItem>((item) => CartItem.fromMap(item))
        .toList();
  }

  Future<void> updateQuantity(
    String cartItemId,
    int quantity,
  ) async {
    if (quantity <= 0) {
      throw Exception('Jumlah barang tidak valid');
    }

    final item = await _supabase
        .from('cart_items')
        .select('product_id')
        .eq('id', cartItemId)
        .eq('user_id', _userId)
        .single();

    final product = await _supabase
        .from('products')
        .select('stock, min_purchase')
        .eq('id', item['product_id'])
        .single();

    final stock = (product['stock'] as num?)?.toInt() ?? 1;
    final minimum = (product['min_purchase'] as num?)?.toInt() ?? 1;

    if (quantity > stock) {
      throw Exception('Jumlah melebihi stok yang tersedia');
    }

    if (quantity < minimum) {
      throw Exception('Jumlah kurang dari minimum pembelian');
    }

    await _supabase
        .from('cart_items')
        .update({
          'quantity': quantity,
        })
        .eq('id', cartItemId)
        .eq('user_id', _userId);
  }

  Future<void> removeFromCart(String cartItemId) async {
    await _supabase
        .from('cart_items')
        .delete()
        .eq('id', cartItemId)
        .eq('user_id', _userId);
  }

  Future<void> clearCart() async {
    await _supabase
        .from('cart_items')
        .delete()
        .eq('user_id', _userId);
  }
}
