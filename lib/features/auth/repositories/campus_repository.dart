import '../../../core/config/supabase_config.dart';
import '../models/campus.dart';

class CampusRepository {
  CampusRepository._();

  static final _client = SupabaseConfig.client;

  /// Mencari data kampus berdasarkan email user
  static Future<Campus?> getCampusByEmail(String email) async {
    try {
      if (!email.contains('@')) {
        print("Email tidak valid: $email");
        return null;
      }

      final domain = email.split('@').last.toLowerCase();

      print("========== CAMPUS REPOSITORY ==========");
      print("Email  : $email");
      print("Domain : $domain");

      final result = await _client
          .from('campuses')
          .select()
          .eq('domain', domain)
          .maybeSingle();

      print("Query Result : $result");

      if (result == null) {
        print("Campus tidak ditemukan.");
        return null;
      }

      final campus = Campus.fromJson(result);

      print("===== CAMPUS DITEMUKAN =====");
      print("ID     : ${campus.id}");
      print("Nama   : ${campus.name}");
      print("Domain : ${campus.domain}");

      return campus;
    } catch (e, stackTrace) {
      print("========== CAMPUS ERROR ==========");
      print(e);
      print(stackTrace);

      rethrow;
    }
  }

  /// Mengecek apakah email berasal dari kampus yang terdaftar
  static Future<bool> isCampusEmail(String email) async {
    final campus = await getCampusByEmail(email);
    return campus != null;
  }

  /// Mengambil semua data kampus
  static Future<List<Campus>> getAllCampuses() async {
    try {
      final response = await _client
          .from('campuses')
          .select()
          .order('name');

      return (response as List)
          .map((e) => Campus.fromJson(e))
          .toList();
    } catch (e, stackTrace) {
      print("========== GET ALL CAMPUS ERROR ==========");
      print(e);
      print(stackTrace);

      rethrow;
    }
  }
}