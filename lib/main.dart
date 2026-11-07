
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'app/router.dart';
import 'core/config/supabase_config.dart';
import 'features/chat/services/chat_service.dart';
import 'features/notification/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');
  await SupabaseConfig.initialize();

  await NotificationService.initialize(
    onNotificationTap: (conversationId) async {
      final details = await ChatService()
          .fetchConversationDetails(conversationId);

      if (details == null) return;

      router.push(
        '/chat/$conversationId',
        extra: details,
      );
    },
  );

  final supabase = Supabase.instance.client;

  if (supabase.auth.currentUser != null) {
    await NotificationService.startListening();
  }

  supabase.auth.onAuthStateChange.listen((data) {
    debugPrint('===== AUTH EVENT =====');
    debugPrint(data.event.toString());
    debugPrint(data.session?.user.email);

    if (data.event == AuthChangeEvent.signedOut) {
      NotificationService.stopListening();
    } else if (data.session != null) {
      NotificationService.startListening();
    }
  });

  runApp(const App());
}
