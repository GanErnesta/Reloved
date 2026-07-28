import '../repository/profile_repository.dart';

class ProfileController {
  ProfileController();

  final ProfileRepository _repository = ProfileRepository();

  Future<Map<String, dynamic>?> getProfile() async {
    return await _repository.getProfile();
  }

  Future<void> saveProfile({
    required String nama,
    required String nim,
    required int campusId,
    required String fakultas,
    required String programStudi,
  }) async {
    if (nama.trim().isEmpty ||
        nim.trim().isEmpty ||
        fakultas.trim().isEmpty ||
        programStudi.trim().isEmpty) {
      throw Exception('Semua data wajib diisi');
    }

    await _repository.saveProfile(
      nama: nama.trim(),
      nim: nim.trim(),
      campusId: campusId,
      fakultas: fakultas.trim(),
      programStudi: programStudi.trim(),
    );
  }
}