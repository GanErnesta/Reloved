import '../../../core/config/supabase_config.dart';

class AuthRepository {
  AuthRepository();

  static final _client = SupabaseConfig.client;

  Future<bool> profileExists(String userId) async {
    final result = await _client
        .from('profiles')
        .select('id')
        .eq('id', userId)
        .maybeSingle();

    return result != null;
  }
}