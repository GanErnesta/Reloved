import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/app.dart';
import 'core/config/supabase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await SupabaseConfig.initialize();
  Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    debugPrint("===== AUTH EVENT =====");
    debugPrint(data.event.toString());
    debugPrint(data.session?.user.email);
  });
  runApp(const App());
}
