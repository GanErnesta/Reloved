import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../widgets/chat_item.dart';
import '../widgets/chat_search_bar.dart';
import 'chat_room_screen.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  static const List<_ChatData> chats = [
    _ChatData(
      name: 'FilkomShop',
      message: 'Apakah kemeja putihnya boleh disewa, kak?',
      date: '09/07',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            const ChatSearchBar(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                itemCount: chats.length,
                itemBuilder: (context, index) {
                  final chat = chats[index];

                  return ChatItem(
                    name: chat.name,
                    message: chat.message,
                    date: chat.date,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatRoomScreen(
                            sellerName: chat.name,
                            productName: 'Kemeja Putih',
                            productPrice: 'Rp49.900',
                            productImage:
                                'https://images.unsplash.com/photo-1603252110481-7ba873bf42ab?w=600',
                          ),
                        ),
                      );
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
}

class _ChatData {
  final String name;
  final String message;
  final String date;

  const _ChatData({
    required this.name,
    required this.message,
    required this.date,
  });
}
