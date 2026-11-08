import 'package:flutter/material.dart';
import '../../community/models/community_post_model.dart';
import '../../community/repositories/community_repository.dart';
import '../../community/screens/community_post_detail_screen.dart';
import '../../community/widgets/community_post_card.dart';

class ProfileUserPostsList extends StatefulWidget {
  final String? userId;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const ProfileUserPostsList({
    super.key,
    this.userId,
    this.shrinkWrap = false,
    this.physics = const AlwaysScrollableScrollPhysics(),
  });

  @override
  State<ProfileUserPostsList> createState() => _ProfileUserPostsListState();
}

class _ProfileUserPostsListState extends State<ProfileUserPostsList> {
  final CommunityRepository _repository = CommunityRepository();
  List<CommunityPostModel> _userPosts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserPosts();
  }

  Future<void> _loadUserPosts() async {
    setState(() => _isLoading = true);
    try {
      final posts = await _repository.getUserPosts(userId: widget.userId);
      if (mounted) {
        setState(() {
          _userPosts = posts;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleLike(int index) async {
    final current = _userPosts[index];
    final nextLiked = !current.isLiked;
    setState(() {
      _userPosts[index] = current.copyWith(
        isLiked: nextLiked,
        likeCount: nextLiked ? current.likeCount + 1 : current.likeCount - 1,
      );
    });
    try {
      await _repository.togglePostLike(current.id, current.isLiked);
    } catch (_) {
      if (mounted) setState(() => _userPosts[index] = current);
    }
  }

  Future<void> _openDetail(int index) async {
    final updated = await Navigator.of(context).push<CommunityPostModel>(
      MaterialPageRoute(
        builder: (_) => CommunityPostDetailScreen(post: _userPosts[index]),
      ),
    );
    if (updated != null && mounted) {
      setState(() => _userPosts[index] = updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_userPosts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Text(
            'Belum ada postingan komunitas.',
            style: TextStyle(color: Color(0xFF757575)),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
      padding: EdgeInsets.zero,
      itemCount: _userPosts.length,
      itemBuilder: (context, index) {
        final post = _userPosts[index];
        return CommunityPostCard(
          post: post,
          onLikeTap: () => _toggleLike(index),
          onPostTap: () => _openDetail(index),
          onCommentTap: () => _openDetail(index),
        );
      },
    );
  }
}