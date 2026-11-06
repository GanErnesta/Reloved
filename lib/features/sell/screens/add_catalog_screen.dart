
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../home/services/product_service.dart';
import '../widgets/catalog_photo_section.dart';
import '../widgets/catalog_info_section.dart';
import '../widgets/catalog_price_section.dart';
import '../widgets/catalog_transaction_section.dart';
import '../widgets/catalog_total_price_section.dart';

class AddCatalogScreen extends StatefulWidget {
  const AddCatalogScreen({super.key});

  @override
  State<AddCatalogScreen> createState() => _AddCatalogScreenState();
}

class _AddCatalogScreenState extends State<AddCatalogScreen> {
  final ProductService _productService = ProductService();

  // FORM CONTROLLERS
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController =
      TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController stockController = TextEditingController();
  final TextEditingController totalPriceController =
      TextEditingController();

  // FORM STATES
  String? selectedCategoryId;
  String selectedCondition = 'Baru/Tag';
  String selectedTransaction = 'jual';

  int rentalDuration = 3;
  String? selectedPeriod;

  // SELECTED PRODUCT IMAGES
  List<XFile> selectedImages = [];

  // SUBMISSION STATE
  bool isSubmitting = false;

  // FORM VALIDATION
  bool get isFormValid {
    final basicInfoValid =
        selectedImages.isNotEmpty &&
        nameController.text.trim().isNotEmpty &&
        descriptionController.text.trim().isNotEmpty &&
        selectedCategoryId != null;

    if (!basicInfoValid) return false;

    if (selectedTransaction == 'jual') {
      final price = double.tryParse(priceController.text) ?? 0;
      final stock = int.tryParse(stockController.text) ?? 0;

      return price > 0 && stock > 0;
    }

    final rentalPrice =
        double.tryParse(totalPriceController.text) ?? 0;

    return rentalPrice > 0 &&
        rentalDuration > 0 &&
        selectedPeriod != null;
  }

  // AUTOMATIC FORM VALIDATION
  @override
  void initState() {
    super.initState();

    nameController.addListener(_updateForm);
    descriptionController.addListener(_updateForm);
    priceController.addListener(_updateForm);
    stockController.addListener(_updateForm);
    totalPriceController.addListener(_updateForm);
  }

  void _updateForm() {
    if (mounted) {
      setState(() {});
    }
  }

  // SUBMIT CATALOG TO SUPABASE
  Future<void> _submitCatalog() async {
    if (!isFormValid || isSubmitting) return;

    setState(() {
      isSubmitting = true;
    });

    try {
      await _productService.createProduct(
        categoryId: selectedCategoryId!,
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
        price: selectedTransaction == 'jual'
            ? double.parse(priceController.text)
            : 0,
        condition: selectedCondition,
        images: selectedImages,
        transactionType: selectedTransaction,
        stock: selectedTransaction == 'jual'
            ? int.parse(stockController.text)
            : 1,
        rentalPrice: selectedTransaction == 'sewa'
            ? double.parse(totalPriceController.text)
            : null,
        rentalPeriod: selectedTransaction == 'sewa'
            ? selectedPeriod
            : null,
        minRentalDuration: selectedTransaction == 'sewa'
            ? rentalDuration
            : 1,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Katalog berhasil ditambahkan!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menambahkan katalog: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  // DISPOSE CONTROLLERS
  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    stockController.dispose();
    totalPriceController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFAFA),

      // APP BAR
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCFAFA),
        elevation: 0,
        leading: IconButton(
          onPressed: isSubmitting
              ? null
              : () => Navigator.of(context).maybePop(),
          icon: const Icon(
            Icons.chevron_left_rounded,
            color: AppColors.textPrimary,
            size: 30,
          ),
        ),
        title: const Text(
          'Tambah Katalog',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // FORM CONTENT
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // PRODUCT PHOTOS
            CatalogPhotoSection(
              onImagesChanged: (images) {
                setState(() {
                  selectedImages = images;
                });
              },
            ),
            const SizedBox(height: 16),

            // BASIC INFORMATION
            CatalogInfoSection(
              nameController: nameController,
              descriptionController: descriptionController,
              selectedCondition: selectedCondition,
              onConditionChanged: (value) {
                setState(() {
                  selectedCondition = value;
                });
              },
              selectedCategoryId: selectedCategoryId,
              onCategoryChanged: (value) {
                setState(() {
                  selectedCategoryId = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // TRANSACTION TYPE
            CatalogTransactionSection(
              selectedTransaction: selectedTransaction,
              onTransactionChanged: (value) {
                setState(() {
                  selectedTransaction = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // FORM BASED ON TRANSACTION TYPE
            if (selectedTransaction == 'jual') ...[
              CatalogPriceSection(
                priceController: priceController,
                stockController: stockController,
              ),
            ] else ...[
              CatalogTotalPriceSection(
                totalPriceController: totalPriceController,
                rentalDuration: rentalDuration,
                selectedPeriod: selectedPeriod,
                onDurationChanged: (value) {
                  setState(() {
                    rentalDuration = value;
                  });
                },
                onPeriodChanged: (value) {
                  setState(() {
                    selectedPeriod = value;
                  });
                },
              ),
            ],
          ],
        ),
      ),

      // FIXED BOTTOM BUTTON
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          color: const Color(0xFFFCFAFA),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: isFormValid && !isSubmitting
                  ? _submitCatalog
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: Colors.grey.shade300,
                foregroundColor: Colors.white,
                disabledForegroundColor: Colors.grey.shade500,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isSubmitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Tambah Katalog',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
