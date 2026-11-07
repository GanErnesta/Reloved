
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../chat/services/chat_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static final SupabaseClient _client = Supabase.instance.client;

  static Function(String conversationId)? _onNotificationTap;
  static RealtimeChannel? _messageChannel;

  static final Set<String> _processedMessages = {};

  static Future<void> initialize({
    required Function(String conversationId) onNotificationTap,
  }) async {
    _onNotificationTap = onNotificationTap;

    const androidSettings = AndroidInitializationSettings('ic_launcher');

    const initializationSettings = InitializationSettings(
      android: androidSettings,
    );

    await _plugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        final conversationId = response.payload;

        if (conversationId != null && conversationId.isNotEmpty) {
          _onNotificationTap?.call(conversationId);
        }
      },
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> startListening() async {
    if (_messageChannel != null) return;

    final currentUserId = _client.auth.currentUser?.id;

    if (currentUserId == null) return;

    _messageChannel = _client
        .channel('reloved-global-messages')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          callback: (payload) async {
            try {
              final record = payload.newRecord;

              final messageId = record['id']?.toString();
              final conversationId =
                  record['conversation_id']?.toString();
              final senderId = record['sender_id']?.toString();

              if (messageId == null ||
                  conversationId == null ||
                  senderId == null) {
                return;
              }

              if (senderId == currentUserId) return;
              if (_processedMessages.contains(messageId)) return;

              _processedMessages.add(messageId);

              final details = await ChatService()
                  .fetchConversationDetails(conversationId);

              if (details == null) return;

              final messageType =
                  record['message_type']?.toString() ?? 'text';

              final message = record['message']?.toString() ?? '';

              String preview;

              switch (messageType) {
                case 'image':
                  preview = 'Mengirim foto';
                  break;
                case 'safe_meeting_point':
                  preview = 'Mengirim titik temu';
                  break;
                default:
                  preview = message.isEmpty ? 'Pesan baru' : message;
              }

              await showMessageNotification(
                id: messageId.hashCode & 0x7fffffff,
                senderName:
                    details['sellerName']?.toString() ?? 'Pengguna Reloved',
                message: preview,
                conversationId: conversationId,
              );
            } catch (error) {
              debugPrint('Notification error: $error');
            }
          },
        )
        .subscribe();
  }

  static Future<void> stopListening() async {
    final channel = _messageChannel;

    if (channel == null) return;

    await _client.removeChannel(channel);
    _messageChannel = null;
    _processedMessages.clear();
  }

  static Future<void> showMessageNotification({
    required int id,
    required String senderName,
    required String message,
    required String conversationId,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'reloved_chat_channel',
      'Chat Reloved',
      channelDescription: 'Notifikasi pesan baru Reloved',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _plugin.show(
      id: id,
      title: senderName,
      body: message,
      notificationDetails: notificationDetails,
      payload: conversationId,
    );
  }
}
