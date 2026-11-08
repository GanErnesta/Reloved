
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/config/supabase_config.dart';

class CatalogInfoSection extends StatefulWidget {
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

  @override
  State<CatalogInfoSection> createState() => _CatalogInfoSectionState();
}

class _CatalogInfoSectionState extends State<CatalogInfoSection> {
  late Future<List<Map<String, dynamic>>> _categoriesFuture;

  static const List<_CategoryItem> categories = [
    _CategoryItem(
      icon: Icons.menu_book_outlined,
      title: 'Buku Kuliah',
      categoryName: 'Buku',
    ),
    _CategoryItem(
      icon: Icons.bed_outlined,
      title: 'Barang Kost',
      categoryName: 'Barang Kost',
    ),
    _CategoryItem(
      icon: Icons.checkroom_outlined,
      title: 'Fashion Kampus',
      categoryName: 'Pakaian',
    ),
    _CategoryItem(
      icon: Icons.science_outlined,
      title: 'Alat Praktikum',
      categoryName: 'Alat Praktikum',
    ),
    _CategoryItem(
      icon: Icons.restaurant_outlined,
      title: 'Bumbu Makanan',
      categoryName: 'Bumbu Makanan',
    ),
    _CategoryItem(
      icon: Icons.tv_outlined,
      title: 'Alat Elektronik',
      categoryName: 'Elektronik',
    ),
    _CategoryItem(
      icon: Icons.face_retouching_natural_outlined,
      title: 'Makeup & Skincare',
      categoryName: 'Makeup & Skincare',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _getCategories();
  }

  Future<List<Map<String, dynamic>>> _getCategories() async {
    final response = await SupabaseConfig.client
        .from('categories')
        .select('id, name');

    final allCategories = List<Map<String, dynamic>>.from(response);

    final orderedCategories = <Map<String, dynamic>>[];

    for (final item in categories) {
      final matched = allCategories.where(
        (category) =>
            category['name'].toString().trim().toLowerCase() ==
            item.categoryName.toLowerCase(),
      );

      if (matched.isNotEmpty) {
        orderedCategories.add(matched.first);
      }
    }

    return orderedCategories;
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
            controller: widget.nameController,
            hint: 'Masukkan nama barang',
          ),

          const SizedBox(height: 16),
          _label('Kategori'),

          FutureBuilder<List<Map<String, dynamic>>>(
            future: _categoriesFuture,
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

              final availableCategories = snapshot.data ?? [];

              if (availableCategories.isEmpty) {
                return const Text(
                  'Belum ada kategori tersedia.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                );
              }

              final dropdownItems = availableCategories.map((category) {
                final categoryName = category['name'].toString();

                final categoryItem = categories.firstWhere(
                  (item) =>
                      item.categoryName.toLowerCase() ==
                      categoryName.trim().toLowerCase(),
                );

                return DropdownMenuItem<String>(
                  value: category['id'].toString(),
                  child: Row(
                    children: [
                      Icon(
                        categoryItem.icon,
                        size: 21,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          categoryItem.title,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList();

              final validSelectedId = dropdownItems.any(
                (item) => item.value == widget.selectedCategoryId,
              )
                  ? widget.selectedCategoryId
                  : null;

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
                items: dropdownItems,
                onChanged: widget.onCategoryChanged,
              );
            },
          ),

          const SizedBox(height: 16),
          _label('Deskripsi Produk'),
          _field(
            controller: widget.descriptionController,
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
    final isSelected = widget.selectedCondition == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => widget.onConditionChanged(value),
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

class _CategoryItem {
  final IconData icon;
  final String title;
  final String categoryName;

  const _CategoryItem({
    required this.icon,
    required this.title,
    required this.categoryName,
  });
}
