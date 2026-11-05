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

  // ==========================================
  // CREATE OR GET CONVERSATION
  // ==========================================

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

  // ==========================================
  // FETCH CONVERSATIONS
  // ==========================================

  Future<List<Map<String, dynamic>>> fetchConversations() async {
    final userId = _currentUserId;

    final result = await _client
        .from('conversations')
        .select('''
          *,
          buyer:profiles!conversations_buyer_id_fkey(
            id, nama, foto_profil
          ),
          seller:profiles!conversations_seller_id_fkey(
            id, nama, foto_profil
          ),
          product:products!conversations_product_id_fkey(
            id, name, price, image_url
          )
        ''')
        .or('buyer_id.eq.$userId,seller_id.eq.$userId')
        .order('updated_at', ascending: false);

    final conversations = <Map<String, dynamic>>[];

    for (final item in result) {
      final conversationId = item['id'];

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
        ...item,
        'last_message': lastMessage,
        'unread_count': unreadMessages.length,
      });
    }

    return conversations;
  }

  // ==========================================
  // FETCH MESSAGES
  // ==========================================

  Future<List<MessageModel>> fetchMessages(String conversationId) async {
    final result = await _client
        .from('messages')
        .select()
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: true);

    return result.map((item) => MessageModel.fromJson(item)).toList();
  }

  // ==========================================
  // SEND MESSAGE
  // ==========================================

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

  // ==========================================
  // REALTIME MESSAGES
  // ==========================================

  Stream<List<MessageModel>> watchMessages(String conversationId) {
    return _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId)
        .map((rows) {
          final messages = rows
              .map((item) => MessageModel.fromJson(item))
              .toList();

          messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

          return messages;
        });
  }

  // ==========================================
  // MARK MESSAGES AS READ
  // ==========================================

  Future<void> markMessagesAsRead(String conversationId) async {
    final userId = _currentUserId;

    await _client
        .from('messages')
        .update({'is_read': true})
        .eq('conversation_id', conversationId)
        .neq('sender_id', userId)
        .eq('is_read', false);
  }
}
