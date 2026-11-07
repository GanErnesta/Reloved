import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/supabase_config.dart';

class OrderRepository {
  SupabaseClient get _supabase => SupabaseConfig.client;

  String? get _currentUserId => _supabase.auth.currentUser?.id;

  Future< List< Map< String, dynamic > > > fetchBuyerOrders(
      String orderType,
      ) async {
    final userId = _currentUserId;
    if (userId == null) return [];

    final response = await _supabase
        .from('orders')
        .select('''
          *,
          seller:profiles!seller_id (id, nama, foto_profil, email),
          buyer:profiles!buyer_id (id, nama, email),
          safe_meeting_points (*),
          order_items (*)
        ''')
        .eq('buyer_id', userId)
        .eq('order_type', orderType)
        .neq('buyer_status', 'dibatalkan')
        .order('ordered_at', ascending: false);

    final list = response as List< dynamic >;
    return list
        .map((row) => Map< String, dynamic >.from(row as Map))
        .toList();
  }

  Future< void > updateOrderSafeMeetingPoint({
    required String orderId,
    required String safeMeetingPointId,
  }) async {
    await _supabase
        .from('orders')
        .update({'safe_meeting_point_id': safeMeetingPointId})
        .eq('id', orderId)
        .eq('buyer_status', 'menunggu');
  }

  Future< void > cancelOrderByBuyer(String orderId) async {
    await _supabase
        .from('orders')
        .update({
      'buyer_status': 'dibatalkan',
      'seller_status': 'ditolak',
    })
        .eq('id', orderId)
        .eq('buyer_status', 'menunggu');
  }

  Future< List< Map< String, dynamic > > > fetchSellerOrders(
      String orderType,
      ) async {
    final userId = _currentUserId;
    if (userId == null) return [];

    final response = await _supabase
        .from('orders')
        .select('''
          *,
          buyer:profiles!buyer_id (
            id, nama, foto_profil, kampus, trust_score
          ),
          safe_meeting_points (*),
          order_items (*)
        ''')
        .eq('seller_id', userId)
        .eq('order_type', orderType)
        .neq('seller_status', 'ditolak')
        .order('ordered_at', ascending: false);

    final list = response as List< dynamic >;
    return list
        .map((row) => Map< String, dynamic >.from(row as Map))
        .toList();
  }

  Future< void > acceptOrderBySeller({
    required String orderId,
    required String orderType,
  }) async {
    final bool isSewa = orderType == 'sewa' || orderType == 'rent';
    await _supabase.from('orders').update({
      'seller_status': isSewa ? 'aktif' : 'siap_cod',
      'buyer_status': 'dikirim',
    }).eq('id', orderId);
  }

  Future< void > rejectOrderBySeller(String orderId) async {
    await _supabase.from('orders').update({
      'seller_status': 'ditolak',
      'buyer_status': 'dibatalkan',
    }).eq('id', orderId);
  }

  Future< void > completeOrderBySeller(String orderId) async {
    final nowIso = DateTime.now().toIso8601String();
    await _supabase.from('orders').update({
      'seller_status': 'selesai',
      'buyer_status': 'selesai',
      'received_at': nowIso,
      'completed_at': nowIso,
    }).eq('id', orderId);
  }
}