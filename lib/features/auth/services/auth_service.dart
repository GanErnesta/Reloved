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

  /// Mengirim OTP sekaligus menyertakan data pendaftaran
  static Future<void> sendOtp(
    String email, {
    required Map<String, dynamic> userData,
  }) async {
    try {
      await _client.auth.signInWithOtp(email: email, data: userData);

      debugPrint('OTP berhasil dikirim ke $email');
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Verifikasi OTP
  static Future<User> verifyOtp({
    required String email,
    required String otp,
    required Map<String, dynamic> userData,
  }) async {
    try {
      final response = await _client.auth.verifyOTP(
        email: email,
        token: otp,
        type: OtpType.email,
      );

      final user = response.user;

      if (user == null) {
        throw Exception('Verifikasi OTP gagal.');
      }

      // Perbarui metadata secara eksplisit setelah OTP terverifikasi.
      final updateResponse = await _client.auth.updateUser(
        UserAttributes(data: userData),
      );

      final updatedUser = updateResponse.user;

      if (updatedUser == null) {
        throw Exception('Gagal menyimpan data pendaftaran.');
      }

      debugPrint('OTP VERIFIED: ${updatedUser.email}');
      debugPrint('UPDATED METADATA: ${updatedUser.userMetadata}');

      return updatedUser;
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Menyimpan password akun setelah OTP berhasil
  static Future<void> setPassword(String password) async {
    try {
      if (_client.auth.currentUser == null) {
        throw Exception('User belum terverifikasi.');
      }

      await _client.auth.updateUser(UserAttributes(password: password));

      debugPrint('Password berhasil dibuat.');
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Mengirim ulang OTP
  static Future<void> resendOtp(String email) async {
    try {
      await _client.auth.resend(type: OtpType.signup, email: email);

      debugPrint('OTP berhasil dikirim ulang ke $email');
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

  /// Validasi domain berdasarkan daftar domain yang sudah ditentukan.
  /// Untuk proses registrasi, gunakan CampusRepository agar domain
  /// diperiksa langsung ke tabel campuses.
  static bool isCampusEmail(String? email) {
    if (email == null || !email.contains('@')) {
      return false;
    }

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
