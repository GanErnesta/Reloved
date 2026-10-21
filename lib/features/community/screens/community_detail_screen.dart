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
  bool _isJoined = false;

  void _openPostDetail(CommunityPostModel post) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CommunityPostDetailScreen(post: post),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final posts = CommunityPostModel.dummyPosts;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Banner & Info Komunitas
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
                  final post = posts[index];
                  return CommunityPostCard(
                    post: post,
                    onPostTap: () => _openPostDetail(post),
                    onCommentTap: () => _openPostDetail(post),
                  );
                },
                childCount: posts.length,
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