import 'package:flutter/material.dart';

import '../../features/home/screens/home_screen.dart';
import '../../features/chat/screens/chat_screen.dart';
import '../../features/orders/screens/orders_screen.dart';
import '../../features/profile/screens/profile_screen.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({super.key, this.initialIndex = 0});

  static const int homeTab = 0;
  static const int chatTab = 1;
  static const int ordersTab = 2;
  static const int profileTab = 3;

  /// Tab yang sedang aktif. Mengubah nilai ini akan memindahkan tab.
  static final ValueNotifier<int> tabIndex = ValueNotifier<int>(homeTab);

  /// Route milik MainScreen yang sedang aktif (dipakai untuk popUntil).
  static ModalRoute<dynamic>? _route;

  /// Kembali ke MainScreen (menutup semua layar di atasnya, mis. Cart,
  /// Checkout, Payment) lalu membuka tab [index].
  ///
  /// Contoh: MainScreen.goToTab(context, MainScreen.ordersTab);
  static void goToTab(BuildContext context, int index) {
    final navigator = Navigator.of(context);
    final route = _route;

    if (route != null && route.isActive) {
      navigator.popUntil((r) => r == route);
      tabIndex.value = index;
    } else {
      // Cadangan: MainScreen belum/tidak aktif, buat baru dan bersihkan stack.
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => MainScreen(initialIndex: index)),
            (route) => false,
      );
    }
  }

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int currentIndex;
  ModalRoute<dynamic>? _myRoute;

  final List<Widget> pages = const [
    HomeScreen(),
    ChatScreen(),
    OrdersScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    MainScreen.tabIndex.value = currentIndex;
    MainScreen.tabIndex.addListener(_onTabRequested);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _myRoute = ModalRoute.of(context);
    MainScreen._route = _myRoute;
  }

  @override
  void dispose() {
    MainScreen.tabIndex.removeListener(_onTabRequested);
    if (MainScreen._route == _myRoute) {
      MainScreen._route = null;
    }
    super.dispose();
  }

  void _onTabRequested() {
    if (!mounted) return;

    final requested = MainScreen.tabIndex.value;
    if (requested != currentIndex) {
      setState(() {
        currentIndex = requested;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: currentIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_bag_outlined),
            selectedIcon: Icon(Icons.shopping_bag),
            label: 'Order',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onDestinationSelected: (index) {
          MainScreen.tabIndex.value = index;
        },
      ),
    );
  }
}