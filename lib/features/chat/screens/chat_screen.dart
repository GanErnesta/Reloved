
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../services/chat_service.dart';
import '../widgets/chat_item.dart';
import '../widgets/chat_search_bar.dart';
import 'chat_room_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _chats = [];

  String _searchQuery = '';
  String? _loadError;

  RealtimeChannel? _messageChannel;

  final Set<String> _selectedConversationIds = {};

  bool _isInitialLoading = true;
  bool _isProcessingSelection = false;

  bool get _isSelectionMode => _selectedConversationIds.isNotEmpty;

  @override
  void initState() {
    super.initState();

    _loadChats(showLoading: true);
    _subscribeToMessages();
  }

  Future<void> _loadChats({bool showLoading = false}) async {
    if (showLoading && mounted) {
      setState(() {
        _isInitialLoading = true;
        _loadError = null;
      });
    }

    try {
      final result = await _chatService.fetchConversations();

      if (!mounted) return;

      setState(() {
        _chats = result;
        _loadError = null;
        _isInitialLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loadError = e.toString();
        _isInitialLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();

    final channel = _messageChannel;

    if (channel != null) {
      unawaited(Supabase.instance.client.removeChannel(channel));
    }

    super.dispose();
  }

  Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return null;
  }

  String _formatDate(dynamic value) {
    if (value == null) return '';

    final date = DateTime.parse(value.toString()).toLocal();
    final now = DateTime.now();

    if (DateUtils.isSameDay(date, now)) {
      return DateFormat('HH:mm').format(date);
    }

    return DateFormat('dd/MM').format(date);
  }

  List<Map<String, dynamic>> _filterChats(
    List<Map<String, dynamic>> chats,
  ) {
    final query = _searchQuery.trim().toLowerCase();

    if (query.isEmpty) return chats;

    return chats.where((chat) {
      final buyer = _asMap(chat['buyer']);
      final seller = _asMap(chat['seller']);
      final product = _asMap(chat['product']);

      final buyerName = buyer?['nama']?.toString() ?? '';
      final sellerName = seller?['nama']?.toString() ?? '';
      final productName = product?['name']?.toString() ?? '';

      return buyerName.toLowerCase().contains(query) ||
          sellerName.toLowerCase().contains(query) ||
          productName.toLowerCase().contains(query);
    }).toList();
  }

  void _subscribeToMessages() {
    final currentUserId = _chatService.currentUserId;

    if (currentUserId == null) return;

    _messageChannel = Supabase.instance.client
        .channel('chat-list-$currentUserId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          callback: (payload) {
            if (!mounted) return;
            _loadChats();
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'messages',
          callback: (payload) {
            if (!mounted) return;
            _loadChats();
          },
        )
        .subscribe();
  }

  void _startSelection(String conversationId) {
    setState(() {
      _selectedConversationIds.add(conversationId);
    });
  }

  void _toggleSelection(String conversationId) {
    setState(() {
      if (_selectedConversationIds.contains(conversationId)) {
        _selectedConversationIds.remove(conversationId);
      } else {
        _selectedConversationIds.add(conversationId);
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedConversationIds.clear();
    });
  }

  Future<void> _markSelectedAsRead() async {
    if (_selectedConversationIds.isEmpty || _isProcessingSelection) {
      return;
    }

    setState(() {
      _isProcessingSelection = true;
    });

    try {
      await _chatService.markConversationsAsRead(
        _selectedConversationIds.toList(),
      );

      if (!mounted) return;

      setState(() {
        _selectedConversationIds.clear();
        _isProcessingSelection = false;
      });

      await _loadChats();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Percakapan berhasil ditandai sudah dibaca.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isProcessingSelection = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menandai percakapan: $e'),
        ),
      );
    }
  }

  Future<void> _hideSelectedChats() async {
    if (_selectedConversationIds.isEmpty || _isProcessingSelection) {
      return;
    }

    setState(() {
      _isProcessingSelection = true;
    });

    try {
      await _chatService.hideConversations(
        _selectedConversationIds.toList(),
      );

      if (!mounted) return;

      setState(() {
        _selectedConversationIds.clear();
        _isProcessingSelection = false;
      });

      await _loadChats();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Percakapan berhasil dihapus dari daftar chat.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isProcessingSelection = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus percakapan: $e'),
        ),
      );
    }
  }

  Widget _buildSelectionHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 8,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _isProcessingSelection ? null : _clearSelection,
            icon: const Icon(Icons.close),
            tooltip: 'Batal memilih',
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${_selectedConversationIds.length} dipilih',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            onPressed: _isProcessingSelection ? null : _markSelectedAsRead,
            icon: const Icon(Icons.mark_email_read_outlined),
            tooltip: 'Tandai sudah dibaca',
          ),
          IconButton(
            onPressed: _isProcessingSelection ? null : _hideSelectedChats,
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Hapus',
          ),
        ],
      ),
    );
  }

  Future<void> _openChat(
    Map<String, dynamic> chat,
    String name,
    String productName,
    Map<String, dynamic>? product,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatRoomScreen(
          conversationId: chat['id'].toString(),
          sellerName: name,
          productName: productName,
          productPrice: 'Rp${product?['price'] ?? 0}',
          productImage: product?['image_url']?.toString() ?? '',
        ),
      ),
    );

    if (mounted) {
      _loadChats();
    }
  }

  @override
  Widget build(BuildContext context) {
    final chats = _filterChats(_chats);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            if (_isSelectionMode)
              _buildSelectionHeader()
            else
              ChatSearchBar(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            Expanded(
              child: _isInitialLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : _loadError != null
                      ? _buildError()
                      : chats.isEmpty
                          ? _buildEmpty()
                          : ListView.builder(
                              padding: const EdgeInsets.only(
                                top: AppSpacing.sm,
                                bottom: 16,
                              ),
                              itemCount: chats.length,
                              itemBuilder: (context, index) {
                                final chat = chats[index];

                                final buyer = _asMap(chat['buyer']);
                                final seller = _asMap(chat['seller']);
                                final product = _asMap(chat['product']);
                                final lastMessage =
                                    _asMap(chat['last_message']);

                                final conversationId =
                                    chat['id'].toString();

                                final isBuyer =
                                    chat['buyer_id']?.toString() ==
                                    _chatService.currentUserId;

                                final otherUser = isBuyer ? seller : buyer;

                                final name =
                                    otherUser?['nama']?.toString() ??
                                    'Pengguna Reloved';

                                final avatarUrl =
                                    otherUser?['foto_profil']?.toString();

                                final productName =
                                    product?['name']?.toString() ?? 'Produk';

                                final message =
                                    lastMessage?['message']?.toString() ??
                                    'Mulai percakapan tentang $productName';

                                final date = _formatDate(
                                  lastMessage?['created_at'] ??
                                      chat['updated_at'],
                                );

                                final unreadCount =
                                    (chat['unread_count'] as num?)
                                        ?.toInt() ??
                                    0;

                                final isSelected =
                                    _selectedConversationIds.contains(
                                  conversationId,
                                );

                                final isLastMessageMine =
                                    lastMessage?['sender_id']?.toString() ==
                                    _chatService.currentUserId;

                                final isLastMessageRead =
                                    lastMessage?['is_read'] == true;

                                return ChatItem(
                                  name: name,
                                  message: message,
                                  date: date,
                                  avatarUrl: avatarUrl,
                                  unreadCount: unreadCount,
                                  selected: isSelected,
                                  selectionMode: _isSelectionMode,
                                  isLastMessageMine: isLastMessageMine,
                                  isLastMessageRead: isLastMessageRead,
                                  onLongPress: () {
                                    if (!_isSelectionMode) {
                                      _startSelection(conversationId);
                                    }
                                  },
                                  onTap: () {
                                    if (_isProcessingSelection) return;

                                    if (_isSelectionMode) {
                                      _toggleSelection(conversationId);
                                    } else {
                                      _openChat(
                                        chat,
                                        name,
                                        productName,
                                        product,
                                      );
                                    }
                                  },
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    final isSearching = _searchQuery.trim().isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 52,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              isSearching
                  ? 'Percakapan tidak ditemukan'
                  : 'Belum ada percakapan',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isSearching
                  ? 'Coba gunakan kata kunci lain.'
                  : 'Mulai chat dengan penjual untuk berdiskusi tentang produk.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 44,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 12),
            const Text(
              'Gagal memuat percakapan',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                _loadChats(showLoading: true);
              },
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
