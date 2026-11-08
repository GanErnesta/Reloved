import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/env.dart';
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

  Future<Map<String, dynamic>> startCheckoutSession({
    required String safeMeetingPointId,
    required String paymentMethod,
    required List<String> cartItemIds,
  }) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User belum login.');
    }

    // 1. Jalankan RPC untuk mengunci stok produk dan membuat baris payment_sessions
    final sessionIdResult = await _supabase.rpc(
      'start_checkout_payment_session',
      params: {
        'p_buyer_id': userId,
        'p_safe_meeting_point_id': safeMeetingPointId,
        'p_payment_method': paymentMethod,
        'p_cart_item_ids': cartItemIds,
      },
    );
    final String sessionId = sessionIdResult.toString();

    // 2. Ambil midtrans_order_id dan grand_total dari sesi yang baru dibuat
    final sessionData = await _supabase
        .from('payment_sessions')
        .select('midtrans_order_id, grand_total')
        .eq('id', sessionId)
        .single();

    final String midtransOrderId = sessionData['midtrans_order_id'].toString();
    final int grossAmount = (sessionData['grand_total'] as num).toInt();

    // 3. Siapkan Basic Auth Header untuk Midtrans
    final serverKey = Env.midtransServerKey;
    final authHeader = base64Encode(utf8.encode('$serverKey:'));

    // 4. Panggil API Midtrans Snap Sandbox
    final response = await http.post(
      Uri.parse('https://app.sandbox.midtrans.com/snap/v1/transactions'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Basic $authHeader',
      },
      body: jsonEncode({
        'transaction_details': {
          'order_id': midtransOrderId,
          'gross_amount': grossAmount,
        },
      }),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Gagal menghubungi Midtrans: ${response.body}');
    }

    final Map<String, dynamic> responseData =
    jsonDecode(response.body) as Map<String, dynamic>;
    final String snapToken = (responseData['token'] ?? '').toString();
    final String redirectUrl = (responseData['redirect_url'] ?? '').toString();

    // 5. Simpan token dan redirect_url ke tabel payment_sessions
    await _supabase.from('payment_sessions').update({
      'midtrans_snap_token': snapToken,
      'qris_string': redirectUrl,
    }).eq('id', sessionId);

    return {
      'sessionId': sessionId,
      'midtransOrderId': midtransOrderId,
      'token': snapToken,
      'redirectUrl': redirectUrl,
    };
  }

  Future<Map<String, dynamic>?> fetchActivePaymentSession() async {
    final userId = _currentUserId;
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
    // 1. Ambil midtrans_order_id dari database
    final sessionData = await _supabase
        .from('payment_sessions')
        .select('midtrans_order_id')
        .eq('id', sessionId)
        .single();

    final String? midtransOrderId =
    sessionData['midtrans_order_id']?.toString();

    if (midtransOrderId != null && midtransOrderId.isNotEmpty) {
      final serverKey = Env.midtransServerKey;
      final authHeader = base64Encode(utf8.encode('$serverKey:'));

      // 2. Cek status transaksi langsung ke server Midtrans Sandbox
      final statusResponse = await http.get(
        Uri.parse(
          'https://api.sandbox.midtrans.com/v2/$midtransOrderId/status',
        ),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Basic $authHeader',
        },
      );

      if (statusResponse.statusCode == 200) {
        final Map<String, dynamic> statusData =
        jsonDecode(statusResponse.body) as Map<String, dynamic>;
        final String trxStatus =
        (statusData['transaction_status'] ?? '').toString().toLowerCase();
        final String statusCode =
        (statusData['status_code'] ?? '').toString();

        if (statusCode == '404') {
          throw Exception(
            'Metode pembayaran belum dipilih di halaman Midtrans. Silakan buka halaman pembayaran terlebih dahulu.',
          );
        }

        if (trxStatus != 'settlement' && trxStatus != 'capture') {
          throw Exception(
            'Pembayaran belum lunas (Status Midtrans: $trxStatus). Silakan selesaikan pembayaran di simulator terlebih dahulu.',
          );
        }
      } else {
        throw Exception(
          'Gagal memeriksa status Midtrans (HTTP ${statusResponse.statusCode}).',
        );
      }
    }

    // 3. Jika sudah settlement/capture, jalankan RPC untuk membuat pesanan
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