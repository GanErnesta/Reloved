import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/order_model.dart';
import '../widgets/order_status_timeline.dart';
import '../widgets/order_location_box.dart';

class OrderDetailScreen extends StatelessWidget {
  final OrderModel order;

  final Color lightMaroon = const Color(0xFFF5EAEB);

  const OrderDetailScreen({super.key, required this.order});

  String get _pageTitle {
    switch (order.type) {
      case OrderType.beli: return 'Detail Pesanan';
      case OrderType.jual: return 'Detail Barang';
      case OrderType.sewa: return 'Detail Sewa';
    }
  }

  String get _chatLabel {
    return order.type == OrderType.beli
        ? '${order.shopName} (Pengirim)'
        : '${order.counterpartName} (Pembeli)';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightMaroon,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: lightMaroon,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 16),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _pageTitle,
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            OrderStatusTimeline(order: order, chatLabel: _chatLabel),
            const SizedBox(height: 16),
            const OrderLocationBox(),
            const SizedBox(height: 16),
            _buildPaymentSummaryCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSummaryCard() { //gabung aja
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Rincian Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          _buildPaymentRow('Biaya Produk', currencyFormatter.format(order.price)),
          const SizedBox(height: 8),
          _buildPaymentRow('Ongkir', 'Rp 5.000'),
          const SizedBox(height: 8),
          _buildPaymentRow('Diskon', '- Rp 0', valueColor: const Color(0xFF4CAF50)),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(thickness: 1, color: Color(0xFFEEEEEE)),
          ),
          _buildPaymentRow('Total Biaya', currencyFormatter.format(order.price + 5000), isBold: true),
          const SizedBox(height: 16),
          _buildPaymentRow('Metode Pembayaran', 'QRIS', isBold: true),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(String title, String value, {bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: isBold ? Colors.black : Colors.black87,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: valueColor ?? Colors.black,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}