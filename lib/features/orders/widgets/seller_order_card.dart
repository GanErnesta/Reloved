import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/smart_image.dart';
import '../models/seller_order_model.dart';
import 'buyer_trust_score_badge.dart';
import 'seller_safe_meeting_pill.dart';

class SellerOrderCard extends StatefulWidget {
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

  @override
  State<SellerOrderCard> createState() => _SellerOrderCardState();
}

class _SellerOrderCardState extends State<SellerOrderCard> {
  bool _isExpanded = false;

  SellerOrderModel get order => widget.order;

  String _formatRupiah(int amount) {
    final formatted = amount.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => '.',
    );

    return 'Rp $formatted';
  }

  _CardThemeColors get _theme {
    if (order.mode == SellerOrderMode.penjualan) {
      switch (order.saleStatus) {
        case SellerSaleStatus.baru:
          return _CardThemeColors.amber('Pesanan Baru');
        case SellerSaleStatus.siapCod:
          return _CardThemeColors.blue('Siap COD / Kirim');
        case SellerSaleStatus.selesai:
          return _CardThemeColors.green('Selesai');
        case null:
          return _CardThemeColors.amber('Pesanan');
      }
    }

    switch (order.rentalStatus) {
      case SellerRentalStatus.permintaan:
        return _CardThemeColors.amber('Permintaan Sewa');
      case SellerRentalStatus.aktif:
        return _CardThemeColors.blue('Masa Sewa Aktif');
      case SellerRentalStatus.kembali:
        return _CardThemeColors.green('Pengembalian');
      case SellerRentalStatus.selesai:
        return _CardThemeColors.green('Selesai');
      case null:
        return _CardThemeColors.amber('Pesanan Sewa');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = _theme;
    final isRental = order.mode == SellerOrderMode.penyewaan;
    final items = order.displayItems;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER STATUS
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 11,
              ),
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
                  // KODE TRANSAKSI
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          order.transactionCode,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF666666),
                            fontWeight: FontWeight.w500,
                          ),
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

                  const SizedBox(height: 16),

                  // PROFIL PEMBELI
                  Row(
                    children: [
                      _buildBuyerAvatar(),

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
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1A253A),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 7),

                                BuyerTrustScoreBadge(
                                  score: order.buyerTrustScore,
                                ),
                              ],
                            ),

                            const SizedBox(height: 4),

                            Text(
                              order.buyerCampus,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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

                  const SizedBox(height: 16),

                  // INFORMASI PRODUK (bisa lebih dari satu)
                  _buildProductsBox(theme, items, isRental),

                  const SizedBox(height: 12),

                  // TOTAL PEMBAYARAN
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: theme.innerBoxBgColor,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _totalLabel(isRental, items.length),
                                style: const TextStyle(
                                  fontSize: 12,
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
                        ),

                        const SizedBox(width: 8),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Metode Pembayaran',
                              style: TextStyle(
                                fontSize: 12,
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

                  // BATAS WAKTU PENERIMAAN
                  if (order.isPendingAction &&
                      order.acceptDeadlineText != null) ...[
                    _buildTimerPill(
                      text: 'Terima sebelum: ${order.acceptDeadlineText}',
                      bgColor: const Color(0xFFF6EFE2),
                      borderColor: const Color(0xFFE5C28C),
                      textColor: const Color(0xFF94621F),
                    ),
                    const SizedBox(height: 10),
                  ],

                  // SISA WAKTU SEWA
                  if (isRental &&
                      order.rentalStatus == SellerRentalStatus.aktif &&
                      order.remainingRentalTimeText != null) ...[
                    _buildTimerPill(
                      text: 'Sisa Sewa: ${order.remainingRentalTimeText}',
                      bgColor: const Color(0xFFF9ECEE),
                      borderColor: AppColors.primary,
                      textColor: AppColors.primary,
                    ),
                    const SizedBox(height: 10),
                  ],

                  // LOKASI PERTEMUAN
                  SellerSafeMeetingPill(
                    meetingPointName: order.safeMeetingPoint.name,
                  ),

                  // TOMBOL AKSI
                  _buildActionButtons(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _totalLabel(bool isRental, int itemCount) {
    final base = isRental ? 'Total Sewa' : 'Total Pembayaran';
    return itemCount > 1 ? '$base ($itemCount produk)' : base;
  }

  // ---------------------------------------------------------------------------
  // BAGIAN PRODUK (dropdown)
  // ---------------------------------------------------------------------------

  Widget _buildProductsBox(
      _CardThemeColors theme,
      List<SellerOrderItemModel> items,
      bool isRental,
      ) {
    final bool hasMultiple = items.length > 1;
    final List<SellerOrderItemModel> visibleItems =
    _isExpanded ? items : [items.first];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.innerBoxBgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        alignment: Alignment.topCenter,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < visibleItems.length; i++) ...[
              if (i > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Divider(
                    height: 1,
                    color: theme.borderColor.withValues(alpha: 0.7),
                  ),
                ),
              _buildItemRow(visibleItems[i], isRental),
            ],

            if (hasMultiple) ...[
              const SizedBox(height: 10),
              InkWell(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: theme.headerTextColor.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isExpanded
                            ? 'Sembunyikan'
                            : 'Lihat ${items.length - 1} produk lainnya',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: theme.headerTextColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: theme.headerTextColor,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(SellerOrderItemModel item, bool isRental) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildProductImage(item.imagePath),

        const SizedBox(width: 12),

        Expanded(
          child: isRental
              ? _buildRentalProductDetails(item)
              : _buildSaleProductDetails(item),
        ),
      ],
    );
  }

  Widget _buildBuyerAvatar() {
    final String initial =
    order.buyerName.isNotEmpty ? order.buyerName[0].toUpperCase() : '?';

    return ClipOval(
      child: SizedBox(
        width: 42,
        height: 42,
        child: SmartImage(
          source: order.buyerAvatarPath,
          width: 42,
          height: 42,
          fit: BoxFit.cover,
          placeholder: Text(
            initial,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage(String path) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 60,
        height: 60,
        color: Colors.white,
        child: SmartImage(
          source: path,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          placeholderIcon: Icons.inventory_2_outlined,
        ),
      ),
    );
  }

  Widget _buildSaleProductDetails(SellerOrderItemModel item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Qty: ${item.quantity} · ${_formatRupiah(item.unitPrice)}/pcs',
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF4A4A4A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          item.productName,
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

  Widget _buildRentalProductDetails(SellerOrderItemModel item) {
    final int days = item.rentalDays ?? order.rentalDays ?? 1;
    final int? deposit = item.depositAmount ?? order.depositAmount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.productName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${_formatRupiah(item.unitPrice)}/hari · $days hari'
              '${item.quantity > 1 ? ' · Qty ${item.quantity}' : ''}',
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF4A4A4A),
          ),
        ),
        if (deposit != null && deposit > 0) ...[
          const SizedBox(height: 4),
          Text(
            'Deposit: ${_formatRupiah(deposit)}',
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
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(
            Icons.access_time_rounded,
            size: 15,
            color: textColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 11,
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
    // PESANAN BARU / PERMINTAAN SEWA
    if (order.isPendingAction) {
      return Padding(
        padding: const EdgeInsets.only(top: 14),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 44,
                child: OutlinedButton(
                  onPressed: widget.onReject,
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
                  onPressed: widget.onAccept,
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

    // PENJUALAN SIAP COD
    if (order.mode == SellerOrderMode.penjualan &&
        order.saleStatus == SellerSaleStatus.siapCod) {
      return Padding(
        padding: const EdgeInsets.only(top: 14),
        child: SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton(
            onPressed: widget.onMarkSaleCompleted,
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
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      );
    }

    // PENGEMBALIAN SEWA
    if (order.mode == SellerOrderMode.penyewaan &&
        order.rentalStatus == SellerRentalStatus.kembali) {
      return Padding(
        padding: const EdgeInsets.only(top: 14),
        child: SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton(
            onPressed: widget.onVerifyRentalReturn,
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
    required this.borderColor,
    required this.headerTextColor,
    required this.innerBoxBgColor,
  });

  factory _CardThemeColors.amber(String title) {
    return _CardThemeColors(
      title: title,
      headerBgColor: const Color(0xFFF5E3C3),
      headerTextColor: const Color(0xFF94621F),
      borderColor: const Color(0xFFE3C896),
      innerBoxBgColor: const Color(0xFFFAF5EC),
    );
  }

  factory _CardThemeColors.blue(String title) {
    return _CardThemeColors(
      title: title,
      headerBgColor: const Color(0xFFDCE5F5),
      headerTextColor: const Color(0xFF28559A),
      borderColor: const Color(0xFFBCCCE8),
      innerBoxBgColor: const Color(0xFFEEF3FA),
    );
  }

  factory _CardThemeColors.green(String title) {
    return _CardThemeColors(
      title: title,
      headerBgColor: const Color(0xFFE1F3E4),
      headerTextColor: const Color(0xFF2E7D47),
      borderColor: const Color(0xFFBFE3C6),
      innerBoxBgColor: const Color(0xFFEEF7F0),
    );
  }
}