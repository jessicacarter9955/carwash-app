import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants.dart';
import 'core/router.dart';
import 'providers/notification_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  await Supabase.initialize(
    url: kSupabaseUrl,
    anonKey: kSupabaseAnonKey,
  );

  // Init Stripe
  Stripe.publishableKey =
      'pk_test_51QixK9LAyxeLVAm3oZ952K8CPWlnFdQPyRQ70Bq1m2zaUVXiy1CpJH8ZE5j4N09PYrPSnCKAVkaXzKoCpQlo19F600OWhYNFbm';
  Stripe.merchantIdentifier = 'merchant.com.example.washgo'; // iOS only
  Stripe.urlScheme = 'washgo'; // Deep link scheme
  await Stripe.instance.applySettings();

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
    ref.watch(notificationProvider);
    ref.watch(fcmTokenProvider);

    return MaterialApp.router(
      title: 'WashGo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: kBg,
        colorScheme: ColorScheme.light(
          primary: kCyan,
          secondary: kMint,
        ),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
