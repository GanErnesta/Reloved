import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

import '../models/campus.dart';
import '../repositories/campus_repository.dart';
import '../services/auth_service.dart';
import 'primary_button.dart';

class AuthCard extends StatefulWidget {
  const AuthCard({super.key});

  @override
  State<AuthCard> createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  final namaController = TextEditingController();
  final emailController = TextEditingController();
  final nimController = TextEditingController();
  final fakultasController = TextEditingController();
  final prodiController = TextEditingController();

  Campus? selectedCampus;

  bool isLoading = false;
  bool isCheckingCampus = false;
  String? campusError;

  int _campusRequestId = 0;

  @override
  void dispose() {
    namaController.dispose();
    emailController.dispose();
    nimController.dispose();
    fakultasController.dispose();
    prodiController.dispose();
    super.dispose();
  }

  Future<void> detectCampus(String email) async {
    final requestId = ++_campusRequestId;
    final value = email.trim().toLowerCase();

    if (!value.contains('@') ||
        value.split('@').length != 2 ||
        value.split('@').last.isEmpty) {
      setState(() {
        selectedCampus = null;
        campusError = null;
        isCheckingCampus = false;
      });
      return;
    }

    setState(() {
      selectedCampus = null;
      campusError = null;
      isCheckingCampus = true;
    });

    try {
      final campus = await CampusRepository.getCampusByEmail(value);

      if (!mounted || requestId != _campusRequestId) return;

      setState(() {
        selectedCampus = campus;
        isCheckingCampus = false;

        if (campus == null) {
          campusError = 'Domain email kampus tidak terdaftar.';
        }
      });
    } catch (e) {
      if (!mounted || requestId != _campusRequestId) return;

      setState(() {
        selectedCampus = null;
        isCheckingCampus = false;
        campusError = 'Gagal memeriksa domain kampus.';
      });

      debugPrint('DETECT CAMPUS ERROR: $e');
    }
  }

  Future<void> register() async {
    final nama = namaController.text.trim();
    final email = emailController.text.trim().toLowerCase();
    final nim = nimController.text.trim();
    final fakultas = fakultasController.text.trim();
    final prodi = prodiController.text.trim();

    if (nama.isEmpty ||
        email.isEmpty ||
        nim.isEmpty ||
        fakultas.isEmpty ||
        prodi.isEmpty) {
      _showMessage('Semua data wajib diisi.');
      return;
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email)) {
      _showMessage('Format email tidak valid.');
      return;
    }

    if (selectedCampus == null) {
      _showMessage(campusError ?? 'Gunakan email dari kampus yang terdaftar.');
      return;
    }

    try {
      setState(() => isLoading = true);

      await AuthService.sendOtp(
        email,
        userData: {
          'nama': nama,
          'full_name': nama,
          'nim': nim,
          'campus_id': selectedCampus!.id,
          'kampus': selectedCampus!.name,
          'fakultas': fakultas,
          'program_studi': prodi,
        },
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kode OTP berhasil dikirim.')),
      );

      context.go(
        '/verify-email',
        extra: {
          'email': email,
          'userData': {
            'nama': nama,
            'full_name': nama,
            'nim': nim,
            'campus_id': selectedCampus!.id,
            'kampus': selectedCampus!.name,
            'fakultas': fakultas,
            'program_studi': prodi,
          },
        },
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.label.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
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
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCampusField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kampus',
          style: AppTextStyles.label.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0F0),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  isCheckingCampus
                      ? 'Memeriksa kampus...'
                      : selectedCampus?.name ?? 'Kampus terdeteksi otomatis',
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
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else if (selectedCampus != null)
                const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 20,
                )
              else
                const Icon(
                  Icons.school_outlined,
                  color: AppColors.textSecondary,
                ),
            ],
          ),
        ),
        if (campusError != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              campusError!,
              style: AppTextStyles.caption.copyWith(color: AppColors.danger),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFFF5E8EA),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daftar Akun',
            style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Lengkapi data diri untuk membuat akun Reloved.',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: AppSpacing.lg),

          _buildField(
            label: 'Nama Lengkap',
            hint: 'Masukkan nama lengkap',
            controller: namaController,
          ),

          const SizedBox(height: AppSpacing.md),

          _buildField(
            label: 'Email Kampus',
            hint: 'nama@student.ub.ac.id',
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            onChanged: detectCampus,
          ),

          const SizedBox(height: AppSpacing.md),

          _buildCampusField(),

          const SizedBox(height: AppSpacing.md),

          _buildField(
            label: 'NIM',
            hint: 'Masukkan NIM',
            controller: nimController,
            keyboardType: TextInputType.number,
          ),

          const SizedBox(height: AppSpacing.md),

          _buildField(
            label: 'Fakultas',
            hint: 'Masukkan fakultas',
            controller: fakultasController,
          ),

          const SizedBox(height: AppSpacing.md),

          _buildField(
            label: 'Program Studi',
            hint: 'Masukkan program studi',
            controller: prodiController,
          ),

          const SizedBox(height: AppSpacing.xl),

          PrimaryButton(
            text: 'Daftar Sekarang',
            loading: isLoading,
            onPressed: isLoading || isCheckingCampus ? null : register,
          ),
        ],
      ),
    );
  }
}
