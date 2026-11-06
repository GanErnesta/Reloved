import '../../../core/config/supabase_config.dart';
import '../../auth/services/auth_service.dart';
import 'package:flutter/foundation.dart';

class ProfileRepository {
  ProfileRepository();

  static final _client = SupabaseConfig.client;

  /// Mengambil data profil beserta data kampus
  Future<Map<String, dynamic>?> getProfile() async {
    final user = AuthService.currentUser;

    if (user == null) {
      return null;
    }

    final result = await _client
        .from('profiles')
        .select('''
          *,
          campuses (
            id,
            name,
            short_name,
            domain,
            logo_url,
            city,
            province
          )
        ''')
        .eq('id', user.id)
        .maybeSingle();

    return result;
  }

  /// Menyimpan profil
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
    throw Exception('User belum login.');
  }

  try {
    await _client.from('profiles').upsert({
      'id': user.id,
      'email': user.email,
      'nama': nama,
      'nim': nim,
      'kampus': campusName,
      'campus_id': campusId,
      'fakultas': fakultas,
      'program_studi': programStudi,
      'foto_profil': user.userMetadata?['avatar_url'],
      'updated_at': DateTime.now().toIso8601String(),
    });

    debugPrint('PROFILE SAVED: ${user.id}');
  } catch (e) {
    debugPrint('PROFILE REPOSITORY ERROR: $e');
    rethrow;
  }
}

  Future<void> saveProfileFromMetadata() async {
    final user = AuthService.currentUser;

    if (user == null) {
      throw Exception('User belum login atau belum terverifikasi.');
    }

    final metadata = user.userMetadata ?? {};

    final nama = metadata['nama']?.toString() ?? '';
    final nim = metadata['nim']?.toString() ?? '';
    final fakultas = metadata['fakultas']?.toString() ?? '';
    final programStudi = metadata['program_studi']?.toString() ?? '';
    final campusId = metadata['campus_id'];

    if (nama.isEmpty ||
        nim.isEmpty ||
        fakultas.isEmpty ||
        programStudi.isEmpty ||
        campusId == null) {
      throw Exception('Data pendaftaran tidak lengkap.');
    }

    await _client.from('profiles').upsert({
      'id': user.id,
      'email': user.email,
      'nama': nama,
      'nim': nim,
      'kampus': metadata['kampus']?.toString(),
      'campus_id': campusId,
      'fakultas': fakultas,
      'program_studi': programStudi,
      'foto_profil': user.userMetadata?['avatar_url'],
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}

/// Menyimpan profil berdasarkan data pendaftaran
