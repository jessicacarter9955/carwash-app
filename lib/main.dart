import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/supabase_client.dart';
import 'state/app_state.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initSupabase();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const WashGoApp(),
    ),
  );
}
