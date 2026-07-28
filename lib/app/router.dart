import 'package:go_router/go_router.dart';

import '../app/screens/splashscreen.dart';
import '../app/navigation/main_screen.dart';

import '../features/onboarding/screens/onboarding_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/auth/screens/create_password_screen.dart';
import '../features/auth/screens/verify_otp_screen.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/auth/screens/reset_password_screen.dart';

import '../features/profile/screens/profile_setup_screen.dart';
import '../features/profile/screens/profile_screen.dart';

final router = GoRouter(
  initialLocation: '/',

  routes: [
    /// Splash
    GoRoute(path: '/', builder: (_, __) => const SplashScreen()),

    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),

    /// Login
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),

    /// Register
    GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),

    /// Create Password
    GoRoute(
      path: '/create-password',
      builder: (context, state) => const CreatePasswordScreen(),
    ),

    /// Verify Email / OTP
    GoRoute(
      path: '/verify-email',
      builder: (context, state) {
        final email = state.extra as String;

        return VerifyOtpScreen(email: email);
      },
    ),

    /// Forgot Password
    GoRoute(
      path: '/forgot-password',
      builder: (_, __) => const ForgotPasswordScreen(),
    ),

    /// Reset Password
    GoRoute(
      path: '/reset-password',
      builder: (_, __) => const ResetPasswordScreen(),
    ),

    /// Setup Profile
    GoRoute(
      path: '/setup-profile',
      builder: (context, state) => const ProfileSetupScreen(),
    ),

    /// Home
    GoRoute(path: '/home', builder: (_, __) => const MainScreen()),

    /// Profile
    GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
  ],
);
