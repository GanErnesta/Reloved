import 'package:flutter/material.dart';
import '../models/community_model.dart';
import '../models/community_post_model.dart';
import '../widgets/community_header_banner.dart';
import '../widgets/community_post_card.dart';
import '../widgets/community_tab_bar.dart';
import 'community_post_detail_screen.dart';

class CommunityDetailScreen extends StatefulWidget {
  final CommunityModel community;

  const CommunityDetailScreen({
    super.key,
    required this.community,
  });

  @override
  State<CommunityDetailScreen> createState() => _CommunityDetailScreenState();
}

class _CommunityDetailScreenState extends State<CommunityDetailScreen> {
  int _selectedTabIndex = 0; // 0: Populer, 1: Baru
  late bool _isJoined;
  late List<CommunityPostModel> _posts;

  @override
  void initState() {
    super.initState();
    _isJoined = widget.community.isJoined;
    _posts = List.from(CommunityPostModel.dummyPosts);
  }

  void _togglePostLike(int index) {
    setState(() {
      final current = _posts[index];
      final newLiked = !current.isLiked;
      _posts[index] = current.copyWith(
        isLiked: newLiked,
        likeCount: newLiked ? current.likeCount + 1 : current.likeCount - 1,
      );
    });
  }

  Future<void> _openPostDetail(int index) async {
    final updatedPost = await Navigator.of(context).push<CommunityPostModel>(
      MaterialPageRoute(
        builder: (_) => CommunityPostDetailScreen(post: _posts[index]),
      ),
    );

    if (updatedPost != null && mounted) {
      setState(() {
        _posts[index] = updatedPost;
      });
    }
  }

  void _openProductDetail(AttachedProductModel product) {
    // Arahkan ke ProductDetailScreen di lib/features/home/screens/product_detail_screen.dart
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Banner & Info Komunitas (dengan deskripsi expandable)
            SliverToBoxAdapter(
              child: CommunityHeaderBanner(
                community: widget.community,
                isJoined: _isJoined,
                onJoinToggle: () {
                  setState(() {
                    _isJoined = !_isJoined;
                  });
                },
              ),
            ),
            // Tab Bar: Populer | Baru
            SliverToBoxAdapter(
              child: CommunityTabBar(
                tabs: const ['Populer', 'Baru'],
                selectedIndex: _selectedTabIndex,
                onTabSelected: (index) {
                  setState(() {
                    _selectedTabIndex = index;
                  });
                },
              ),
            ),
            // Daftar Postingan
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final post = _posts[index];
                  return CommunityPostCard(
                    post: post,
                    onLikeTap: () => _togglePostLike(index),
                    onPostTap: () => _openPostDetail(index),
                    onCommentTap: () => _openPostDetail(index),
                    onProductTap: post.attachedProduct != null
                        ? () => _openProductDetail(post.attachedProduct!)
                        : null,
                  );
                },
                childCount: _posts.length,
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 24),
            ),
          ],
        ),
      ),
    );
  }
}