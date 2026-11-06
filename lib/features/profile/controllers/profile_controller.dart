import '../../auth/services/auth_service.dart';
import '../repository/profile_repository.dart';

class ProfileController {
  ProfileController();

  final ProfileRepository _repository = ProfileRepository();

  Future<Map<String, dynamic>?> getProfile() async {
    final user = AuthService.currentUser;

    if (user == null) {
      throw Exception('Pengguna belum login.');
    }

    return _repository.getProfile();
  }

  Future<void> saveProfile({
    required String nama,
    required String nim,
    required int campusId,
    required String campusName,
    required String fakultas,
    required String programStudi,
  }) async {
    final user = AuthService.currentUser;

    if (user == null) {
      throw Exception('Sesi login tidak ditemukan.');
    }

    if (nama.trim().isEmpty ||
        nim.trim().isEmpty ||
        campusName.trim().isEmpty ||
        fakultas.trim().isEmpty ||
        programStudi.trim().isEmpty) {
      throw Exception('Semua data wajib diisi.');
    }

    if (campusId <= 0) {
      throw Exception('Data kampus tidak valid.');
    }

    await _repository.saveProfile(
      nama: nama.trim(),
      nim: nim.trim(),
      campusId: campusId,
      campusName: campusName.trim(),
      fakultas: fakultas.trim(),
      programStudi: programStudi.trim(),
    );
  }
}