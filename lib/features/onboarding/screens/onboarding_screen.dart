
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../pages/onboarding_page1.dart';
import '../pages/onboarding_page2.dart';
import '../pages/onboarding_page3.dart';
import '../widgets/page_indicator.dart';
import '../widgets/next_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();

  double currentPage = 0;

  @override
  void initState() {
    super.initState();

    _controller.addListener(() {
      if (!mounted) return;

      setState(() {
        currentPage = _controller.page ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void nextPage() {
    if (currentPage.round() == 2) {
      context.go('/login');
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void skipOnboarding() {
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            children: const [
              OnboardingPage1(),
              OnboardingPage2(),
              OnboardingPage3(),
            ],
          ),

          if (currentPage.round() < 2)
            Positioned(
              left: 28,
              bottom: 32,
              child: GestureDetector(
                onTap: skipOnboarding,
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

          Positioned(
            left: 28,
            bottom: 68,
            child: PageIndicator(
              controller: _controller,
            ),
          ),

          Positioned(
            right: 24,
            bottom: 26,
            child: NextButton(
              onTap: nextPage,
            ),
          ),
        ],
      ),
    );
  }
}
