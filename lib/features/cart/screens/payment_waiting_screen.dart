import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/navigation/main_screen.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/cart_controller.dart';
import '../widgets/payment_dialogs.dart';

class PaymentWaitingScreen extends StatefulWidget {
  const PaymentWaitingScreen({super.key});

  @override
  State<PaymentWaitingScreen> createState() => _PaymentWaitingScreenState();
}

class _PaymentWaitingScreenState extends State<PaymentWaitingScreen> {
  final CartController _cartController = CartController.instance;
  Timer? _countdownTimer;
  Duration _remaining = Duration.zero;
  bool _isOpeningUrl = false;

  @override
  void initState() {
    super.initState();
    _syncRemainingTime();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _syncRemainingTime();
    });
  }

  void _syncRemainingTime() {
    final session = _cartController.activePaymentSession;
    if (session == null) return;

    final diff = session.expiresAt.difference(DateTime.now());
    if (diff.isNegative || diff.inSeconds <= 0) {
      _countdownTimer?.cancel();
      _handleSessionExpired();
    } else {
      if (mounted) {
        setState(() {
          _remaining = diff;
        });
      }
    }
  }

  Future<void> _handleSessionExpired() async {
    await _cartController.cancelOrExpirePaymentSession();
    if (!mounted) return;
    await PaymentDialogs.showPaymentExpiredDialog(context);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _openMidtransPayment() async {
    final session = _cartController.activePaymentSession;
    if (session == null) return;

    setState(() => _isOpeningUrl = true);

    try {
      // Ambil redirect_url (Midtrans Snap) yang baru saja disimpan di kolom qris_string
      final response = await Supabase.instance.client
          .from('payment_sessions')
          .select('qris_string')
          .eq('id', session.sessionId)
          .single();

      final urlString = response['qris_string'] as String?;

      if (urlString != null && urlString.isNotEmpty) {
        final uri = Uri.parse(urlString);
        if (await canLaunchUrl(uri)) {
          // Buka di browser eksternal agar user nyaman melihat UI Midtrans
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tidak dapat membuka link pembayaran.')),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tautan pembayaran sedang diproses, coba lagi sebentar lagi.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isOpeningUrl = false);
      }
    }
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes : $seconds';
  }

  String _formatRupiah(int amount) {
    final str = amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
    );
    return 'Rp $str';
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = _cartController.activePaymentSession;
    if (session == null) {
      return const Scaffold(body: SizedBox.shrink());
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Selesaikan atau batalkan pembayaran terlebih dahulu.',
            ),
          ),
        );
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
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Harap konfirmasi atau batalkan pembayaran terlebih dahulu.',
                    ),
                  ),
                );
              },
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
            'Pembayaran',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // 1. Kartu Total Biaya & Bayar Dalam (Timer 30:00)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Biaya',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          _formatRupiah(session.grandTotal),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Bayar Dalam',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          _formatDuration(_remaining),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 2. Kartu Arahkan ke Midtrans (Menggantikan UI QRIS Palsu)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.lock_outline_rounded,
                      size: 64,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Selesaikan Pembayaran',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Klik tombol di bawah untuk diarahkan ke halaman aman Midtrans. Anda dapat menyelesaikan pembayaran menggunakan metode ${session.paymentMethod}.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isOpeningUrl ? null : _openMidtransPayment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isOpeningUrl
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                            : const Text(
                          'Buka Halaman Pembayaran',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 3. Panel Bawah: Konfirmasi Pembayaran & Batalkan Pesanan
        bottomNavigationBar: Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tombol Konfirmasi Pembayaran (Mengeksekusi RPC untuk mengubah pesanan dari pending ke paid)
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: OutlinedButton(
                    onPressed: () async {
                      // Ini akan memicu _cartController.confirmPaymentSuccess()
                      // Jika pembayaran sukses dan valid, layar beralih ke Order
                      final success =
                      await _cartController.confirmPaymentSuccess();
                      if (success && context.mounted) {
                        _countdownTimer?.cancel();
                        await PaymentDialogs.showPaymentSuccessDialog(context);
                        if (context.mounted) {
                          MainScreen.goToTab(context, MainScreen.ordersTab);
                        }
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(
                        color: AppColors.primary,
                        width: 1.4,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Konfirmasi Pembayaran',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Tombol Batalkan Pesanan (Mengeksekusi RPC untuk mengembalikan stok)
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: TextButton(
                    onPressed: () async {
                      final confirm = await PaymentDialogs
                          .showCancelPaymentConfirmDialog(context);
                      if (confirm && context.mounted) {
                        _countdownTimer?.cancel();
                        await _cartController.cancelOrExpirePaymentSession();
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      }
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                    ),
                    child: const Text(
                      'Batalkan Pesanan',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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