import 'dart:async';
import 'package:flutter/material.dart';
import '../models/community_model.dart';
import '../models/community_post_model.dart';
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
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _searchDebounce;

  late int _selectedTabIndex; // 0: Komunitas, 1: Jelajahi
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
      });
      return;
    }

    setState(() {
      _isSearchMode = true;
      _searchQuery = trimmed;
      _isSearching = true;
    });

    // Simulasi state "Sedang mencari..." sebelum menampilkan hasil
    _searchDebounce = Timer(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        _isSearching = false;
      });
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
      });
    } else {
      Navigator.of(context).maybePop();
    }
  }

  List<CommunityModel> get _filteredCommunities {
    if (_searchQuery.isEmpty) {
      return CommunityModel.dummyCommunities;
    }
    return CommunityModel.dummyCommunities
        .where(
          (c) => c.name.toLowerCase().contains(_searchQuery.toLowerCase()),
    )
        .toList();
  }

  void _openCommunityDetail(CommunityModel community) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CommunityDetailScreen(community: community),
      ),
    );
  }

  void _openPostDetail(CommunityPostModel post) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CommunityPostDetailScreen(post: post),
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
              // Header: Tombol Back & Judul "Komunitas"
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
              // Tab Bar hanya tampil jika TIDAK sedang di dalam Mode Pencarian
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
              // Body Content (Mode Pencarian vs Mode Tab Normal)
              Expanded(
                child: _isSearchMode
                    ? _buildSearchBody()
                    : _selectedTabIndex == 0
                    ? _buildCommunityList(CommunityModel.dummyCommunities)
                    : _buildExploreFeed(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Menampilkan konten saat pengguna berada di Mode Pencarian
  Widget _buildSearchBody() {
    // 1. Jika input masih kosong -> tampilkan Riwayat Pencarian
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

    // 2. Jika sedang proses mencari -> tampilkan animasi 3 titik "Sedang mencari..."
    if (_isSearching) {
      return const CommunitySearchLoading();
    }

    // 3. Jika hasil pencarian kosong -> tampilkan ilustrasi Empty State
    final results = _filteredCommunities;
    if (results.isEmpty) {
      return const CommunityEmptySearch();
    }

    // 4. Jika hasil ditemukan -> tampilkan daftar CommunityCard yang cocok
    return _buildCommunityList(results);
  }

  /// Menampilkan daftar kartu komunitas (Tab Komunitas & Hasil Pencarian)
  Widget _buildCommunityList(List<CommunityModel> communities) {
    return ListView.separated(
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
    );
  }

  /// Menampilkan feed postingan pada Tab Jelajahi
  Widget _buildExploreFeed() {
    final posts = CommunityPostModel.dummyPosts;
    return ListView.builder(
      padding: const EdgeInsets.only(top: 4, bottom: 24),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return CommunityPostCard(
          post: post,
          onPostTap: () => _openPostDetail(post),
          onCommentTap: () => _openPostDetail(post),
        );
      },
    );
  }
}