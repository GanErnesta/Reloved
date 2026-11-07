
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';

class CatalogPhotoSection extends StatefulWidget {
  final ValueChanged<List<XFile>> onImagesChanged;

  const CatalogPhotoSection({
    super.key,
    required this.onImagesChanged,
  });

  @override
  State<CatalogPhotoSection> createState() =>
      _CatalogPhotoSectionState();
}

class _CatalogPhotoSectionState extends State<CatalogPhotoSection> {
  final ImagePicker _picker = ImagePicker();

  final List<XFile> _selectedImages = [];

  static const int maxImages = 5;

  Future<void> _pickImages() async {
    final remainingSlots = maxImages - _selectedImages.length;

    if (remainingSlots <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maksimal hanya 5 foto produk.'),
        ),
      );
      return;
    }

    try {
      final List<XFile> images = await _picker.pickMultiImage(
        limit: remainingSlots,
        imageQuality: 80,
      );

      if (images.isEmpty) return;

      final availableImages = images.take(remainingSlots).toList();

      setState(() {
        _selectedImages.addAll(availableImages);
      });

      widget.onImagesChanged(List<XFile>.from(_selectedImages));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memilih foto: $e'),
        ),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });

    widget.onImagesChanged(List<XFile>.from(_selectedImages));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFEDE8E8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Foto Produk',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tambahkan foto produk agar lebih menarik perhatian pembeli.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ...List.generate(
                _selectedImages.length,
                (index) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(_selectedImages[index].path),
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),

              if (_selectedImages.length < maxImages)
                InkWell(
                  onTap: _pickImages,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF5F5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.5),
                        width: 1.2,
                      ),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo_outlined,
                          color: AppColors.primary,
                          size: 28,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tambah Foto',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            '${_selectedImages.length}/$maxImages foto dipilih',
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 4),

          const Text(
            'Format JPG, PNG atau JPEG. Maksimal 5 foto produk.',
            style: TextStyle(
              fontSize: 11,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
