import 'package:flutter/material.dart';
import '../../home/widgets/community_image.dart';
import '../models/community_post_model.dart';
import '../repositories/community_repository.dart';
import '../widgets/community_product_attachment.dart';
import 'community_select_product_screen.dart';

class CommunityCreatePostScreen extends StatefulWidget {
  final String communityId;

  const CommunityCreatePostScreen({
    super.key,
    required this.communityId,
  });

  @override
  State<CommunityCreatePostScreen> createState() =>
      _CommunityCreatePostScreenState();
}

class _CommunityCreatePostScreenState extends State<CommunityCreatePostScreen> {
  final CommunityRepository _repository = CommunityRepository();
  final TextEditingController _contentController = TextEditingController();
  UserProductModel? _attachedProduct;
  bool _isPostEnabled = false;
  bool _isSubmitting = false;
  String _userAvatar = 'assets/images/avatar_falisha.png';

  static const Color _primaryMaroon = Color(0xFF9B2335);

  @override
  void initState() {
    super.initState();
    _contentController.addListener(_checkPostStatus);
    _loadCurrentUserAvatar();
  }

  Future<void> _loadCurrentUserAvatar() async {
    final profile = await _repository.getCurrentUserProfileSummary();
    if (mounted) {
      setState(() {
        _userAvatar = profile['foto_profil'] ?? 'assets/images/avatar_falisha.png';
      });
    }
  }

  @override
  void dispose() {
    _contentController.removeListener(_checkPostStatus);
    _contentController.dispose();
    super.dispose();
  }

  void _checkPostStatus() {
    final enabled = _contentController.text.trim().isNotEmpty;
    if (enabled != _isPostEnabled && mounted) {
      setState(() => _isPostEnabled = enabled);
    }
  }

  Future<void> _openProductSelector() async {
    FocusScope.of(context).unfocus();

    final selected = await Navigator.of(context).push<UserProductModel>(
      MaterialPageRoute(
        builder: (_) => const CommunitySelectProductScreen(),
      ),
    );

    if (selected != null && mounted) {
      setState(() {
        _attachedProduct = selected;
      });
    }
  }

  Future<void> _createPost() async {
    if (!_isPostEnabled || _isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final createdPost = await _repository.createPost(
        communityId: widget.communityId,
        content: _contentController.text.trim(),
        attachedProductId: _attachedProduct?.id,
      );

      if (mounted) {
        Navigator.of(context).pop(createdPost);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    }
  }

  Widget _buildPostButton() {
    return ElevatedButton(
      onPressed: (_isPostEnabled && !_isSubmitting) ? _createPost : null,
      style: ElevatedButton.styleFrom(
        fixedSize: const Size(88, 42),
        minimumSize: const Size(88, 42),
        backgroundColor: _primaryMaroon,
        disabledBackgroundColor: const Color(0xFFDCA9AF),
        foregroundColor: Colors.white,
        disabledForegroundColor: Colors.white,
        elevation: 0,
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: _isSubmitting
          ? const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.white,
        ),
      )
          : const Text(
        'Post',
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildAttachButton() {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE09F41), width: 1),
      ),
      child: InkWell(
        onTap: _openProductSelector,
        borderRadius: BorderRadius.circular(12),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(
                Icons.shopping_cart_outlined,
                color: Color(0xFFE59428),
                size: 20,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Cantumkan produk',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFE59428),
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFE59428),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = _attachedProduct;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Material(
                      color: const Color(0xFFF6EEEE),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => Navigator.of(context).pop(),
                        child: const SizedBox(
                          width: 48,
                          height: 48,
                          child: Icon(
                            Icons.close_rounded,
                            color: Color(0xFF4A4A4A),
                            size: 26,
                          ),
                        ),
                      ),
                    ),
                    _buildPostButton(),
                  ],
                ),
              ),

              // Konten utama
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipOval(
                      child: CommunityImage(
                        path: _userAvatar,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 44,
                          height: 44,
                          color: const Color(0xFFEEEEEE),
                          child: const Icon(Icons.person, color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 6),
                          TextField(
                            controller: _contentController,
                            maxLines: null,
                            minLines: 1,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1.5,
                              color: Color(0xFF1E1E1E),
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Kamu ingin ngomongin apa?',
                              hintStyle: TextStyle(
                                color: Color(0xFF9E9E9E),
                                fontSize: 15,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (product == null)
                            _buildAttachButton()
                          else
                            CommunityProductAttachment(
                              product: AttachedProductModel(
                                id: product.id,
                                title: product.title,
                                price: product.price,
                              ),
                              onTap: _openProductSelector,
                            ),
                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}