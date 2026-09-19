import 'package:flutter/material.dart';
// Pastikan path import ini sesuai dengan letak folder Anda
import 'features/orders/screens/orders_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Menghilangkan banner debug
      title: 'Reloved App',
      home: const OrdersScreen(), // Memanggil halaman pesanan
    );
  }
}