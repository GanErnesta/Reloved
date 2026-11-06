import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/message_model.dart';
import '../services/chat_service.dart';

import '../widgets/chat_bubble.dart';
import '../widgets/chat_input.dart';
import '../widgets/chat_room_header.dart';
import '../widgets/product_chat_card.dart';
import '../widgets/safe_meeting_point.dart';

class ChatRoomScreen extends StatefulWidget {
  final String conversationId;
  final String sellerName;
  final String productName;
  final String productPrice;
  final String productImage;

  const ChatRoomScreen({
    super.key,
    required this.conversationId,
    required this.sellerName,
    required this.productName,
    required this.productPrice,
    required this.productImage,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final ChatService _chatService = ChatService();

  final TextEditingController _messageController = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  late Stream<List<MessageModel>> _messagesStream;
  late final String _currentUserId;

  bool _isSending = false;
  String? _lastMessageId;

  @override
  void initState() {
    super.initState();

    _currentUserId = Supabase.instance.client.auth.currentUser?.id ?? '';

    _messagesStream = _chatService.watchMessages(widget.conversationId);

    _markMessagesAsRead();
  }

  Future<void> _markMessagesAsRead() async {
    try {
      await _chatService.markMessagesAsRead(widget.conversationId);
    } catch (e) {
      debugPrint('ERROR MARK MESSAGES READ: $e');
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();

    if (message.isEmpty || _isSending) return;

    if (_currentUserId.isEmpty) {
      _showMessage('Silakan login terlebih dahulu');
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      await _chatService.sendMessage(
        conversationId: widget.conversationId,
        message: message,
      );

      if (!mounted) return;

      _messageController.clear();

      _scrollToBottom();
    } catch (e) {
      debugPrint('ERROR SEND MESSAGE: $e');

      if (mounted) {
        _showMessage('Pesan gagal dikirim. Coba lagi.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;

    final minute = dateTime.minute.toString().padLeft(2, '0');

    final period = dateTime.hour >= 12 ? 'PM' : 'AM';

    return '$hour.$minute $period';
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6E9EC),
      body: SafeArea(
        child: Column(
          children: [
            ChatRoomHeader(
              name: widget.sellerName,
              onBack: () {
                Navigator.pop(context);
              },
              onMore: () {},
            ),

            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: StreamBuilder<List<MessageModel>>(
                      stream: _messagesStream,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.wifi_off_rounded,
                                  size: 35,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 8),
                                const Text('Gagal memuat percakapan'),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _messagesStream = _chatService
                                          .watchMessages(widget.conversationId);
                                    });
                                  },
                                  child: const Text('Coba lagi'),
                                ),
                              ],
                            ),
                          );
                        }

                        if (snapshot.connectionState ==
                                ConnectionState.waiting &&
                            !snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final messages = snapshot.data ?? [];

                        if (messages.isNotEmpty) {
                          final latestId = messages.last.id;

                          if (_lastMessageId != latestId) {
                            _lastMessageId = latestId;
                            _scrollToBottom();
                          }
                        }

                        return ListView(
                          controller: _scrollController,
                          padding: EdgeInsets.zero,
                          children: [
                            ProductChatCard(
                              imageUrl: widget.productImage,
                              productName: widget.productName,
                              price: widget.productPrice,
                            ),

                            const SizedBox(height: 4),

                            if (messages.isEmpty)
                              Padding(
                                padding: const EdgeInsets.all(24),
                                child: Center(
                                  child: Text(
                                    'Mulai percakapan dengan ${widget.sellerName}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),

                            ...messages.map((item) {
                              final isMe = item.senderId == _currentUserId;

                              return ChatBubble(
                                message: item.message,
                                time: _formatTime(item.createdAt),
                                isMe: isMe,
                              );
                            }),
                          ],
                        );
                      },
                    ),
                  ),

                  const SafeMeetingPoint(),
                ],
              ),
            ),

            ChatInput(
              controller: _messageController,
              onSend: _sendMessage,
              isSending: _isSending,
              onAdd: () {
                _showMessage('Fitur lampiran akan ditambahkan');
              },
            ),
          ],
        ),
      ),
    );
  }
}
