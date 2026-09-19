import 'package:flutter/material.dart';

class OrderLocationBox extends StatelessWidget {
  const OrderLocationBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLocationItem(
            color: const Color(0xFFF2A63B),
            title: 'Diambil dari',
            address: 'Area Ketawanggede, Kecamatan Lowokwaru, Kota Malang, Provinsi Jawa Timur.',
            showArrow: true,
          ),
          const SizedBox(height: 20),
          _buildLocationItem(
            color: const Color(0xFF4CAF50),
            title: 'Diantar ke',
            address: 'Gedung Perpustakaan, Jl. Veteran, Ketawanggede, Kec. Lowokwaru, Kota Malang, Jawa Timur 65145',
            subtitle: 'falishakeyrani - falishakeyrani@student.ub.ac.id',
            showArrow: false,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationItem({
    required Color color,
    required String title,
    required String address,
    String? subtitle,
    required bool showArrow,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4),
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              Text(address, style: const TextStyle(fontSize: 12, color: Colors.black87, height: 1.4)),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.black54)),
              ],
            ],
          ),
        ),
        if (showArrow) const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
      ],
    );
  }
}