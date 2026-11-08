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

  static final ValueNotifier<int> tabIndex = ValueNotifier<int>(homeTab);

  static ModalRoute<dynamic>? _route;

  static void goToTab(BuildContext context, int index) {
    final navigator = Navigator.of(context);
    final route = _route;

    if (route != null && route.isActive) {
      navigator.popUntil((r) => r == route);
      tabIndex.value = index;
    } else {
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

  Widget _navIcon(String asset, {double size = 24}) {
    return Image.asset(asset, width: size, height: size, fit: BoxFit.contain);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: currentIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        destinations: [
          NavigationDestination(
            icon: _navIcon('assets/icons/home.png'),
            selectedIcon: _navIcon('assets/icons/home_active.png'),
            label: 'Home',
          ),
          NavigationDestination(
            icon: _navIcon('assets/icons/chat.png'),
            selectedIcon: _navIcon('assets/icons/chat_active.png'),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: _navIcon('assets/icons/order.png'),
            selectedIcon: _navIcon('assets/icons/order_active.png'),
            label: 'Order',
          ),
          NavigationDestination(
            icon: _navIcon('assets/icons/profile.png'),
            selectedIcon: _navIcon('assets/icons/profile_active.png'),
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
