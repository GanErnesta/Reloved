import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../home/models/product.dart';

enum TransactionMode { sale, rent }

class TransactionConfirmationModal extends StatefulWidget {
  final Product product;
  final TransactionMode initialMode;
  final ValueChanged<Map<String, dynamic>> onConfirm;

  const TransactionConfirmationModal({
    super.key,
    required this.product,
    this.initialMode = TransactionMode.sale,
    required this.onConfirm,
  });

  @override
  State<TransactionConfirmationModal> createState() =>
      _TransactionConfirmationModalState();
}

class _TransactionConfirmationModalState
    extends State<TransactionConfirmationModal> {
  late TransactionMode _mode;
  late int _quantity;
  late int _duration;

  String _rentalPeriod = 'daily';

  @override
  void initState() {
    super.initState();

    _mode = widget.initialMode;
    _quantity = widget.product.minPurchase;
    _duration = widget.product.minRentalDuration;
    _rentalPeriod = widget.product.rentalPeriod ?? 'daily';
  }

  int get _stock => widget.product.stock;

  bool get _isRent => _mode == TransactionMode.rent;

  bool get _canConfirm {
    if (_stock <= 0) return false;

    if (_quantity < widget.product.minPurchase || _quantity > _stock) {
      return false;
    }

    if (_isRent && _duration < widget.product.minRentalDuration) {
      return false;
    }

    if (_isRent &&
        (widget.product.rentalPrice == null ||
            widget.product.rentalPrice! <= 0)) {
      return false;
    }

    return true;
  }

  String _formatPrice(double price) {
    final value = price.toInt().toString();

    final formatted = value.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );

    return 'Rp $formatted';
  }

  double get _totalPrice {
    if (_isRent) {
      return (widget.product.rentalPrice ?? 0) * _quantity * _duration;
    }

    return widget.product.price * _quantity;
  }

  String get _periodLabel {
    switch (_rentalPeriod) {
      case 'weekly':
        return 'Mingguan';
      case 'monthly':
        return 'Bulanan';
      default:
        return 'Harian';
    }
  }

  void _changeQuantity(int value) {
    if (value < widget.product.minPurchase || value > _stock) {
      return;
    }

    setState(() {
      _quantity = value;
    });
  }

  void _changeDuration(int value) {
    if (value < widget.product.minRentalDuration) return;

    setState(() {
      _duration = value;
    });
  }

  void _confirm() {
    if (!_canConfirm) return;

    widget.onConfirm({
      'productId': widget.product.id,
      'transactionType': _mode == TransactionMode.sale ? 'sale' : 'rent',
      'quantity': _quantity,
      'duration': _isRent ? _duration : null,
      'rentalPeriod': _isRent ? _rentalPeriod : null,
      'totalPrice': _totalPrice,
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.lg),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  'Konfirmasi Transaksi',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 18),

                Text(
                  product.name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 16),

                if (product.transactionType == 'both')
                  _buildTransactionChoice(),

                _buildInformationRow('Stok', '$_stock'),

                const SizedBox(height: 12),

                _buildInformationRow(
                  'Minimum pembelian',
                  '${product.minPurchase}',
                ),

                if (_isRent) ...[
                  const SizedBox(height: 12),

                  _buildRentalPeriodSelector(),

                  const SizedBox(height: 12),

                  _buildInformationRow(
                    'Waktu Sewa (${_periodLabel.toLowerCase()})',
                    '',
                    child: _buildCounter(
                      value: _duration,
                      onDecrease: () => _changeDuration(_duration - 1),
                      onIncrease: () => _changeDuration(_duration + 1),
                      minimum: product.minRentalDuration,
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                _buildInformationRow(
                  'Jumlah',
                  '',
                  child: _buildCounter(
                    value: _quantity,
                    onDecrease: () => _changeQuantity(_quantity - 1),
                    onIncrease: () => _changeQuantity(_quantity + 1),
                    minimum: product.minPurchase,
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  '*Pastikan cek kondisi barang dengan teliti sebelum menekan tombol Bayar.*',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 12),

                _buildInformationRow('Total harga', _formatPrice(_totalPrice)),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _canConfirm ? _confirm : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: Colors.grey.shade400,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Konfirmasi',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionChoice() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pilih Jenis Transaksi',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(child: _buildModeButton('Jual', TransactionMode.sale)),
              const SizedBox(width: 8),
              Expanded(child: _buildModeButton('Sewa', TransactionMode.rent)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton(String label, TransactionMode mode) {
    final selected = _mode == mode;

    return OutlinedButton(
      onPressed: () {
        setState(() {
          _mode = mode;
          _quantity = widget.product.minPurchase;
          _duration = widget.product.minRentalDuration;
        });
      },
      style: OutlinedButton.styleFrom(
        backgroundColor: selected ? AppColors.primary : Colors.white,
        side: const BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInformationRow(String label, String value, {Widget? child}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(fontSize: 12),
          ),
        ),
        if (child != null)
          child
        else
          Text(value, style: AppTextStyles.bodyMedium.copyWith(fontSize: 12)),
      ],
    );
  }

  Widget _buildCounter({
    required int value,
    required VoidCallback onDecrease,
    required VoidCallback onIncrease,
    required int minimum,
  }) {
    final canDecrease = value > minimum;
    final canIncrease = value < _stock;

    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: canDecrease ? onDecrease : null,
            icon: const Icon(Icons.remove, size: 17),
            color: AppColors.textPrimary,
            disabledColor: AppColors.textSecondary,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          SizedBox(
            width: 24,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
                fontSize: 12,
              ),
            ),
          ),
          IconButton(
            onPressed: canIncrease ? onIncrease : null,
            icon: const Icon(Icons.add, size: 17),
            color: AppColors.textPrimary,
            disabledColor: AppColors.textSecondary,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildRentalPeriodSelector() {
    return _buildInformationRow(
      'Pilihan Sewa',
      '',
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _rentalPeriod,
            dropdownColor: Colors.white,
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white,
              size: 18,
            ),
            style: const TextStyle(color: Colors.white, fontSize: 11),
            items: const [
              DropdownMenuItem(value: 'daily', child: Text('Harian')),
              DropdownMenuItem(value: 'weekly', child: Text('Mingguan')),
              DropdownMenuItem(value: 'monthly', child: Text('Bulanan')),
            ],
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                _rentalPeriod = value;
              });
            },
          ),
        ),
      ),
    );
  }
}
