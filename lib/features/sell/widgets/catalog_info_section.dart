
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/config/supabase_config.dart';

class CatalogInfoSection extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final String selectedCondition;
  final ValueChanged<String> onConditionChanged;

  final String? selectedCategoryId;
  final ValueChanged<String?>? onCategoryChanged;

  const CatalogInfoSection({
    super.key,
    required this.nameController,
    required this.descriptionController,
    required this.selectedCondition,
    required this.onConditionChanged,
    this.selectedCategoryId,
    this.onCategoryChanged,
  });

  Future<List<Map<String, dynamic>>> _getCategories() async {
    final response = await SupabaseConfig.client
        .from('categories')
        .select('id, name')
        .order('name');

    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEDE8E8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi Dasar',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          _label('Nama Barang'),
          _field(
            controller: nameController,
            hint: 'Masukkan nama barang',
          ),

          const SizedBox(height: 16),
          _label('Kategori'),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _getCategories(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LinearProgressIndicator();
              }

              if (snapshot.hasError) {
                return const Text(
                  'Gagal memuat kategori. Periksa koneksi Supabase.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.danger,
                  ),
                );
              }

              final categories = snapshot.data ?? [];

              if (categories.isEmpty) {
                return const Text(
                  'Belum ada kategori tersedia.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                );
              }

              final validSelectedId = categories.any(
                (category) => category['id'].toString() == selectedCategoryId,
              ) ? selectedCategoryId : null;

              return DropdownButtonFormField<String>(
                value: validSelectedId,
                isExpanded: true,
                hint: const Text(
                  'Pilih kategori...',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                decoration: _decoration(),
                items: categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category['id'].toString(),
                    child: Text(
                      category['name'].toString(),
                      style: const TextStyle(fontSize: 13),
                    ),
                  );
                }).toList(),
                onChanged: onCategoryChanged,
              );
            },
          ),

          const SizedBox(height: 16),
          _label('Deskripsi Produk'),
          _field(
            controller: descriptionController,
            hint: 'Jelaskan kondisi dan detail produk',
            maxLines: 4,
          ),

          const SizedBox(height: 16),
          _label('Kondisi Barang'),
          _buildConditionSelector(),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _field({
    required String hint,
    TextEditingController? controller,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: _decoration(hint: hint),
    );
  }

  InputDecoration _decoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontSize: 12,
        color: AppColors.textSecondary,
      ),
      filled: true,
      fillColor: const Color(0xFFFFFCFC),
      contentPadding: const EdgeInsets.all(14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
    );
  }

  Widget _buildConditionSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _conditionOption('Baru/Tag'),
          _conditionOption('Bekas'),
        ],
      ),
    );
  }

  Widget _conditionOption(String value) {
    final isSelected = selectedCondition == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => onConditionChanged(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isSelected
                  ? Colors.white
                  : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
