import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  final FocusNode _searchFocusNode = FocusNode();
  final ProductService _productService = ProductService();

  static const String _historyKey = 'reloved_search_history';

  List<String> _searchHistory = [];
  List<Product> _products = [];

  Timer? _debounce;

  bool _isLoading = false;
  bool _hasSearched = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
  }

  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_historyKey) ?? [];

    if (!mounted) return;

    setState(() {
      _searchHistory = history;
    });
  }

  Future<void> _saveSearchHistory(String keyword) async {
    final query = keyword.trim();

    if (query.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();

    final history = List<String>.from(prefs.getStringList(_historyKey) ?? []);

    history.removeWhere((item) => item.toLowerCase() == query.toLowerCase());

    history.insert(0, query);

    if (history.length > 10) {
      history.removeRange(10, history.length);
    }

    await prefs.setStringList(_historyKey, history);

    if (!mounted) return;

    setState(() {
      _searchHistory = history;
    });
  }

  Future<void> _deleteHistory(String keyword) async {
    final prefs = await SharedPreferences.getInstance();

    final history = List<String>.from(_searchHistory)..remove(keyword);

    await prefs.setStringList(_historyKey, history);

    if (!mounted) return;

    setState(() {
      _searchHistory = history;
    });
  }

  Future<void> _clearHistory() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_historyKey);

    if (!mounted) return;

    setState(() {
      _searchHistory.clear();
    });
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();

    final query = value.trim();

    if (query.isEmpty) {
      setState(() {
        _isLoading = false;
        _hasSearched = false;
        _errorMessage = null;
        _products = [];
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String keyword) async {
    final query = keyword.trim();

    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _hasSearched = true;
      _errorMessage = null;
    });

    try {
      final results = await _productService.searchProducts(query);

      if (!mounted) return;

      if (_searchController.text.trim() != query) return;

      setState(() {
        _products = results;
        _isLoading = false;
      });

      await _saveSearchHistory(query);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'Gagal memuat hasil pencarian';
      });

      debugPrint('ERROR SEARCH PRODUCTS: $e');
    }
  }

  void _selectHistory(String keyword) {
    _searchController.text = keyword;
    _searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: keyword.length),
    );

    _performSearch(keyword);
  }

  String _formatPrice(double price) {
    final value = price.toInt().toString();

    final formatted = value.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );

    return 'Rp $formatted';
  }

  void _openProduct(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        titleSpacing: 0,
        title: _buildSearchField(),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 40,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        autofocus: true,
        textInputAction: TextInputAction.search,
        onChanged: _onSearchChanged,
        onSubmitted: _performSearch,
        style: AppTextStyles.body.copyWith(fontSize: 13),
        decoration: InputDecoration(
          hintText: 'Cari produk...',
          hintStyle: AppTextStyles.body.copyWith(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.textSecondary,
            size: 21,
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 38),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                    _searchFocusNode.requestFocus();
                  },
                  icon: const Icon(
                    Icons.close,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 9),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoading();
    }

    if (_errorMessage != null) {
      return _buildError();
    }

    if (_hasSearched) {
      if (_products.isEmpty) {
        return _buildEmptyResult();
      }

      return _buildSearchResults();
    }

    return _buildSearchHistory();
  }

  Widget _buildSearchHistory() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Pencarian Terakhir',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              if (_searchHistory.isNotEmpty)
                TextButton(
                  onPressed: _clearHistory,
                  child: Text(
                    'Hapus Semua',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (_searchHistory.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 90),
                child: Column(
                  children: [
                    Icon(
                      Icons.search,
                      size: 48,
                      color: AppColors.textSecondary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Belum ada riwayat pencarian',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Cari produk yang kamu butuhkan',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                itemCount: _searchHistory.length,
                separatorBuilder: (_, __) {
                  return const SizedBox(height: 2);
                },
                itemBuilder: (context, index) {
                  final keyword = _searchHistory[index];

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    leading: const Icon(
                      Icons.history,
                      color: AppColors.textPrimary,
                      size: 21,
                    ),
                    title: Text(
                      keyword,
                      style: AppTextStyles.bodyMedium.copyWith(fontSize: 12),
                    ),
                    trailing: IconButton(
                      onPressed: () => _deleteHistory(keyword),
                      icon: const Icon(
                        Icons.close,
                        size: 17,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    onTap: () => _selectHistory(keyword),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AnimatedLoadingDots(),
          const SizedBox(height: 16),
          Text(
            'Sedang mencari...',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textPrimary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyResult() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/imgsearch.png',
              width: 180,
              height: 180,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            Text(
              'Yah, barangnya belum ada nih',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Yuk, cari barang yang lain!',
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 45, color: AppColors.danger),
            const SizedBox(height: 12),
            Text(_errorMessage!, style: AppTextStyles.bodyMedium),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                _performSearch(_searchController.text);
              },
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            12,
          ),
          child: Row(
            children: [
              Text(
                'Hasil Pencarian',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Text(
                '${_products.length} produk ditemukan',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.lg,
            ),
            itemCount: _products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.72,
            ),
            itemBuilder: (context, index) {
              final product = _products[index];

              return ProductCard(
                product: ProductItem(
                  imageUrl: product.imageUrl,
                  name: product.name,
                  price: _formatPrice(product.price),
                  location: product.locationName,
                ),
                onTap: () => _openProduct(product),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Animasi tiga titik yang bergerak naik-turun secara bergantian.
class AnimatedLoadingDots extends StatefulWidget {
  const AnimatedLoadingDots({super.key});

  @override
  State<AnimatedLoadingDots> createState() => _AnimatedLoadingDotsState();
}

class _AnimatedLoadingDotsState extends State<AnimatedLoadingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final progress = (_controller.value - (index * 0.22)) % 1.0;

            final bounceProgress = progress < 0.5
                ? progress * 2
                : (1 - progress) * 2;

            final bounce = Curves.easeInOut.transform(bounceProgress);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.translate(
                offset: Offset(0, -9 * bounce),
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
