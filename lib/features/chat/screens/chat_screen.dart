
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  final TextEditingController _searchController =
      TextEditingController();

  late Future<List<Map<String, dynamic>>> _chatsFuture;

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  void _loadChats() {
    _chatsFuture = _chatService.fetchConversations();
  }

  Future<void> _refreshChats() async {
    setState(_loadChats);
    await _chatsFuture;
  }

  @override
  void dispose() {
    _searchController.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            ChatSearchBar(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _chatsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return _buildError();
                  }

                  final chats = _filterChats(
                    snapshot.data ?? [],
                  );

                  if (chats.isEmpty) {
                    return _buildEmpty();
                  }

                  return RefreshIndicator(
                    onRefresh: _refreshChats,
                    child: ListView.builder(
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

                        final isBuyer =
                            chat['buyer_id'] ==
                            _chatService.currentUserId;

                        final otherUser =
                            isBuyer ? seller : buyer;

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
                            (chat['unread_count'] as num?)?.toInt() ??
                            0;

                        return ChatItem(
                          name: name,
                          message: message,
                          date: date,
                          avatarUrl: avatarUrl,
                          unreadCount: unreadCount,
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatRoomScreen(
                                  conversationId: chat['id'].toString(),
                                  sellerName: name,
                                  productName: productName,
                                  productPrice:
                                      'Rp${product?['price'] ?? 0}',
                                  productImage:
                                      product?['image_url']?.toString() ??
                                      '',
                                ),
                              ),
                            );

                            if (mounted) {
                              setState(_loadChats);
                            }
                          },
                        );
                      },
                    ),
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
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                setState(_loadChats);
              },
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
