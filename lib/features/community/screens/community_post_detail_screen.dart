import 'package:flutter/material.dart';
import '../models/community_comment_model.dart';
import '../models/community_post_model.dart';
import '../repositories/community_repository.dart';
import '../widgets/community_back_button.dart';
import '../widgets/community_comment_input.dart';
import '../widgets/community_comment_item.dart';
import '../widgets/community_post_card.dart';
import '../widgets/community_search_loading.dart';
import '../../home/models/product.dart';
import '../../home/services/product_service.dart';
import '../../home/screens/product_detail_screen.dart';

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
  final CommunityRepository _repository = CommunityRepository();
  final TextEditingController _commentController = TextEditingController();
  late CommunityPostModel _post;
  List<CommunityCommentModel> _comments = [];
  bool _isLoadingComments = true;

  @override
  void initState() {
    super.initState();
    _post = widget.post;
    _fetchComments();
  }

  Future<void> _fetchComments() async {
    setState(() => _isLoadingComments = true);
    try {
      final list = await _repository.getComments(_post.id);
      if (mounted) {
        setState(() {
          _comments = list;
          _isLoadingComments = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingComments = false);
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _togglePostLike() async {
    final prev = _post;
    final newLiked = !_post.isLiked;
    setState(() {
      _post = _post.copyWith(
        isLiked: newLiked,
        likeCount: newLiked ? _post.likeCount + 1 : _post.likeCount - 1,
      );
    });

    try {
      await _repository.togglePostLike(prev.id, prev.isLiked);
    } catch (_) {
      if (mounted) setState(() => _post = prev);
    }
  }

  Future<void> _toggleCommentLike(int index) async {
    final current = _comments[index];
    final newLiked = !current.isLiked;
    setState(() {
      _comments[index] = current.copyWith(
        isLiked: newLiked,
        likeCount: newLiked ? current.likeCount + 1 : current.likeCount - 1,
      );
    });

    try {
      await _repository.toggleCommentLike(current.id, current.isLiked);
    } catch (_) {
      if (mounted) setState(() => _comments[index] = current);
    }
  }

  Future<void> _sendComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    _commentController.clear();
    FocusScope.of(context).unfocus();

    try {
      final created = await _repository.addComment(
        postId: _post.id,
        content: text,
      );
      if (mounted) {
        setState(() {
          _comments.add(created);
          _post = _post.copyWith(commentCount: _post.commentCount + 1);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    }
  }

  Future<void> _openProductDetail(AttachedProductModel attachedProduct) async {
    // 1. Tampilkan loading dialog agar layar tidak terasa freeze saat fetching data
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF9B2335),
        ),
      ),
    );

    try {
      // 2. Fetch data produk secara lengkap menggunakan ProductService milik Anda
      final productService = ProductService();
      final Product productData = await productService.getProductById(attachedProduct.id);

      if (!mounted) return;
      Navigator.pop(context); // Tutup loading dialog

      // 3. Navigasi ke halaman Product Detail Screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ProductDetailScreen(product: productData),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Tutup loading dialog

      // Tampilkan error jika produk sudah dihapus atau gagal dimuat
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal memuat detail produk. Barang mungkin sudah dihapus.'),
          backgroundColor: Color(0xFF9B2335),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
              // Header
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
              // Konten Scrollable
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
                    if (_isLoadingComments)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: CommunitySearchLoading(
                            message: 'Memuat komentar...'),
                      )
                    else
                      ...List.generate(_comments.length, (index) {
                        return CommunityCommentItem(
                          comment: _comments[index],
                          onLikeToggle: () => _toggleCommentLike(index),
                        );
                      }),
                  ],
                ),
              ),
              // Input Bar Komentar
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