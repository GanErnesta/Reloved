import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../auth/services/auth_service.dart';
import 'account_settings_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationEnabled = true;
  bool _isLoggingOut = false;

  String get _email =>
      Supabase.instance.client.auth.currentUser?.email ?? 'Tidak tersedia';

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Keluar dari Akun?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          content: const Text(
            'Apakah kamu yakin ingin keluar dari akun Reloved?',
            style: TextStyle(fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text(
                'Batal',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Keluar'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isLoggingOut = true);

    try {
      await AuthService.signOut();

      if (!mounted) return;

      context.go('/login');
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoggingOut = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal keluar dari akun. Coba lagi.')),
      );

      debugPrint('LOGOUT ERROR: $e');
    }
  }

  void _showInfo(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Mengerti',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10, top: 20),
      child: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    Color? iconColor,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFF8E9EB),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor ?? AppColors.primary, size: 21),
        ),
        title: Text(
          title,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.caption.copyWith(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
        trailing:
            trailing ??
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
              size: 22,
            ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AccountSettingsScreen()),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        title: Text(
          'Pengaturan',
          style: AppTextStyles.title.copyWith(
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 10,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF3E6F0),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        color: AppColors.primary,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Akun Reloved',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.verified_user_outlined,
                      color: AppColors.primary,
                      size: 21,
                    ),
                  ],
                ),
              ),

              _buildSectionTitle('PREFERENSI'),

              _buildSettingTile(
                icon: Icons.notifications_none,
                title: 'Notifikasi',
                subtitle: 'Atur notifikasi aplikasi',
                trailing: Switch.adaptive(
                  value: _notificationEnabled,
                  activeTrackColor: AppColors.primary,
                  onChanged: (value) {
                    setState(() {
                      _notificationEnabled = value;
                    });
                  },
                ),
                onTap: () {
                  setState(() {
                    _notificationEnabled = !_notificationEnabled;
                  });
                },
              ),

              _buildSectionTitle('AKUN & KEAMANAN'),

              _buildSettingTile(
                icon: Icons.person_outline,
                title: 'Informasi Akun',
                subtitle: 'Email dan informasi akun',
                onTap: () {
                  _showInfo(
                    'Informasi Akun',
                    'Email akun yang sedang digunakan:\n\n$_email',
                  );
                },
              ),

              _buildSettingTile(
                icon: Icons.lock_outline,
                title: 'Privasi & Keamanan',
                subtitle: 'Informasi keamanan akun',
                onTap: () {
                  _showInfo(
                    'Privasi & Keamanan',
                    'Reloved menggunakan Supabase Authentication '
                        'untuk membantu menjaga keamanan akun pengguna.',
                  );
                },
              ),

              _buildSectionTitle('BANTUAN'),

              _buildSettingTile(
                icon: Icons.help_outline,
                title: 'Pusat Bantuan',
                subtitle: 'Bantuan penggunaan aplikasi Reloved',
                onTap: () {
                  _showInfo(
                    'Pusat Bantuan',
                    'Jika mengalami kendala saat menggunakan Reloved, '
                        'silakan hubungi tim pengembang.',
                  );
                },
              ),

              _buildSettingTile(
                icon: Icons.description_outlined,
                title: 'Syarat & Ketentuan',
                subtitle: 'Ketentuan penggunaan aplikasi',
                onTap: () {
                  _showInfo(
                    'Syarat & Ketentuan',
                    'Gunakan Reloved secara bertanggung jawab. '
                        'Pastikan setiap transaksi dilakukan dengan '
                        'kesepakatan antara pembeli dan penjual.',
                  );
                },
              ),

              _buildSettingTile(
                icon: Icons.info_outline,
                title: 'Tentang Reloved',
                subtitle: 'Informasi aplikasi dan versi',
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'Reloved',
                    applicationVersion: '1.0.0',
                    applicationLegalese:
                        'Platform jual beli dan sewa kebutuhan mahasiswa.',
                  );
                },
              ),

              const SizedBox(height: 22),

              Center(
                child: Column(
                  children: [
                    Text(
                      'RELOVED',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Made with care for students',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Version 1.0.0',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}
