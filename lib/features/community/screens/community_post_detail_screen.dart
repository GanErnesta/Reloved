import 'package:flutter/material.dart';
import '../models/community_comment_model.dart';
import '../models/community_post_model.dart';
import '../widgets/community_back_button.dart';
import '../widgets/community_comment_input.dart';
import '../widgets/community_comment_item.dart';
import '../widgets/community_post_card.dart';

class CommunityPostDetailScreen extends StatefulWidget {
  final CommunityPostModel post;

  const CommunityPostDetailScreen({
    super.key,
    required this.post,
  });

  @override
  State<CommunityPostDetailScreen> createState() =>
      _CommunityPostDetailScreenState();
}

class _CommunityPostDetailScreenState extends State<CommunityPostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  late CommunityPostModel _post;
  late List<CommunityCommentModel> _comments;

  @override
  void initState() {
    super.initState();
    _post = widget.post;
    _comments = List.from(CommunityCommentModel.initialComments);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _togglePostLike() {
    setState(() {
      final newLiked = !_post.isLiked;
      _post = _post.copyWith(
        isLiked: newLiked,
        likeCount: newLiked ? _post.likeCount + 1 : _post.likeCount - 1,
      );
    });
  }

  void _toggleCommentLike(int index) {
    setState(() {
      final current = _comments[index];
      final newLiked = !current.isLiked;
      _comments[index] = current.copyWith(
        isLiked: newLiked,
        likeCount: newLiked ? current.likeCount + 1 : current.likeCount - 1,
      );
    });
  }

  void _sendComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _comments.add(
        CommunityCommentModel(
          id: 'c_${DateTime.now().millisecondsSinceEpoch}',
          authorName: 'Falisha Keyrani',
          authorAvatar: 'assets/images/avatar_falisha.png',
          content: text,
          likeCount: 10,
          isLiked: false,
        ),
      );
      _post = _post.copyWith(commentCount: _post.commentCount + 1);
      _commentController.clear();
    });
    FocusScope.of(context).unfocus();
  }

  void _openProductDetail(AttachedProductModel product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text('Detail Produk')),
          body: Center(
            child: Text(
              'Halaman Detail Produk:\n${product.title} (${product.price})',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          Navigator.of(context).pop(_post);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Header: Tombol Back & Judul "Detail Komen"
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Row(
                  children: [
                    CommunityBackButton(
                      onTap: () => Navigator.of(context).pop(_post),
                    ),
                    const SizedBox(width: 20),
                    const Text(
                      'Detail Komen',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              // Konten Scrollable: Postingan Utama + Daftar Komentar
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 16),
                  children: [
                    CommunityPostCard(
                      post: _post,
                      onLikeTap: _togglePostLike,
                      onProductTap: _post.attachedProduct != null
                          ? () => _openProductDetail(_post.attachedProduct!)
                          : null,
                    ),
                    const SizedBox(height: 4),
                    ...List.generate(_comments.length, (index) {
                      return CommunityCommentItem(
                        comment: _comments[index],
                        onLikeToggle: () => _toggleCommentLike(index),
                      );
                    }),
                  ],
                ),
              ),
              // Input Bar Komentar di Bagian Bawah
              CommunityCommentInput(
                controller: _commentController,
                onSend: _sendComment,
              ),
            ],
          ),
        ),
      ),
    );
  }
}