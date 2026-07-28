import '../../auth/repositories/auth_repository.dart';
import '../services/auth_service.dart';

class AuthController {
  AuthController();

  final AuthRepository _repository = AuthRepository();

  /// Apakah user sudah login
  bool get isLoggedIn => AuthService.currentUser != null;

  /// ID user yang sedang login
  String? get userId => AuthService.currentUser?.id;

  /// Email user yang sedang login
  String? get email => AuthService.currentUser?.email;

  /// Mengecek apakah profil sudah dibuat
  Future<bool> profileExists() async {
    final id = userId;

    if (id == null) {
      return false;
    }

    return await _repository.profileExists(id);
  }

  /// Logout
  Future<void> logout() async {
    await AuthService.signOut();
  }
}