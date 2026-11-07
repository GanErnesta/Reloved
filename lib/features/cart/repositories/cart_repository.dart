import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../orders/models/safe_meeting_point_model.dart';
import '../models/cart_model.dart';

class CartRepository {
  SupabaseClient get _supabase => Supabase.instance.client;

  String? get _currentUserId => _supabase.auth.currentUser?.id;

  Future<List<CartItemModel>> fetchCartItems() async {
    final userId = _currentUserId;
    if (userId == null) return [];

    try {
      final response = await _supabase
          .from('cart_items')
          .select('''
            *,
            products (
              *,
              profiles (*),
              categories (*)
            )
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final list = response as List<dynamic>;
      return list
          .map(
            (row) => CartItemModel.fromSupabaseMap(
          Map<String, dynamic>.from(row as Map),
        ),
      )
          .toList();
    } catch (e) {
      debugPrint('Fallback fetchCartItems tanpa relasi kategori: $e');
      final fallbackResponse = await _supabase
          .from('cart_items')
          .select('''
            *,
            products (
              *,
              profiles (*)
            )
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final list = fallbackResponse as List<dynamic>;
      return list
          .map(
            (row) => CartItemModel.fromSupabaseMap(
          Map<String, dynamic>.from(row as Map),
        ),
      )
          .toList();
    }
  }

  Future<void> addToCart({
    required String productId,
    required bool isRental,
    int quantity = 1,
    int? rentalDuration,
    DateTime? rentalStartDate,
  }) async {
    final userId = _currentUserId;
    if (userId == null) return;

    await _supabase.from('cart_items').insert({
      'user_id': userId,
      'product_id': productId,
      'quantity': quantity,
      'transaction_type': isRental ? 'rent' : 'sale',
      'rental_duration': isRental ? (rentalDuration ?? 3) : null,
      'rental_period': isRental ? 'daily' : null,
      'rental_start_date': rentalStartDate?.toIso8601String().split('T').first,
      'is_selected': true,
    });
  }

  Future<void> updateCartItem(
      String cartItemId, {
        int? quantity,
        int? rentalDuration,
        bool? isSelected,
      }) async {
    final Map<String, dynamic> updates = {};
    if (quantity != null) updates['quantity'] = quantity;
    if (rentalDuration != null) updates['rental_duration'] = rentalDuration;
    if (isSelected != null) updates['is_selected'] = isSelected;

    if (updates.isEmpty) return;

    try {
      await _supabase.from('cart_items').update(updates).eq('id', cartItemId);
    } catch (e) {
      // Fallback jika kolom is_selected belum ada di tabel cart_items temanmu
      if (updates.containsKey('is_selected') && updates.length > 1) {
        updates.remove('is_selected');
        await _supabase.from('cart_items').update(updates).eq('id', cartItemId);
      } else {
        debugPrint('Info updateCartItem: $e');
      }
    }
  }

  Future<void> deleteCartItem(String cartItemId) async {
    await _supabase.from('cart_items').delete().eq('id', cartItemId);
  }

  Future<List<SafeMeetingPointModel>> fetchSafeMeetingPoints() async {
    final response = await _supabase
        .from('safe_meeting_points')
        .select()
        .eq('is_active', true);

    final list = response as List<dynamic>;
    return list
        .map(
          (row) => SafeMeetingPointModel.fromMap(
        Map<String, dynamic>.from(row as Map),
      ),
    )
        .toList();
  }

  Future<String> startCheckoutSession({
    required String safeMeetingPointId,
    required String paymentMethod,
    required List<String> cartItemIds,
  }) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User belum login.');
    }

    final result = await _supabase.rpc(
      'start_checkout_payment_session',
      params: {
        'p_buyer_id': userId,
        'p_safe_meeting_point_id': safeMeetingPointId,
        'p_payment_method': paymentMethod,
        'p_cart_item_ids': cartItemIds,
      },
    );
    return result.toString();
  }

  Future<Map<String, dynamic>?> fetchActivePaymentSession() async {    final userId = _currentUserId;
    if (userId == null) return null;

    final response = await _supabase
        .from('payment_sessions')
        .select('*, safe_meeting_points(*)')
        .eq('buyer_id', userId)
        .eq('status', 'pending')
        .maybeSingle();

    if (response == null) return null;
    return Map<String, dynamic>.from(response as Map);
  }

  Future<void> confirmPaymentSession(String sessionId) async {
    await _supabase.rpc(
      'confirm_payment_session',
      params: {'p_session_id': sessionId},
    );
  }

  Future<void> cancelOrExpireSession(String sessionId) async {
    await _supabase.rpc(
      'cancel_or_expire_payment_session',
      params: {'p_session_id': sessionId},
    );
  }
}