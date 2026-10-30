import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class PaymentMethodScreen extends StatefulWidget {
  final String? initialMethod;

  const PaymentMethodScreen({
    super.key,
    this.initialMethod,
  });

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  String? _selectedMethod;

  static const List<String> _methods = [
    'QRIS',
    'OVO',
    'Gopay',
    'Shopeepay',
  ];

  @override
  void initState() {
    super.initState();
    _selectedMethod = widget.initialMethod;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        Navigator.of(context).pop(_selectedMethod);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leadingWidth: 64,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
            child: InkWell(
              onTap: () => Navigator.of(context).pop(_selectedMethod),
              borderRadius: BorderRadius.circular(24),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chevron_left_rounded,
                  color: AppColors.textPrimary,
                  size: 26,
                ),
              ),
            ),
          ),
          title: const Text(
            'Ubah Metode Bayar',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: _methods.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final method = _methods[index];
            final bool isSelected = _selectedMethod == method;

            return GestureDetector(
              onTap: () {
                // Hanya mengubah pilihan tanpa keluar dari halaman Ubah Metode Bayar
                setState(() {
                  _selectedMethod = method;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.45)
                        : Colors.transparent,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      method,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : const Color(0xFFD9D9D9),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}