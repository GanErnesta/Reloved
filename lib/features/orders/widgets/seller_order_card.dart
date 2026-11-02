import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/seller_order_model.dart';
import 'buyer_trust_score_badge.dart';
import 'seller_safe_meeting_pill.dart';

class SellerOrderCard extends StatelessWidget {
  final SellerOrderModel order;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onMarkSaleCompleted;
  final VoidCallback onVerifyRentalReturn;

  const SellerOrderCard({
    super.key,
    required this.order,
    required this.onAccept,
    required this.onReject,
    required this.onMarkSaleCompleted,
    required this.onVerifyRentalReturn,
  });

  String _formatRupiah(int amount) {
    final str = amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
    );
    return 'Rp $str';
  }

  // Menentukan skema warna kartu berdasarkan status
  _CardThemeColors get _theme {
    if (order.mode == SellerOrderMode.penjualan) {
      switch (order.saleStatus!) {
        case SellerSaleStatus.baru:
          return _CardThemeColors.amber(title: 'Pesanan Baru');
        case SellerSaleStatus.siapCod:
          return _CardThemeColors.blue(title: 'Siap COD / Kirim');
        case SellerSaleStatus.selesai:
          return _CardThemeColors.green(title: 'Selesai');
      }
    } else {
      switch (order.rentalStatus!) {
        case SellerRentalStatus.permintaan:
          return _CardThemeColors.amber(title: 'Permintaan');
        case SellerRentalStatus.aktif:
          return _CardThemeColors.blue(title: 'Masa Sewa Aktif');
        case SellerRentalStatus.kembali:
          return _CardThemeColors.green(title: 'Pengembalian');
        case SellerRentalStatus.selesai:
          return _CardThemeColors.green(title: 'Selesai');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = _theme;
    final bool isRental = order.mode == SellerOrderMode.penyewaan;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Status Berwarna
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              color: theme.headerBgColor,
              child: Text(
                theme.title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: theme.headerTextColor,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Kode Transaksi & Waktu Relatif
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        order.transactionCode,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF666666),
                        ),
                      ),
                      Text(
                        order.relativeTimeText,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 3. Profil Pembeli + Campus Trust Score Badge + Nama Kampus
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 21,
                        backgroundColor: AppColors.primaryLight,
                        backgroundImage: AssetImage(order.buyerAvatarPath),
                        onBackgroundImageError: (_, __) {},
                        child: Text(
                          order.buyerName[0].toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    order.buyerName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1A253A),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                BuyerTrustScoreBadge(
                                  score: order.buyerTrustScore,
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              order.buyerCampus,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF666666),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 4. Kotak Informasi Produk
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.innerBoxBgColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 60,
                            height: 60,
                            color: Colors.white,
                            child: Image.asset(
                              order.productImagePath,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.inventory_2_outlined,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: isRental
                              ? _buildRentalProductDetails()
                              : _buildSaleProductDetails(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 5. Kotak Total Pembayaran / Total Sewa & Metode Pembayaran
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: theme.innerBoxBgColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isRental &&
                                  order.rentalStatus !=
                                      SellerRentalStatus.kembali
                                  ? 'Total Sewa'
                                  : 'Total Pembayaran',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatRupiah(order.totalPayment),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Metode Pembayaran',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              order.paymentMethod,
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
                  const SizedBox(height: 12),

                  // 6. Pill Waktu Terima Sebelum (Khusus Status Baru / Permintaan)
                  if (order.isPendingAction &&
                      order.acceptDeadlineText != null) ...[
                    _buildTimerPill(
                      text: 'Terima sebelum: ${order.acceptDeadlineText}',
                      bgColor: const Color(0xFFF6EFE2),
                      borderColor: const Color(0xFF7D6B57),
                      textColor: const Color(0xFF94621F),
                    ),
                    const SizedBox(height: 8),
                  ],

                  // 7. Pill Sisa Waktu Sewa (Khusus Status Masa Sewa Aktif)
                  if (isRental &&
                      order.rentalStatus == SellerRentalStatus.aktif &&
                      order.remainingRentalTimeText != null) ...[
                    _buildTimerPill(
                      text: 'Sisa Sewa: ${order.remainingRentalTimeText}',
                      bgColor: const Color(0xFFF9ECEE),
                      borderColor: AppColors.primary,
                      textColor: AppColors.primary,
                    ),
                    const SizedBox(height: 8),
                  ],

                  // 8. Pill Lokasi Safe Meeting Point (Seragam untuk Penjualan & Penyewaan, tanpa COD/Kurir)
                  SellerSafeMeetingPill(
                    meetingPointName: order.safeMeetingPoint.name,
                  ),

                  // 9. Tombol Aksi Sesuai Status
                  _buildActionButtons(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaleProductDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Qty: ${order.quantity} · ${_formatRupiah(order.unitPrice)}/pcs',
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF4A4A4A),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          order.productName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildRentalProductDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          order.productName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          '${_formatRupiah(order.unitPrice)}/hari · ${order.rentalDays ?? 1} hari',
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF4A4A4A),
          ),
        ),
        if (order.depositAmount != null) ...[
          const SizedBox(height: 3),
          Text(
            'Deposit: ${_formatRupiah(order.depositAmount!)}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF28559A),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTimerPill({
    required String text,
    required Color bgColor,
    required Color borderColor,
    required Color textColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        children: [
          Icon(
            Icons.access_time_rounded,
            size: 16,
            color: textColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    // Aksi untuk Pesanan Baru (Penjualan) atau Permintaan (Penyewaan): Tolak & Terima
    if (order.isPendingAction) {
      return Padding(
        padding: const EdgeInsets.only(top: 14),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 44,
                child: OutlinedButton(
                  onPressed: onReject,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(
                      color: AppColors.primary,
                      width: 1.4,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Tolak',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Terima',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Aksi untuk Siap COD (Penjualan): Tandai Selesai
    if (order.mode == SellerOrderMode.penjualan &&
        order.saleStatus == SellerSaleStatus.siapCod) {
      return Padding(
        padding: const EdgeInsets.only(top: 14),
        child: SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton(
            onPressed: onMarkSaleCompleted,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Tandai Selesai',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      );
    }

    // Aksi untuk Pengembalian (Penyewaan): Verifikasi Pengembalian
    if (order.mode == SellerOrderMode.penyewaan &&
        order.rentalStatus == SellerRentalStatus.kembali) {
      return Padding(
        padding: const EdgeInsets.only(top: 14),
        child: SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton(
            onPressed: onVerifyRentalReturn,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Verifikasi Pengembalian',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

class _CardThemeColors {
  final String title;
  final Color headerBgColor;
  final Color headerTextColor;
  final Color borderColor;
  final Color innerBoxBgColor;

  const _CardThemeColors({
    required this.title,
    required this.headerBgColor,
    required this.headerTextColor,
    required this.borderColor,
    required this.innerBoxBgColor,
  });

  factory _CardThemeColors.amber({required String title}) {
    return _CardThemeColors(
      title: title,
      headerBgColor: const Color(0xFFF5E3C3),
      headerTextColor: const Color(0xFF94621F),
      borderColor: const Color(0xFFE3C896),
      innerBoxBgColor: const Color(0xFFFAF5EC),
    );
  }

  factory _CardThemeColors.blue({required String title}) {
    return _CardThemeColors(
      title: title,
      headerBgColor: const Color(0xFFDCE5F5),
      headerTextColor: const Color(0xFF28559A),
      borderColor: const Color(0xFFBCCCE8),
      innerBoxBgColor: const Color(0xFFEEF3FA),
    );
  }

  factory _CardThemeColors.green({required String title}) {
    return _CardThemeColors(
      title: title,
      headerBgColor: const Color(0xFFE1F3E4),
      headerTextColor: const Color(0xFF2E7D47),
      borderColor: const Color(0xFFBFE3C6),
      innerBoxBgColor: const Color(0xFFEEF7F0),
    );
  }
}