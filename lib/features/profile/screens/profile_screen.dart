import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';

import '../../auth/services/auth_service.dart';
import '../../orders/screens/seller_manage_orders_screen.dart';

import '../controllers/profile_controller.dart';
import '../repository/profile_repository.dart';

import '../widgets/profile_header.dart';
import '../widgets/trust_score_card.dart';
import '../widgets/logout_button.dart';
import '../widgets/profile_catalog_tab.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final ProfileController _controller = ProfileController();
  final ProfileRepository _repository = ProfileRepository();

  late Future<Map<String, dynamic>?> _profileFuture;
  late TabController _tabController;

  String? recoveryError;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 2,
      vsync: this,
    );

    _profileFuture = loadProfile();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ==========================================
  // LOAD PROFILE
  // ==========================================

  Future<Map<String, dynamic>?> loadProfile() async {
    final user = AuthService.currentUser;

    if (user == null) {
      throw Exception('Pengguna belum login.');
    }

    try {
      final existingProfile = await _controller.getProfile();

      if (existingProfile != null) {
        recoveryError = null;
        return existingProfile;
      }

      // Recovery jika profil belum tersedia.
      await _repository.saveProfileFromMetadata();

      final recoveredProfile = await _controller.getProfile();

      if (recoveredProfile == null) {
        recoveryError = 'Profil belum berhasil ditemukan.';
      } else {
        recoveryError = null;
      }

      return recoveredProfile;
    } catch (e) {
      recoveryError = e.toString().replaceFirst(
        'Exception: ',
        '',
      );

      debugPrint('PROFILE LOAD ERROR: $e');

      return null;
    }
  }

  void retryLoadProfile() {
    setState(() {
      recoveryError = null;
      _profileFuture = loadProfile();
    });
  }

  // ==========================================
  // NAVIGATION
  // ==========================================

  Future<void> _logout() async {
    try {
      await AuthService.signOut();

      if (!mounted) return;

      context.go('/register');
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal logout: $e'),
        ),
      );
    }
  }

  void _openSellerOrders() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SellerManageOrdersScreen(),
      ),
    );
  }

  // ==========================================
  // PROFILE NOT FOUND
  // ==========================================

  Widget _buildProfileNotFound() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.person_search_outlined,
                size: 64,
                color: AppColors.textSecondary,
              ),

              const SizedBox(height: 16),

              const Text(
                'Data profil belum tersedia',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                recoveryError ?? 'Lengkapi informasi profilmu.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.go('/profile-recovery');
                  },
                  child: const Text('Lengkapi Profil'),
                ),
              ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: retryLoadProfile,
                child: const Text('Coba Lagi'),
              ),

              const SizedBox(height: 8),

              LogoutButton(
                onPressed: _logout,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // POSTINGAN EMPTY STATE
  // ==========================================

  Widget _buildEmptyPostTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.article_outlined,
              size: 52,
              color: AppColors.textSecondary,
            ),

            const SizedBox(height: 12),

            const Text(
              'Belum Ada Postingan',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Postingan yang kamu buat akan muncul di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // LOADING
  // ==========================================

  Widget _buildLoading() {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  // ==========================================
  // MAIN PROFILE SCREEN
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoading();
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 50,
                      color: AppColors.danger,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Gagal memuat profil',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: retryLoadProfile,
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (snapshot.data == null) {
          return _buildProfileNotFound();
        }

        final profile = snapshot.data!;

        return Scaffold(
          backgroundColor: const Color(0xFFFCFAFA),

          // APP BAR
          appBar: AppBar(
            backgroundColor: const Color(0xFFFCFAFA),
            elevation: 0,
            automaticallyImplyLeading: false,

            title: const Text(
              'Profil',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: AppColors.textPrimary,
              ),
            ),

            actions: [
              IconButton(
                onPressed: () {
                  // TODO: Navigasi ke halaman pengaturan.
                },
                icon: const Icon(
                  Icons.settings_outlined,
                  size: 27,
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),

          body: Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    // ==================================
                    // PROFILE HEADER & TRUST SCORE
                    // ==================================

                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          20,
                          12,
                          20,
                          16,
                        ),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ProfileHeader(
                              profile: profile,
                            ),

                            const SizedBox(height: 16),

                            // EDIT PROFILE & MANAGE ORDERS
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      // TODO: Edit Profil.
                                    },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.primary,
                                      side: const BorderSide(
                                        color: AppColors.primary,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      'Edit Profil',
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 12),

                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _openSellerOrders,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      'Kelola Pesanan',
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // TRUST SCORE
                            const TrustScoreCard(),
                          ],
                        ),
                      ),
                    ),

                    // ==================================
                    // TAB BAR
                    // ==================================

                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _ProfileTabDelegate(
                        TabBar(
                          controller: _tabController,
                          labelColor: AppColors.textPrimary,
                          unselectedLabelColor:
                              AppColors.textPrimary,
                          indicatorColor: AppColors.primary,
                          indicatorWeight: 3,
                          labelStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                          unselectedLabelStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                          tabs: const [
                            Tab(text: 'Postingan'),
                            Tab(text: 'Katalog'),
                          ],
                        ),
                      ),
                    ),

                    // ==================================
                    // TAB CONTENT
                    // ==================================

                    SliverFillRemaining(
                      hasScrollBody: true,

                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // POSTINGAN
                          _buildEmptyPostTab(),

                          // KATALOG DARI SUPABASE
                          const ProfileCatalogTab(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ==========================================
// TAB BAR DELEGATE
// ==========================================

class _ProfileTabDelegate
    extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _ProfileTabDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: const Color(0xFFFCFAFA),
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(
    covariant _ProfileTabDelegate oldDelegate,
  ) {
    return oldDelegate.tabBar != tabBar;
  }
}
