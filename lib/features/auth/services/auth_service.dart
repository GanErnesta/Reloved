import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/supabase_config.dart';

class AuthService {
  AuthService._();

  static final SupabaseClient _client = SupabaseConfig.client;

  /// User yang sedang login
  static User? get currentUser => _client.auth.currentUser;

  /// Stream perubahan auth
  static Stream<AuthState> get authStateChanges =>
      _client.auth.onAuthStateChange;

  /// ===========================
  /// KIRIM OTP KE EMAIL
  /// ===========================
  static Future<void> sendOtp(String email) async {
    try {
      await _client.auth.signInWithOtp(
        email: email,
      );

      debugPrint("OTP berhasil dikirim ke $email");
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// ===========================
  /// VERIFIKASI OTP
  /// ===========================
  static Future<void> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _client.auth.verifyOTP(
        email: email,
        token: otp,
        type: OtpType.email,
      );

      if (response.user == null) {
        throw Exception("Verifikasi OTP gagal.");
      }

      debugPrint(
        "Login berhasil : ${response.user!.email}",
      );
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Logout
  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Validasi email kampus
  static bool isCampusEmail(String? email) {
    if (email == null) return false;

    final domain = email.split('@').last.toLowerCase();

    const allowedDomains = [
      'student.ub.ac.id',
      'ub.ac.id',
      'ui.ac.id',
      'mail.ugm.ac.id',
      'itb.ac.id',
      'its.ac.id',
      'student.unair.ac.id',
      'students.undip.ac.id',
      'student.uns.ac.id',
    ];

    return allowedDomains.contains(domain);
  }
}