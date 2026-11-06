import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

import '../../auth/models/campus.dart';
import '../../auth/repositories/campus_repository.dart';
import '../../auth/services/auth_service.dart';

import '../controllers/profile_controller.dart';

class ProfileRecoveryScreen extends StatefulWidget {
  const ProfileRecoveryScreen({super.key});

  @override
  State<ProfileRecoveryScreen> createState() =>
      _ProfileRecoveryScreenState();
}

class _ProfileRecoveryScreenState
    extends State<ProfileRecoveryScreen> {
  final _formKey = GlobalKey<FormState>();

  final namaController = TextEditingController();
  final nimController = TextEditingController();
  final fakultasController = TextEditingController();
  final prodiController = TextEditingController();

  final ProfileController _controller = ProfileController();

  Campus? selectedCampus;

  bool isCheckingCampus = true;
  bool isSaving = false;
  String? campusError;

  String get email => AuthService.currentUser?.email ?? '';

  @override
  void initState() {
    super.initState();
    detectCampus();
  }

  @override
  void dispose() {
    namaController.dispose();
    nimController.dispose();
    fakultasController.dispose();
    prodiController.dispose();
    super.dispose();
  }

  Future<void> detectCampus() async {
    if (email.isEmpty) {
      setState(() {
        isCheckingCampus = false;
        campusError = 'Email akun tidak ditemukan.';
      });
      return;
    }

    try {
      final campus =
          await CampusRepository.getCampusByEmail(email);

      if (!mounted) return;

      setState(() {
        selectedCampus = campus;
        isCheckingCampus = false;

        if (campus == null) {
          campusError =
              'Kampus tidak ditemukan berdasarkan domain email.';
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isCheckingCampus = false;
        campusError = 'Gagal mendeteksi kampus: $e';
      });

      debugPrint('CAMPUS DETECTION ERROR: $e');
    }
  }

  Future<void> saveProfile() async {
    if (isSaving) return;

    if (!_formKey.currentState!.validate()) return;

    if (selectedCampus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            campusError ?? 'Data kampus belum tersedia.',
          ),
        ),
      );
      return;
    }

    try {
      setState(() => isSaving = true);

      await _controller.saveProfile(
        nama: namaController.text,
        nim: nimController.text,
        campusId: selectedCampus!.id,
        campusName: selectedCampus!.name,
        fakultas: fakultasController.text,
        programStudi: prodiController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil berhasil disimpan.'),
        ),
      );

      context.go('/profile');
    } catch (e) {
      debugPrint('SAVE RECOVERY PROFILE ERROR: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  Widget buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.label.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: AppTextStyles.body,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 15,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(
                color: AppColors.border,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(
                color: AppColors.border,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '$label wajib diisi.';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email Kampus',
          style: AppTextStyles.label.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          initialValue: email,
          readOnly: true,
          style: AppTextStyles.body,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.email_outlined),
            filled: true,
            fillColor: const Color(0xFFF0F0F0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(
                color: AppColors.border,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildCampusField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kampus',
          style: AppTextStyles.label.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0F0),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  isCheckingCampus
                      ? 'Memeriksa kampus...'
                      : selectedCampus?.name ??
                          'Kampus tidak ditemukan',
                  style: AppTextStyles.body.copyWith(
                    color: selectedCampus != null
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
              if (isCheckingCampus)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              else if (selectedCampus != null)
                const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 20,
                )
              else
                const Icon(
                  Icons.error_outline,
                  color: AppColors.danger,
                  size: 20,
                ),
            ],
          ),
        ),
        if (campusError != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              campusError!,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.danger,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Lengkapi Profil'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lengkapi Data Dirimu',
                  style: AppTextStyles.title.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Lengkapi informasi berikut agar akun Reloved '
                  'dapat digunakan dengan baik.',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                buildTextField(
                  label: 'Nama Lengkap',
                  hint: 'Masukkan nama lengkap',
                  controller: namaController,
                ),
                const SizedBox(height: AppSpacing.md),

                buildEmailField(),
                const SizedBox(height: AppSpacing.md),

                buildCampusField(),
                const SizedBox(height: AppSpacing.md),

                buildTextField(
                  label: 'NIM',
                  hint: 'Masukkan NIM',
                  controller: nimController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: AppSpacing.md),

                buildTextField(
                  label: 'Fakultas',
                  hint: 'Masukkan fakultas',
                  controller: fakultasController,
                ),
                const SizedBox(height: AppSpacing.md),

                buildTextField(
                  label: 'Program Studi',
                  hint: 'Masukkan program studi',
                  controller: prodiController,
                ),
                const SizedBox(height: AppSpacing.xl),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        isSaving || isCheckingCampus ||
                                selectedCampus == null
                            ? null
                            : saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                    child: isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Simpan Profil'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}