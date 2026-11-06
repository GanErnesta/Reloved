
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../controllers/profile_controller.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> profile;

  const EditProfileScreen({
    super.key,
    required this.profile,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ProfileController _controller = ProfileController();
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _namaController = TextEditingController();

  Uint8List? _imageBytes;
  String? _imageExtension;
  String? _currentPhotoUrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _namaController.text = widget.profile['nama']?.toString() ?? '';
    _currentPhotoUrl = widget.profile['foto_profil']?.toString();
  }

  @override
  void dispose() {
    _namaController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1000,
      );

      if (image == null) return;

      final extension = image.name.split('.').last.toLowerCase();

      if (!['jpg', 'jpeg', 'png', 'webp'].contains(extension)) {
        _showMessage('Format foto tidak didukung.');
        return;
      }

      final bytes = await image.readAsBytes();

      if (!mounted) return;

      setState(() {
        _imageBytes = bytes;
        _imageExtension = extension;
      });
    } catch (e) {
      _showMessage('Gagal memilih foto: $e');
    }
  }

  Future<void> _saveProfile() async {
    if (_namaController.text.trim().isEmpty) {
      _showMessage('Nama tidak boleh kosong.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _controller.updateProfile(
        nama: _namaController.text,
        imageBytes: _imageBytes,
        imageExtension: _imageExtension,
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nim = widget.profile['nim']?.toString() ?? '-';
    final email = widget.profile['email']?.toString() ?? '-';
    final kampus = widget.profile['kampus']?.toString() ?? '-';
    final fakultas = widget.profile['fakultas']?.toString() ?? '-';
    final programStudi =
        widget.profile['program_studi']?.toString() ?? '-';

    ImageProvider? profileImage;

    if (_imageBytes != null) {
      profileImage = MemoryImage(_imageBytes!);
    } else if (_currentPhotoUrl != null &&
        _currentPhotoUrl!.isNotEmpty) {
      profileImage = NetworkImage(_currentPhotoUrl!);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Edit Profil',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: AppColors.primary.withValues(
                      alpha: 0.1,
                    ),
                    backgroundImage: profileImage,
                    child: profileImage == null
                        ? const Icon(
                            Icons.person,
                            size: 55,
                            color: AppColors.textSecondary,
                          )
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('Ganti Foto Profil'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Informasi Pribadi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildLabel('Nama Lengkap'),
            TextField(
              controller: _namaController,
              textCapitalization: TextCapitalization.words,
              decoration: _inputDecoration(
                hint: 'Masukkan nama lengkap',
                icon: Icons.person_outline,
              ),
            ),
            const SizedBox(height: 18),
            _buildLabel('NIM'),
            _buildReadOnlyField(nim),
            const SizedBox(height: 18),
            _buildLabel('Email'),
            _buildReadOnlyField(email),
            const SizedBox(height: 28),
            const Text(
              'Informasi Akademik',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildLabel('Kampus'),
            _buildReadOnlyField(kampus),
            const SizedBox(height: 18),
            _buildLabel('Fakultas'),
            _buildReadOnlyField(fakultas),
            const SizedBox(height: 18),
            _buildLabel('Program Studi'),
            _buildReadOnlyField(programStudi),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      AppColors.primary.withValues(alpha: 0.5),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Simpan Perubahan',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String value) {
    return TextField(
      readOnly: true,
      controller: TextEditingController(text: value),
      decoration: _inputDecoration(
        hint: value,
        icon: Icons.lock_outline,
      ).copyWith(
        fillColor: Colors.grey.shade100,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(
        icon,
        color: AppColors.textSecondary,
        size: 20,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 15,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
    );
  }
}
