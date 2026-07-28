import '../../../core/config/supabase_config.dart';
import '../../auth/services/auth_service.dart';

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
    required String fakultas,
    required String programStudi,
  }) async {
    final user = AuthService.currentUser;

    if (user == null) {
      throw Exception('User belum login');
    }

    final avatarUrl = user.userMetadata?['avatar_url'];

    await _client.from('profiles').upsert({
      'id': user.id,
      'email': user.email,
      'nama': nama,
      'nim': nim,
      'campus_id': campusId,
      'fakultas': fakultas,
      'program_studi': programStudi,
      'foto_profil': avatarUrl,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}