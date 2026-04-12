import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:washgo/core/constants.dart';

Future<void> initSupabase() async {
  await Supabase.initialize(url: kSupabaseUrl, anonKey: kSupabaseAnonKey);
}

final supabase = Supabase.instance.client;

final supabaseAdmin = kSupabaseServiceRoleKey.isNotEmpty
    ? SupabaseClient(kSupabaseUrl, kSupabaseServiceRoleKey)
    : supabase;
