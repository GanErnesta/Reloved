import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool _isCheckingPayment = false;

  @override
  void initState() {
    super.initState();
    _cartController.addListener(_onCartChanged);
    _syncRemainingTime();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _syncRemainingTime();
    });
  }

  void _onCartChanged() {
    if (mounted) {
      setState(() {});
    }
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

  Future<void> _openMidtransPage(String urlString) async {
    final uri = Uri.tryParse(urlString);
    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('URL pembayaran tidak valid.')),
      );
      return;
    }

    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal membuka browser. Silakan salin link pembayaran.'),
        ),
      );
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
    _cartController.removeListener(_onCartChanged);
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = _cartController.activePaymentSession;
    if (session == null) {
      return const Scaffold(body: SizedBox.shrink());
    }

    final bool isQris = session.paymentMethod.toUpperCase() == 'QRIS';
    final String? snapUrl = session.qrisString;
    final bool hasSnapUrl = snapUrl != null && snapUrl.startsWith('http');
    final bool isSyncing = session.sessionId == 'PENDING-SYNC' &&
        _cartController.lastErrorMessage == null;

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
                    if (session.midtransOrderId != null) ...[
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Order ID Midtrans',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            session.midtransOrderId!,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 2. Kartu Instruksi Pembayaran Midtrans
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    Text(
                      isQris ? 'QRIS' : session.paymentMethod,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'klik untuk mendapatkan kode.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (isSyncing) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: CircularProgressIndicator(),
                      ),
                      const Text(
                        'Menghubungi server Midtrans...',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ] else if (hasSnapUrl) ...[
                      if (isQris)
                        Image.asset(
                          'assets/images/qris_sample.png',
                          width: 180,
                          height: 180,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.qr_code_2_rounded,
                            size: 180,
                            color: AppColors.textPrimary,
                          ),
                        )
                      else
                        const Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 72,
                          color: AppColors.primary,
                        ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton.icon(
                          onPressed: () => _openMidtransPage(snapUrl),
                          icon: const Icon(Icons.open_in_new_rounded, size: 18),
                          label: const Text(
                            'Buka Halaman Pembayaran Midtrans',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: snapUrl));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Link pembayaran Midtrans disalin!'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.copy_rounded, size: 16),
                        label: const Text('Salin Link Pembayaran'),
                      ),
                    ] else ...[
                      const Icon(
                        Icons.error_outline_rounded,
                        size: 56,
                        color: Colors.redAccent,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _cartController.lastErrorMessage ??
                            'Gagal memuat link Midtrans. Pastikan MIDTRANS_SERVER_KEY di file .env sudah benar.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),

        // 3. Panel Bawah: Simpan Kode QR, Konfirmasi Pembayaran, & Batalkan Pesanan
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
                if (isQris) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () {
                        PaymentDialogs.showQrSavedDialog(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Simpan Kode QR',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                // Tombol Konfirmasi Pembayaran (Mengecek status settlement ke Midtrans)
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: OutlinedButton(
                    onPressed: _isCheckingPayment
                        ? null
                        : () async {
                      setState(() {
                        _isCheckingPayment = true;
                      });
                      final success =
                      await _cartController.confirmPaymentSuccess();
                      if (!mounted) return;
                      setState(() {
                        _isCheckingPayment = false;
                      });

                      if (success && context.mounted) {
                        _countdownTimer?.cancel();
                        await PaymentDialogs.showPaymentSuccessDialog(
                          context,
                        );
                        if (context.mounted) {
                          MainScreen.goToTab(
                            context,
                            MainScreen.ordersTab,
                          );
                        }
                      } else if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              _cartController.lastErrorMessage ??
                                  'Pembayaran belum terverifikasi lunas.',
                            ),
                          ),
                        );
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
                    child: _isCheckingPayment
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Text(
                      'Konfirmasi Pembayaran',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Tombol Batalkan Pesanan
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