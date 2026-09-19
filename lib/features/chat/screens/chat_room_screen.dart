import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input.dart';
import '../widgets/chat_room_header.dart';
import '../widgets/product_chat_card.dart';
import '../widgets/safe_meeting_point.dart';

class ChatRoomScreen extends StatefulWidget {
  final String sellerName;
  final String productName;
  final String productPrice;
  final String productImage;

  const ChatRoomScreen({
    super.key,
    required this.sellerName,
    required this.productName,
    required this.productPrice,
    required this.productImage,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _messageController =
      TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
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
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        ProductChatCard(
                          imageUrl: widget.productImage,
                          productName: widget.productName,
                          price: widget.productPrice,
                        ),
                        const SizedBox(height: 4),
                        const ChatBubble(
                          message:
                              'Terimakasih sudah menghubungi!',
                          time: '10.20 PM',
                          isMe: false,
                        ),
                        const ChatBubble(
                          message:
                              'Apakah kemeja putihnya boleh disewa, kak?',
                          time: '10.20 PM',
                          isMe: true,
                        ),
                        const ChatBubble(
                          message:
                              'Boleh banget, kak! silahkan dicari dulu meeting point nya.',
                          time: '10.20 PM',
                          isMe: false,
                        ),
                        const ChatBubble(
                          message: 'Baik, kak! sebentar yaa',
                          time: '10.20 PM',
                          isMe: true,
                        ),
                      ],
                    ),
                  ),
                  const SafeMeetingPoint(),
                ],
              ),
            ),
            ChatInput(
              controller: _messageController,
              onAdd: () {},
              onEmoji: () {},
            ),
          ],
        ),
      ),
    );
  }
}