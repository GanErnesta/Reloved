import 'package:flutter/material.dart';
import '../models/community_model.dart';
import '../models/community_post_model.dart';
import '../repositories/community_repository.dart';
import '../widgets/community_header_banner.dart';
import '../widgets/community_post_card.dart';
import '../widgets/community_search_loading.dart';
import '../widgets/community_tab_bar.dart';
import 'community_create_post_screen.dart';
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
  final CommunityRepository _repository = CommunityRepository();
  int _selectedTabIndex = 0; // 0: Populer, 1: Baru
  late CommunityModel _community;
  late bool _isJoined;
  List<CommunityPostModel> _posts = [];
  bool _isLoadingPosts = true;

  static const Color _primaryMaroon = Color(0xFF9B2335);

  @override
  void initState() {
    super.initState();
    _community = widget.community;
    _isJoined = widget.community.isJoined;
    _fetchCommunityPosts();
  }

  Future<void> _fetchCommunityPosts() async {
    setState(() => _isLoadingPosts = true);
    try {
      final posts = await _repository.getPosts(
        communityId: _community.id,
        sortByPopular: _selectedTabIndex == 0,
      );
      if (mounted) {
        setState(() {
          _posts = posts;
          _isLoadingPosts = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingPosts = false);
    }
  }

  Future<void> _handleJoinToggle() async {
    final previousJoined = _isJoined;
    final nextJoined = !previousJoined;
    final nextCount = nextJoined
        ? _community.memberCount + 1
        : (_community.memberCount > 0 ? _community.memberCount - 1 : 0);

    setState(() {
      _isJoined = nextJoined;
      _community = _community.copyWith(
        isJoined: nextJoined,
        memberCount: nextCount,
      );
    });

    try {
      await _repository.toggleJoinCommunity(_community.id, previousJoined);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isJoined = previousJoined;
          _community = widget.community;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    }
  }

  List<CommunityPostModel> get _sortedPosts {
    final sorted = List<CommunityPostModel>.from(_posts);
    if (_selectedTabIndex == 0) {
      sorted.sort((a, b) => b.likeCount.compareTo(a.likeCount));
    } else {
      sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return sorted;
  }

  Future<void> _togglePostLike(int originalIndex) async {
    final current = _posts[originalIndex];
    final nextLiked = !current.isLiked;

    setState(() {
      _posts[originalIndex] = current.copyWith(
        isLiked: nextLiked,
        likeCount: nextLiked ? current.likeCount + 1 : current.likeCount - 1,
      );
    });

    try {
      await _repository.togglePostLike(current.id, current.isLiked);
    } catch (_) {
      if (mounted) {
        setState(() => _posts[originalIndex] = current);
      }
    }
  }

  Future<void> _openPostDetail(int originalIndex) async {
    final updatedPost = await Navigator.of(context).push<CommunityPostModel>(
      MaterialPageRoute(
        builder: (_) => CommunityPostDetailScreen(post: _posts[originalIndex]),
      ),
    );

    if (updatedPost != null && mounted) {
      setState(() {
        _posts[originalIndex] = updatedPost;
      });
    }
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

  Future<void> _openCreatePost() async {
    final newPost = await Navigator.of(context).push<CommunityPostModel>(
      MaterialPageRoute(
        builder: (_) => CommunityCreatePostScreen(communityId: _community.id),
      ),
    );

    if (newPost != null && mounted) {
      setState(() {
        _posts.insert(0, newPost);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentSortedList = _sortedPosts;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: CommunityHeaderBanner(
                community: _community,
                isJoined: _isJoined,
                onJoinToggle: _handleJoinToggle,
              ),
            ),
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
            if (_isLoadingPosts)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: CommunitySearchLoading(message: 'Memuat postingan...'),
              )
            else if (currentSortedList.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Belum ada postingan di komunitas ini.\nBergabung dan jadilah yang pertama memposting!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF757575)),
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final post = currentSortedList[index];
                    final originalIndex =
                    _posts.indexWhere((p) => p.id == post.id);

                    return CommunityPostCard(
                      post: post,
                      onLikeTap: () => _togglePostLike(originalIndex),
                      onPostTap: () => _openPostDetail(originalIndex),
                      onCommentTap: () => _openPostDetail(originalIndex),
                      onProductTap: post.attachedProduct != null
                          ? () => _openProductDetail(post.attachedProduct!)
                          : null,
                    );
                  },
                  childCount: currentSortedList.length,
                ),
              ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 80),
            ),
          ],
        ),
      ),
      // Hanya tampilkan tombol + jika user sudah bergabung
      floatingActionButton: _isJoined
          ? FloatingActionButton(
        onPressed: _openCreatePost,
        backgroundColor: _primaryMaroon,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 32,
        ),
      )
          : null,
    );
  }
}