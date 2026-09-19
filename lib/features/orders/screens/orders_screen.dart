import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../widgets/order_card.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  // Dummy data untuk Beli
  final List<OrderModel> dummyBeli = [
    OrderModel(
      id: '1',
      productName: 'Kemeja Putih',
      shopName: 'FilkomShop',
      counterpartName: '',
      description: 'Dijual Kemeja Putih harga merakyat',
      price: 49900,
      imageUrl: 'https://via.placeholder.com/150',
      status: OrderStatus.selesai,
      type: OrderType.beli,
    ),
  ];

  // Dummy data untuk Jual
  final List<OrderModel> dummyJual = [
    OrderModel(
      id: '2',
      productName: 'Buku Pemrograman Dasar',
      shopName: 'Toko Saya',
      counterpartName: 'Andi',
      description: 'Buku kondisi 90% mulus',
      price: 35000,
      imageUrl: 'https://via.placeholder.com/150',
      status: OrderStatus.dibayar,
      type: OrderType.jual,
    ),
  ];

  final List<OrderModel> dummySewa = [
    OrderModel(
      id: '2',
      productName: 'Buku Pemrograman Dasar',
      shopName: 'Toko Saya',
      counterpartName: 'Miko',
      description: 'Buku kondisi 90% mulus',
      price: 35000,
      imageUrl: 'https://via.placeholder.com/150',
      status: OrderStatus.dibuat,
      type: OrderType.sewa,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    const Color lightMaroon = Color(0xFFF5EAEB);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: lightMaroon,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          titleSpacing: 0,
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: lightMaroon,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 16),
            ),
            onPressed: () {
              // Navigasi kembali
            },
          ),
          title: const Text(
            'Pesanan Saya',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          bottom: const TabBar(
            labelColor: Color(0xFF9E2A2B),
            unselectedLabelColor: Colors.black54,
            indicatorColor: Color(0xFF9E2A2B),
            indicatorWeight: 4,
            tabs: [
              Tab(text: 'Beli'),
              Tab(text: 'Jual'),
              Tab(text: 'Sewa'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab Beli
            _buildOrderList(dummyBeli),
            // Tab Jual
            _buildOrderList(dummyJual),
            // Tab Sewa
            _buildOrderList(dummySewa),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderList(List<OrderModel> orders) {
    if (orders.isEmpty) {
      return const Center(
        child: Text('Belum ada pesanan'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return OrderCard(order: orders[index]);
      },
    );
  }
}