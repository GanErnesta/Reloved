import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/config/supabase_config.dart';
import 'core/constants/app_colors.dart';
import 'features/cart/controllers/cart_controller.dart';
import 'features/cart/screens/cart_screen.dart';
import 'features/cart/screens/payment_waiting_screen.dart';
import 'features/orders/controllers/order_controller.dart';
import 'features/orders/screens/orders_screen.dart';
import 'features/orders/screens/seller_manage_orders_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Memuat file .env dan menyalakan koneksi SupabaseConfig
  await dotenv.load(fileName: '.env');
  await SupabaseConfig.initialize();

  runApp(const RelovedTestApp());
}

class RelovedTestApp extends StatelessWidget {
  const RelovedTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reloved Integration Tester',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
      ),
      home: const IntegrationTestHubScreen(),
    );
  }
}

class IntegrationTestHubScreen extends StatefulWidget {
  const IntegrationTestHubScreen({super.key});

  @override
  State<IntegrationTestHubScreen> createState() =>
      _IntegrationTestHubScreenState();
}

class _IntegrationTestHubScreenState extends State<IntegrationTestHubScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isBusy = false;
  String _statusLog = 'Siap melakukan pengetesan database Supabase.';

  void _setLog(String msg) {
    if (!mounted) return;
    setState(() {
      _statusLog = msg;
    });
  }

  /// Login cepat ke Supabase Auth
  Future<void> _handleQuickLogin() async {
    setState(() => _isBusy = true);
    try {
      await SupabaseConfig.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      await CartController.instance.loadCartFromSupabase();
      await OrderController.instance.loadBuyerOrders();
      _setLog('Berhasil login sebagai: ${SupabaseConfig.client.auth.currentUser?.email}');
    } catch (e) {
      _setLog('Gagal Login: $e');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  /// Fungsi Seeder Otomatis: Mengisi data Cart, Order Buyer, dan Order Seller ke Supabase untuk akun yang sedang login!
  Future<void> _seedDatabaseForCurrentUser() async {
    final user = SupabaseConfig.client.auth.currentUser;
    if (user == null) {
      _setLog('Harap login terlebih dahulu sebelum menekan tombol Seeder!');
      return;
    }

    setState(() => _isBusy = true);
    final supabase = SupabaseConfig.client;

    try {
      _setLog('1/5 Memastikan profil user tersedia di tabel profiles...');
      await supabase.from('profiles').upsert({
        'id': user.id,
        'email': user.email ?? 'mahasiswa@student.ub.ac.id',
        'nama': 'Johanes Farrell (Tester)',
        'kampus': 'Universitas Brawijaya',
        'trust_score': 95,
        'city': 'Malang',
        'address': 'Jl. Ikan Arwana, Tunjungsekar, Kota Malang',
      });

      _setLog('2/5 Memastikan kategori & Safe Meeting Point tersedia...');
      final catRes = await supabase
          .from('categories')
          .select()
          .limit(1)
          .maybeSingle();

      final String categoryId;
      if (catRes != null) {
        categoryId = catRes['id'].toString();
      } else {
        final newCat = await supabase
            .from('categories')
            .insert({'name': 'Pakaian & Perlengkapan Kuliah'})
            .select()
            .single();
        categoryId = newCat['id'].toString();
      }

      var smpRes = await supabase
          .from('safe_meeting_points')
          .select()
          .limit(1)
          .maybeSingle();
      smpRes ??= await supabase
          .from('safe_meeting_points')
          .insert({
        'name': 'Lobby Utama Gedung F Filkom UB',
        'full_address': 'Gedung F FILKOM UB, Jl. Veteran, Malang',
        'image_url': 'assets/images/smp_filkom.png',
      })
          .select()
          .single();
      final String smpId = smpRes['id'].toString();

      _setLog('3/5 Membuat produk testing (Beli & Sewa) di tabel products...');
      final prodBeli = await supabase
          .from('products')
          .insert({
        'seller_id': user.id,
        'category_id': categoryId,
        'name': 'Buku Algoritma & Struktur Data Java',
        'price': 85000,
        'condition': 'Sangat Baik',
        'variant': 'Edisi Ke-3',
        'stock': 10,
        'transaction_type': 'sale',
        'image_url': 'assets/images/buku_algoritma.png',
      })
          .select()
          .single();

      final prodSewa = await supabase
          .from('products')
          .insert({
        'seller_id': user.id,
        'category_id': categoryId,
        'name': 'Jas Laboratorium Kimia / Praktikum UB',
        'price': 30000,
        'rental_price': 30000,
        'rental_period': 'daily',
        'deposit_amount': 100000,
        'condition': 'Seperti Baru',
        'variant': 'Putih, Size L',
        'stock': 5,
        'transaction_type': 'rent',
        'image_url': 'assets/images/kemeja_putih.png',
      })
          .select()
          .single();

      _setLog('4/5 Memasukkan item ke tabel cart_items...');
      await supabase.from('cart_items').insert([
        {
          'user_id': user.id,
          'product_id': prodBeli['id'],
          'quantity': 1,
          'transaction_type': 'sale',
          'is_selected': true,
        },
        {
          'user_id': user.id,
          'product_id': prodSewa['id'],
          'quantity': 1,
          'transaction_type': 'rent',
          'rental_duration': 3,
          'rental_period': 'daily',
          'is_selected': true,
        },
      ]);

      _setLog('5/5 Membuat sampel pesanan di tabel orders & order_items...');
      final codeSuffix = DateTime.now().millisecondsSinceEpoch.toString().substring(7);

      // Order 1: Penjualan (Status Baru / Menunggu)
      final orderSale = await supabase
          .from('orders')
          .insert({
        'transaction_code': 'TRX-2026-$codeSuffix',
        'buyer_id': user.id,
        'seller_id': user.id,
        'order_type': 'beli',
        'buyer_status': 'menunggu',
        'seller_status': 'baru',
        'pickup_address': 'Area Ketawanggede, Kec. Lowokwaru, Malang',
        'safe_meeting_point_id': smpId,
        'product_subtotal': 85000,
        'shipping_fee': 5000,
        'grand_total': 90000,
        'payment_method': 'QRIS',
      })
          .select()
          .single();

      await supabase.from('order_items').insert({
        'order_id': orderSale['id'],
        'product_id': prodBeli['id'],
        'product_name_snapshot': prodBeli['name'],
        'product_image_snapshot': prodBeli['image_url'],
        'variant_snapshot': prodBeli['variant'],
        'quantity': 1,
        'unit_price': 85000,
        'subtotal': 85000,
      });

      // Order 2: Penyewaan (Status Permintaan / Menunggu)
      final orderRent = await supabase
          .from('orders')
          .insert({
        'transaction_code': 'SEW-2026-$codeSuffix',
        'buyer_id': user.id,
        'seller_id': user.id,
        'order_type': 'sewa',
        'buyer_status': 'menunggu',
        'seller_status': 'permintaan',
        'pickup_address': 'Area Ketawanggede, Kec. Lowokwaru, Malang',
        'safe_meeting_point_id': smpId,
        'product_subtotal': 90000,
        'shipping_fee': 5000,
        'deposit_total': 100000,
        'grand_total': 95000,
        'payment_method': 'Gopay',
        'rental_duration_days': 3,
        'rental_end_at': DateTime.now().add(const Duration(days: 3)).toIso8601String(),
      })
          .select()
          .single();

      await supabase.from('order_items').insert({
        'order_id': orderRent['id'],
        'product_id': prodSewa['id'],
        'product_name_snapshot': prodSewa['name'],
        'product_image_snapshot': prodSewa['image_url'],
        'variant_snapshot': prodSewa['variant'],
        'quantity': 1,
        'unit_price': 30000,
        'rental_duration_days': 3,
        'deposit_amount': 100000,
        'subtotal': 90000,
      });

      await CartController.instance.loadCartFromSupabase();
      await OrderController.instance.loadBuyerOrders();

      _setLog(
        'BERHASIL! Data produk, keranjang, pesanan buyer & seller telah masuk ke Supabase. Silakan buka masing-masing layar di bawah.',
      );
    } catch (e) {
      _setLog('Gagal Seeding Database: $e');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = SupabaseConfig.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text(
          'Reloved - Supabase Testing Hub',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Kotak Status User & Log
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentUser != null
                        ? 'Status Auth: LOGIN (${currentUser.email})'
                        : 'Status Auth: BELUM LOGIN',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: currentUser != null
                          ? AppColors.statusSuccess
                          : Colors.red.shade700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'User UUID: ${currentUser?.id ?? "-"}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const Divider(height: 20),
                  Text(
                    'Log: $_statusLog',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Form Login Cepat jika belum login
            if (currentUser == null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Login Akun Supabase Anda',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email Mahasiswa (.ac.id)',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _isBusy ? null : _handleQuickLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Login ke Supabase'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Tombol Seeder Otomatis ke Supabase
            ElevatedButton.icon(
              onPressed: _isBusy ? null : _seedDatabaseForCurrentUser,
              icon: _isBusy
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Icon(Icons.cloud_upload_rounded),
              label: const Text(
                '1. Isi Data Testing Otomatis ke Supabase (Seeder)',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Pilih Layar untuk Diuji:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),

            // 1. Layar Keranjang & Checkout
            _buildNavButton(
              icon: Icons.shopping_cart_outlined,
              title: 'Buka Layar Keranjang (Cart -> Checkout -> Payment)',
              subtitle: 'Uji tab Semua/Beli/Sewa, durasi 1h/3h/7h, Safe Meeting Point & Stuck Payment',
              onTap: () {
                CartController.instance.loadCartFromSupabase();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                );
              },
            ),

            // 2. Layar Pesanan Saya (Buyer)
            _buildNavButton(
              icon: Icons.receipt_long_outlined,
              title: 'Buka Layar Pesanan Saya (Buyer)',
              subtitle: 'Uji tab Beli & Sewa, Detail Pesanan, Ubah Safe Meeting Point & Batalkan',
              onTap: () {
                OrderController.instance.loadBuyerOrders();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const OrdersScreen()),
                );
              },
            ),

            // 3. Layar Kelola Pesanan (Seller)
            _buildNavButton(
              icon: Icons.storefront_outlined,
              title: 'Buka Layar Kelola Pesanan (Seller)',
              subtitle: 'Uji Mode Penjualan & Penyewaan, tanda seru (!), Terima/Tolak/Selesai',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SellerManageOrdersScreen(),
                  ),
                );
              },
            ),

            // 4. Layar Stuck Pembayaran (Jika ada sesi aktif)
            _buildNavButton(
              icon: Icons.qr_code_scanner_rounded,
              title: 'Buka Layar Pembayaran Tertahan (Stuck Screen)',
              subtitle: 'Melihat layar hitung mundur 30:00 apabila ada sesi pending',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PaymentWaitingScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryLight,
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitle, style: const TextStyle(fontSize: 12)),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}