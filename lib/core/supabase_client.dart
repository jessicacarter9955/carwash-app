import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:washgo/core/constants.dart';

Future<void> initSupabase() async {
  await Supabase.initialize(url: kSupabaseUrl, anonKey: kSupabaseAnonKey);
}

// Main client (uses RLS)
final supabase = Supabase.instance.client;

// Admin client (bypasses RLS)
final supabaseAdmin = kSupabaseServiceRoleKey.isNotEmpty
    ? SupabaseClient(kSupabaseUrl, kSupabaseServiceRoleKey)
    : supabase;
