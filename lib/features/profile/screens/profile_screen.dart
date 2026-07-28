import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_spacing.dart';
import '../../auth/services/auth_service.dart';
import '../controllers/profile_controller.dart';
import '../widgets/logout_button.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_info_card.dart';
import '../widgets/profile_menu_tile.dart';
import '../widgets/campus_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await AuthService.signOut();

    if (!context.mounted) return;

    context.go('/auth');
  }

  @override
  Widget build(BuildContext context) {
    final controller = ProfileController();

    return FutureBuilder<Map<String, dynamic>?>(
      future: controller.getProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Scaffold(
            body: Center(child: Text('Data profil tidak ditemukan')),
          );
        }

        final profile = snapshot.data!;

        return Scaffold(
          appBar: AppBar(title: const Text("Profil Saya")),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                /// Header
                ProfileHeader(profile: profile),

                const SizedBox(height: AppSpacing.md),

                /// Campus Card
                if (profile['campuses'] != null)
                  CampusCard(campus: profile['campuses']),

                /// Informasi Mahasiswa
                ProfileInfoCard(profile: profile),

                const SizedBox(height: AppSpacing.lg),

                /// Menu
                ProfileMenuTile(
                  icon: Icons.edit_outlined,
                  title: "Edit Profil",
                  onTap: () {
                    // TODO: Edit Profile
                  },
                ),

                ProfileMenuTile(
                  icon: Icons.security,
                  title: "Keamanan",
                  onTap: () {},
                ),

                ProfileMenuTile(
                  icon: Icons.help_outline,
                  title: "Bantuan",
                  onTap: () {},
                ),

                ProfileMenuTile(
                  icon: Icons.info_outline,
                  title: "Tentang Aplikasi",
                  onTap: () {},
                ),

                const SizedBox(height: AppSpacing.xl),

                LogoutButton(onPressed: () => _logout(context)),
              ],
            ),
          ),
        );
      },
    );
  }
}
