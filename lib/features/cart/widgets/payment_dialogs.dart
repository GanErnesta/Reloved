import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class PaymentDialogs {
  /// 1. Popup "Kode QR disimpan!"
  static Future<void> showQrSavedDialog(BuildContext context) {
    return _showSingleActionDialog(
      context,
      message: 'Kode QR disimpan!',
      buttonText: 'Ya',
    );
  }

  /// 2. Popup "Pembayaran berhasil!"
  static Future<void> showPaymentSuccessDialog(BuildContext context) {
    return _showSingleActionDialog(
      context,
      message: 'Pembayaran\nberhasil!',
      buttonText: 'Ya',
    );
  }

  /// 3. Popup "Sesi pembayaran habis. Mohon lakukan pembayaran ulang."
  static Future<void> showPaymentExpiredDialog(BuildContext context) {
    return _showSingleActionDialog(
      context,
      message: 'Sesi pembayaran\nhabis. Mohon\nlakukan\npembayaran ulang.',
      buttonText: 'Ya',
    );
  }

  /// 4. Popup Konfirmasi Batalkan Pembayaran
  static Future<bool> showCancelPaymentConfirmDialog(
      BuildContext context) async {
    final res = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.new_releases_outlined,
                size: 40,
                color: AppColors.textPrimary,
              ),
              const SizedBox(height: 12),
              const Text(
                'Batalkan pesanan?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Pesanan yang belum dibayar akan dibatalkan dan barang dikembalikan ke keranjang.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text(
                        'Kembali',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text(
                        'Ya',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return res ?? false;
  }

  static Future<void> _showSingleActionDialog(
      BuildContext context, {
        required String message,
        required String buttonText,
      }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.new_releases_outlined,
                size: 42,
                color: AppColors.textPrimary,
              ),
              const SizedBox(height: 14),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 42,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(
                    buttonText,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}