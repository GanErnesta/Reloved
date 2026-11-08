import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_catalog_tab.dart';
// Tambahkan import widget ProfileUserPostsList yang baru dibuat
import '../widgets/profile_user_posts_list.dart';

class SellerProfileScreen extends StatefulWidget {
  final String sellerId;

  const SellerProfileScreen({
    super.key,
    required this.sellerId,
  });

  @override
  State<SellerProfileScreen> createState() => _SellerProfileScreenState();
}

class _SellerProfileScreenState extends State<SellerProfileScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final Future<Map<String, dynamic>?> _profileFuture;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _profileFuture = _fetchSellerProfile();
  }

  Future<Map<String, dynamic>?> _fetchSellerProfile() async {
    // Sesuaikan query profil dengan struktur tabel Anda (menggunakan 'profiles' atau 'public_profiles' sesuai setup Anda)
    final result = await Supabase.instance.client
        .from('profiles') // Di skema SQL sebelumnya, nama tabelnya 'profiles'
        .select('id, nama, foto_profil, kampus, fakultas, program_studi')
        .eq('id', widget.sellerId)
        .maybeSingle();

    return result == null ? null : Map<String, dynamic>.from(result);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCFAFA),
        elevation: 0,
        title: const Text(
          'Profil Penjual',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError || snapshot.data == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.person_off_outlined,
                    size: 52,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Profil penjual tidak ditemukan.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Kembali'),
                  ),
                ],
              ),
            ),
          );
        }

        final profile = snapshot.data!;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: ProfileHeader(profile: profile),
            ),
            TabBar(
              controller: _tabController,
              labelColor: AppColors.textPrimary,
              unselectedLabelColor: AppColors.textPrimary,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
              tabs: const [
                Tab(text: 'Postingan'),
                Tab(text: 'Katalog'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Ganti Text placeholder dengan widget list postingan dari repository Komunitas
                  ProfileUserPostsList(
                    userId: widget.sellerId,
                    shrinkWrap: false,
                    physics: const AlwaysScrollableScrollPhysics(),
                  ),
                  ProfileCatalogTab(
                    sellerId: widget.sellerId,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    ),
    );
  }
}