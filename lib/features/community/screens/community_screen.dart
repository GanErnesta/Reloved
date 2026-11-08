import 'dart:async';
import 'package:flutter/material.dart';
import '../models/community_model.dart';
import '../models/community_post_model.dart';
import '../repositories/community_repository.dart';
import '../widgets/community_back_button.dart';
import '../widgets/community_card.dart';
import '../widgets/community_empty_search.dart';
import '../widgets/community_post_card.dart';
import '../widgets/community_search_bar.dart';
import '../widgets/community_search_history_item.dart';
import '../widgets/community_search_loading.dart';
import '../widgets/community_tab_bar.dart';
import 'community_detail_screen.dart';
import 'community_post_detail_screen.dart';

class CommunityScreen extends StatefulWidget {
  final int initialTabIndex;

  const CommunityScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final CommunityRepository _repository = CommunityRepository();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _searchDebounce;

  late int _selectedTabIndex;
  List<CommunityModel> _communities = [];
  List<CommunityModel> _searchResults = [];
  List<CommunityPostModel> _explorePosts = [];

  bool _isLoadingCommunities = true;
  bool _isLoadingExplore = true;
  bool _isSearchMode = false;
  bool _isSearching = false;
  String _searchQuery = '';

  final List<String> _searchHistory = [
    'Kemeja Putih',
    'Jas Almamater',
    'Sepatu Pantofel',
    'Rok Hitam',
  ];

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.initialTabIndex;
    _searchFocusNode.addListener(_handleFocusChange);
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      _fetchCommunities(),
      _fetchExplorePosts(),
    ]);
  }

  Future<void> _fetchCommunities() async {
    setState(() => _isLoadingCommunities = true);
    try {
      final data = await _repository.getCommunities();
      if (mounted) {
        setState(() {
          _communities = data;
          _isLoadingCommunities = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingCommunities = false);
    }
  }

  Future<void> _fetchExplorePosts() async {
    setState(() => _isLoadingExplore = true);
    try {
      final posts = await _repository.getPosts(sortByPopular: false);
      if (mounted) {
        setState(() {
          _explorePosts = posts;
          _isLoadingExplore = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingExplore = false);
    }
  }

  void _handleFocusChange() {
    if (_searchFocusNode.hasFocus && !_isSearchMode) {
      setState(() {
        _isSearchMode = true;
      });
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchFocusNode.removeListener(_handleFocusChange);
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();

    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _searchQuery = '';
        _isSearching = false;
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearchMode = true;
      _searchQuery = trimmed;
      _isSearching = true;
    });

    _searchDebounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        final results = await _repository.getCommunities(searchQuery: trimmed);
        if (!mounted) return;
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      } catch (_) {
        if (!mounted) return;
        setState(() => _isSearching = false);
      }
    });
  }

  void _selectHistoryKeyword(String keyword) {
    _searchController.text = keyword;
    _searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: keyword.length),
    );
    _onSearchChanged(keyword);
  }

  void _exitSearchModeOrPop() {
    if (_isSearchMode) {
      _searchDebounce?.cancel();
      _searchController.clear();
      _searchFocusNode.unfocus();
      setState(() {
        _isSearchMode = false;
        _isSearching = false;
        _searchQuery = '';
        _searchResults = [];
      });
    } else {
      Navigator.of(context).maybePop();
    }
  }

  Future<void> _openCommunityDetail(CommunityModel community) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CommunityDetailScreen(community: community),
      ),
    );
    // Refresh data setelah kembali dari detail komunitas
    _loadInitialData();
  }

  Future<void> _toggleExplorePostLike(int index) async {
    final current = _explorePosts[index];
    final optimisticLiked = !current.isLiked;

    setState(() {
      _explorePosts[index] = current.copyWith(
        isLiked: optimisticLiked,
        likeCount:
        optimisticLiked ? current.likeCount + 1 : current.likeCount - 1,
      );
    });

    try {
      await _repository.togglePostLike(current.id, current.isLiked);
    } catch (_) {
      if (mounted) {
        setState(() => _explorePosts[index] = current);
      }
    }
  }

  Future<void> _openPostDetail(int index) async {
    final updatedPost = await Navigator.of(context).push<CommunityPostModel>(
      MaterialPageRoute(
        builder: (_) => CommunityPostDetailScreen(post: _explorePosts[index]),
      ),
    );

    if (updatedPost != null && mounted) {
      setState(() {
        _explorePosts[index] = updatedPost;
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isSearchMode,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _isSearchMode) {
          _exitSearchModeOrPop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: Row(
                  children: [
                    CommunityBackButton(
                      onTap: _exitSearchModeOrPop,
                    ),
                    const SizedBox(width: 20),
                    const Text(
                      'Komunitas',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: CommunitySearchBar(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  onTap: () {
                    if (!_isSearchMode) {
                      setState(() {
                        _isSearchMode = true;
                      });
                    }
                  },
                  onChanged: _onSearchChanged,
                ),
              ),
              const SizedBox(height: 10),
              // Tab Bar
              if (!_isSearchMode)
                CommunityTabBar(
                  tabs: const ['Komunitas', 'Jelajahi'],
                  selectedIndex: _selectedTabIndex,
                  onTabSelected: (index) {
                    setState(() {
                      _selectedTabIndex = index;
                    });
                  },
                ),
              // Body Content
              Expanded(
                child: _isSearchMode
                    ? _buildSearchBody()
                    : _selectedTabIndex == 0
                    ? _buildCommunityList(_communities)
                    : _buildExploreFeed(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBody() {
    if (_searchQuery.isEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.only(top: 10, bottom: 24),
        itemCount: _searchHistory.length,
        itemBuilder: (context, index) {
          final keyword = _searchHistory[index];
          return CommunitySearchHistoryItem(
            keyword: keyword,
            onTap: () => _selectHistoryKeyword(keyword),
          );
        },
      );
    }

    if (_isSearching) {
      return const CommunitySearchLoading();
    }

    if (_searchResults.isEmpty) {
      return const CommunityEmptySearch();
    }

    return _buildCommunityList(_searchResults);
  }

  Widget _buildCommunityList(List<CommunityModel> communities) {
    if (_isLoadingCommunities && !_isSearchMode) {
      return const CommunitySearchLoading(message: 'Memuat komunitas...');
    }

    return RefreshIndicator(
      onRefresh: _fetchCommunities,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        itemCount: communities.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final community = communities[index];
          return CommunityCard(
            community: community,
            onTap: () => _openCommunityDetail(community),
            onJoinTap: () => _openCommunityDetail(community),
          );
        },
      ),
    );
  }

  Widget _buildExploreFeed() {
    if (_isLoadingExplore) {
      return const CommunitySearchLoading(message: 'Memuat postingan...');
    }

    if (_explorePosts.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada postingan di komunitas.',
          style: TextStyle(color: Color(0xFF757575)),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchExplorePosts,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 4, bottom: 24),
        itemCount: _explorePosts.length,
        itemBuilder: (context, index) {
          final post = _explorePosts[index];
          return CommunityPostCard(
            post: post,
            onLikeTap: () => _toggleExplorePostLike(index),
            onPostTap: () => _openPostDetail(index),
            onCommentTap: () => _openPostDetail(index),
            onProductTap: post.attachedProduct != null
                ? () => _openProductDetail(post.attachedProduct!)
                : null,
          );
        },
      ),
    );
  }
}