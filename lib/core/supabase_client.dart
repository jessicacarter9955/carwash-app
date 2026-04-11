import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:carwash_pro/core/constants.dart';

Future<void> initSupabase() async {
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnon);
}

SupabaseClient get sb => Supabase.instance.client;

// Service role client for bypassing RLS (temporary)
SupabaseClient get sbServiceRole =>
    SupabaseClient(supabaseUrl, supabaseServiceRole);
