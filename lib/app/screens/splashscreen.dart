import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_text_styles.dart';
import '../router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller;

  // 1. Animasi lingkaran merah pertama dari putih ke merah
  late final Animation<double> _redCircleAnimation;
  // 2. Animasi lingkaran putih kedua dari merah ke putih
  late final Animation<double> _whiteCircleAnimation;
  // 3. Animasi kemunculan logo dan teks "Reloved"
  late final Animation<double> _contentFadeAnimation;

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Tahap 1: Lingkaran merah membesar (0.0 - 0.35)
    _redCircleAnimation = Tween<double>(begin: 0.0, end: 40.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.35, curve: Curves.easeInOutCubic),
      ),
    );

    // Tahap 2: Lingkaran putih membesar di atas background merah (0.35 - 0.75)
    _whiteCircleAnimation = Tween<double>(begin: 0.0, end: 40.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.75, curve: Curves.easeInOutCubic),
      ),
    );

    // Tahap 3: Logo dan teks muncul bersamaan dengan membesarnya lingkaran putih (0.5 - 0.8)
    _contentFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.8, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
    _timer = Timer(const Duration(seconds: 4), _checkSession);
  }

  void _checkSession() {
    if (!mounted) return;

    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      router.go('/home');
    } else {
      router.go('/onboarding');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background awal putih bersih
      backgroundColor: Colors.white,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Lingkaran Merah yang membesar menutupi background putih
          AnimatedBuilder(
            animation: _redCircleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _redCircleAnimation.value,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          ),

          // 2. Lingkaran Putih kedua yang membesar menutupi background merah
          AnimatedBuilder(
            animation: _whiteCircleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _whiteCircleAnimation.value,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          ),

          // 3. Logo (Gambar) & Teks "Reloved" yang muncul di tengah
          FadeTransition(
            opacity: _contentFadeAnimation,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    child: Image.asset(
                      'assets/images/LogoReloved.png', // Ganti dengan path aset gambar kamu yang sesuai
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback jika path gambar belum ada/salah agar tidak error
                        return const Icon(
                          Icons.shopping_bag_outlined,
                          color: Colors.white,
                          size: 48,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Reloved',
                    style: AppTextStyles.heading.copyWith(
                      fontSize: 32,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Preloved Aman\nSekampus Nyaman',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 14,
                      height: 1.5,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
