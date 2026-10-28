import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../models/community_model.dart';
import 'community_back_button.dart';

class CommunityHeaderBanner extends StatefulWidget {
  final CommunityModel community;
  final bool isJoined;
  final VoidCallback onJoinToggle;
  final VoidCallback? onShareTap;

  const CommunityHeaderBanner({
    super.key,
    required this.community,
    required this.isJoined,
    required this.onJoinToggle,
    this.onShareTap,
  });

  @override
  State<CommunityHeaderBanner> createState() => _CommunityHeaderBannerState();
}

class _CommunityHeaderBannerState extends State<CommunityHeaderBanner> {
  static const Color _primaryMaroon = Color(0xFF9B2335);
  static const int _collapsedCharLimit = 185;

  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final String fullDescription = widget.community.description;
    final bool isLongDescription =
        fullDescription.length > _collapsedCharLimit;

    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      alignment: Alignment.topCenter,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFCF7F7),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Banner dengan Tombol Back Overlay
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(
                    widget.community.bannerAsset,
                    width: double.infinity,
                    height: 175,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: 175,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF3A6073), Color(0xFF16222A)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: const Icon(
                          Icons.landscape_rounded,
                          size: 64,
                          color: Colors.white54,
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: CommunityBackButton(
                    backgroundColor:
                    const Color(0xFFF6EEEE).withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
            // Informasi Komunitas
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.community.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        widget.community.memberCountText.toLowerCase(),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF222222),
                        ),
                      ),
                      const SizedBox(width: 12),
                      InkWell(
                        onTap: widget.onShareTap,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _primaryMaroon,
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.share_outlined,
                            size: 16,
                            color: _primaryMaroon,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: SizedBox(
                          height: 34,
                          child: ElevatedButton(
                            onPressed: widget.onJoinToggle,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: widget.isJoined
                                  ? const Color(0xFF757575)
                                  : _primaryMaroon,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            // Tanpa tanda centang ketika sudah bergabung
                            child: const Text(
                              'Bergabung',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Deskripsi terbatas dengan tombol "... See more" / "See less"
                  _buildExpandableDescription(
                    fullDescription,
                    isLongDescription,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableDescription(String text, bool isLong) {
    if (!isLong) {
      return Text(
        text,
        style: const TextStyle(
          fontSize: 12.5,
          height: 1.4,
          color: Color(0xFF1E1E1E),
        ),
      );
    }

    final String displayedText = _isExpanded
        ? text
        : '${text.substring(0, _collapsedCharLimit).trimRight()}... ';

    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 12.5,
          height: 1.4,
          color: Color(0xFF1E1E1E),
        ),
        children: [
          TextSpan(text: displayedText),
          TextSpan(
            text: _isExpanded ? ' See less' : 'See more',
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: _primaryMaroon,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
          ),
        ],
      ),
    );
  }
}