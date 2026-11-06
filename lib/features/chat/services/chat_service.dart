import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/supabase_config.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';

class ChatService {
  final SupabaseClient _client = SupabaseConfig.client;

  String get _currentUserId {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception('Pengguna belum login.');
    }

    return user.id;
  }

  String get currentUserId => _currentUserId;

  Future<ChatModel> createOrGetConversation({
    required String sellerId,
    required String productId,
  }) async {
    final buyerId = _currentUserId;

    if (buyerId == sellerId) {
      throw Exception('Tidak dapat chat dengan akun sendiri.');
    }

    final existing = await _client
        .from('conversations')
        .select()
        .eq('buyer_id', buyerId)
        .eq('seller_id', sellerId)
        .eq('product_id', productId)
        .maybeSingle();

    if (existing != null) {
      return ChatModel.fromJson(existing);
    }

    final result = await _client
        .from('conversations')
        .insert({
          'buyer_id': buyerId,
          'seller_id': sellerId,
          'product_id': productId,
        })
        .select()
        .single();

    return ChatModel.fromJson(result);
  }

  Future<List<Map<String, dynamic>>> fetchConversations() async {
    final userId = _currentUserId;

    final result = await _client
        .from('conversations')
        .select('''
          *,
          product:products!conversations_product_id_fkey(
            id,
            name,
            price,
            image_url
          )
        ''')
        .or('buyer_id.eq.$userId,seller_id.eq.$userId')
        .order('updated_at', ascending: false);

    if (result.isEmpty) return [];

    final profileIds = <String>{};

    for (final item in result) {
      profileIds.add(item['buyer_id'].toString());
      profileIds.add(item['seller_id'].toString());
    }

    final profileResult = await _client
        .from('public_profiles')
        .select('''
          id,
          nama,
          foto_profil,
          kampus,
          fakultas,
          program_studi
        ''')
        .inFilter('id', profileIds.toList());

    final Map<String, Map<String, dynamic>> profiles = {};

    for (final profile in profileResult) {
      profiles[profile['id'].toString()] =
          Map<String, dynamic>.from(profile);
    }

    final conversations = <Map<String, dynamic>>[];

    for (final item in result) {
      final conversationId = item['id'];
      final buyerId = item['buyer_id'].toString();
      final sellerId = item['seller_id'].toString();

      final lastMessage = await _client
          .from('messages')
          .select('message, sender_id, created_at, is_read')
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      final unreadMessages = await _client
          .from('messages')
          .select('id')
          .eq('conversation_id', conversationId)
          .neq('sender_id', userId)
          .eq('is_read', false);

      conversations.add({
        ...Map<String, dynamic>.from(item),
        'buyer': profiles[buyerId],
        'seller': profiles[sellerId],
        'last_message': lastMessage,
        'unread_count': unreadMessages.length,
      });
    }

    return conversations;
  }

  Future<List<MessageModel>> fetchMessages(
    String conversationId,
  ) async {
    final result = await _client
        .from('messages')
        .select()
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: true);

    return result
        .map((item) => MessageModel.fromJson(item))
        .toList();
  }

  Future<MessageModel> sendMessage({
    required String conversationId,
    required String message,
  }) async {
    final text = message.trim();

    if (text.isEmpty) {
      throw Exception('Pesan tidak boleh kosong.');
    }

    final result = await _client
        .from('messages')
        .insert({
          'conversation_id': conversationId,
          'sender_id': _currentUserId,
          'message': text,
        })
        .select()
        .single();

    return MessageModel.fromJson(result);
  }

  Stream<List<MessageModel>> watchMessages(
    String conversationId,
  ) {
    return _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId)
        .map((rows) {
          final messages = rows
              .map((item) => MessageModel.fromJson(item))
              .toList();

          messages.sort(
            (a, b) => a.createdAt.compareTo(b.createdAt),
          );

          return messages;
        });
  }

  Future<void> markMessagesAsRead(
    String conversationId,
  ) async {
    final userId = _currentUserId;

    await _client
        .from('messages')
        .update({'is_read': true})
        .eq('conversation_id', conversationId)
        .neq('sender_id', userId)
        .eq('is_read', false);
  }
}