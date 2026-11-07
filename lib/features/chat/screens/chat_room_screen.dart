
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/message_model.dart';
import '../models/safe_meeting_point_model.dart';
import '../services/chat_service.dart';

import '../widgets/chat_bubble.dart';
import '../widgets/chat_input.dart';
import '../widgets/chat_room_header.dart';
import '../widgets/product_chat_card.dart';
import '../widgets/safe_meeting_point.dart';
import '../widgets/safe_meeting_point_picker.dart';
import '../widgets/safe_meeting_point_message.dart';

import '../../profile/screens/seller_profile_screen.dart';

class ChatRoomScreen extends StatefulWidget {
  final String conversationId;
  final String sellerName;
  final String? sellerAvatar; // 1. Tambahkan parameter avatar penjual
  final String productName;
  final String productPrice;
  final String productImage;

  const ChatRoomScreen({
    super.key,
    required this.conversationId,
    required this.sellerName,
    this.sellerAvatar, // 2. Daftarkan di constructor
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
  final ImagePicker _imagePicker = ImagePicker();

  late Stream<List<MessageModel>> _messagesStream;
  late final String _currentUserId;

  bool _isSending = false;
  XFile? _selectedImage;

  String? _otherUserId;
  String? _lastMessageId;
  String? _otherUserPhotoUrl;

  @override
  void initState() {
    super.initState();

    _currentUserId = Supabase.instance.client.auth.currentUser?.id ?? '';

    _messagesStream = _chatService.watchMessages(widget.conversationId);

    _markMessagesAsRead();
    _loadOtherUserProfile();
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
    final image = _selectedImage;

    if (message.isEmpty && image == null) return;
    if (_isSending) return;

    if (_currentUserId.isEmpty) {
      _showMessage('Silakan login terlebih dahulu.');
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      if (image != null) {
        await _chatService.sendImageMessage(
          conversationId: widget.conversationId,
          image: image,
          message: message,
        );
      } else {
        await _chatService.sendMessage(
          conversationId: widget.conversationId,
          message: message,
        );
      }

      if (!mounted) return;

      setState(() {
        _selectedImage = null;
      });

      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      debugPrint('ERROR SEND MESSAGE: $e');

      if (mounted) {
        _showMessage(
          image != null
              ? 'Foto dan pesan gagal dikirim. Coba lagi.'
              : 'Pesan gagal dikirim. Coba lagi.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  Future<void> _takePhoto() async {
    if (_isSending) return;

    if (_currentUserId.isEmpty) {
      _showMessage('Silakan login terlebih dahulu.');
      return;
    }

    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1600,
      );

      if (photo == null || !mounted) return;

      setState(() {
        _selectedImage = photo;
      });
    } catch (e) {
      debugPrint('ERROR TAKE PHOTO: $e');

      if (mounted) {
        _showMessage('Gagal mengambil foto.');
      }
    }
  }

  void _removeSelectedImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  Future<void> _showSafeMeetingPointPicker() async {
    try {
      final locations = await _chatService.fetchSafeMeetingPoints();

      if (!mounted) return;

      if (locations.isEmpty) {
        _showMessage('Belum ada titik temu yang tersedia.');
        return;
      }

      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (sheetContext) {
          return SafeMeetingPointPicker(
            locations: locations,
            onConfirm: (selectedLocations) {
              Navigator.pop(sheetContext);
              _sendSafeMeetingPoints(selectedLocations);
            },
          );
        },
      );
    } catch (e) {
      debugPrint('ERROR LOAD SAFE MEETING POINTS: $e');

      if (mounted) {
        _showMessage('Gagal memuat daftar titik temu.');
      }
    }
  }

  Future<void> _sendSafeMeetingPoints(
    List<SafeMeetingPointModel> locations,
  ) async {
    try {
      await _chatService.sendSafeMeetingPoint(
        conversationId: widget.conversationId,
        locations: locations,
      );

      if (!mounted) return;

      _scrollToBottom();
    } catch (e) {
      debugPrint('ERROR SEND SAFE MEETING POINT: $e');

      if (mounted) {
        _showMessage('Gagal mengirim titik temu.');
      }
    }
  }

  Future<void> _loadOtherUserProfile() async {
    try {
      final profile = await _chatService.fetchOtherParticipantProfile(
        widget.conversationId,
      );

      if (!mounted) return;

      setState(() {
        _otherUserId = profile?['id']?.toString();
        _otherUserPhotoUrl = profile?['foto_profil']?.toString();
      });
    } catch (e) {
      debugPrint('ERROR LOAD CHAT PROFILE: $e');
    }
  }

  void _showMoreOptions(String value) {
    if (value == 'profile') {
      if (_otherUserId == null || _otherUserId!.isEmpty) {
        _showMessage('Profil penjual belum tersedia.');
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SellerProfileScreen(
            sellerId: _otherUserId!,
          ),
        ),
      );
    }
  }

  Widget _buildMessage(MessageModel item) {
    final isMe = item.senderId == _currentUserId;
    final time = _formatTime(item.createdAt);

    if (item.messageType == 'safe_meeting_point') {
      final rawLocations = item.metadata['locations'];

      final locations = rawLocations is List
          ? rawLocations
              .whereType<Map>()
              .map((location) => Map<String, dynamic>.from(location))
              .toList()
          : <Map<String, dynamic>>[];

      if (locations.isEmpty) {
        return ChatBubble(
          message: item.message,
          time: time,
          isMe: isMe,
        );
      }

      return SafeMeetingPointMessage(
        locations: locations,
        time: time,
        isMe: isMe,
      );
    }

    if (item.messageType == 'image') {
      return ChatBubble(
        message: item.message,
        time: time,
        isMe: isMe,
        imageUrl: item.metadata['image_url']?.toString(),
      );
    }

    return ChatBubble(
      message: item.message,
      time: time,
      isMe: isMe,
    );
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
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            ChatRoomHeader(
              name: widget.sellerName,
              avatarUrl: _otherUserPhotoUrl,
              onBack: () {
                Navigator.pop(context);
              },
              onMore: _showMoreOptions,
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
                                          .watchMessages(
                                        widget.conversationId,
                                      );
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
                            ...messages.map(_buildMessage),
                          ],
                        );
                      },
                    ),
                  ),
                  SafeMeetingPoint(
                    onTap: _showSafeMeetingPointPicker,
                  ),
                ],
              ),
            ),
            ChatInput(
              controller: _messageController,
              onSend: _sendMessage,
              isSending: _isSending,
              onAdd: _takePhoto,
              selectedImage: _selectedImage,
              onRemoveImage: _removeSelectedImage,
            ),
          ],
        ),
      ),
    );
  }
}