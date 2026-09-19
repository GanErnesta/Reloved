import 'package:flutter/material.dart';

import '../widgets/category_menu.dart';
import '../widgets/home_header.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/information_card.dart';
import '../widgets/product_section.dart';
import '../widgets/promo_banner.dart';
import '../widgets/bundling_card.dart';
import '../widgets/location_permission_modal.dart';
import 'all_products_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void _showLocationModal() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (context) {
        return LocationPermissionModal(
          onAllowLocation: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: HomeHeader(onLocationTap: _showLocationModal),
            ),
            const SliverToBoxAdapter(child: HomeSearchBar()),
            const SliverToBoxAdapter(child: CategoryMenu()),
            const SliverToBoxAdapter(child: PromoBanner()),
            SliverToBoxAdapter(
              child: ProductSection(
                onSeeAll: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AllProductsScreen(),
                    ),
                  );
                },
              ),
            ),
            SliverToBoxAdapter(child: _buildBundlingSection()),
            const SliverToBoxAdapter(child: InformationSection()),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildBundlingSection() {
    const bundles = [
      BundleItem(
        title: 'Paket Ospek Lengkap',
        description: 'Kemeja + Celana + Dasi',
        price: 'Rp 120.000',
        oldPrice: 'Rp 150.000',
        badge: 'Lebih Hemat',
      ),
      BundleItem(
        title: 'Paket Kamar Kos',
        description: 'Kasur Lipat + Kipas',
        price: 'Rp 200.000',
        oldPrice: 'Rp 250.000',
        badge: 'Lebih Hemat',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 0, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              decoration: BoxDecoration(
                color: const Color(0xFF9F283A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Paket Bundling Hemat Mahasiswa Kos',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 106,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(right: 16),
              itemCount: bundles.length,
              separatorBuilder: (_, __) {
                return const SizedBox(width: 14);
              },
              itemBuilder: (context, index) {
                return BundlingCard(bundle: bundles[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
