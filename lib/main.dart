import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants.dart';
import 'core/router.dart';
import 'providers/notification_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  await dotenv.load(fileName: ".env");

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  await Supabase.initialize(url: kSupabaseUrl, anonKey: kSupabaseAnonKey);

  try {
    await Firebase.initializeApp();
    await NotificationService.init();
  } catch (_) {}

  runApp(const ProviderScope(child: WashGoApp()));
}

class WashGoApp extends ConsumerWidget {
  const WashGoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    // Init notifications silently
    ref.watch(notificationProvider);
    ref.watch(fcmTokenProvider);

    return MaterialApp.router(
      title: 'WashGo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: kBg,
        colorScheme: ColorScheme.light(primary: kCyan, secondary: kMint),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
