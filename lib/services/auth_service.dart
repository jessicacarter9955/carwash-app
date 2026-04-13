import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/supabase_client.dart';
import '../models/user_profile.dart';

class AuthService {
  // ── Real login ──────────────────────────────────────
  static Future<AuthResponse> login(String email, String password) =>
      supabase.auth.signInWithPassword(email: email, password: password);

  // ── Real register ───────────────────────────────────
  static Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String role,
  }) async {
    final res = await supabase.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': name, 'role': role, 'phone': phone},
    );
    if (res.user != null) {
      await supabase.from('profiles').upsert({
        'id': res.user!.id,
        'full_name': name,
        'role': role,
        'phone': phone,
      });
      if (role == 'driver') {
        await supabase.from('drivers').upsert({
          'id': res.user!.id,
          'is_online': false,
          'vehicle_make': 'Toyota Corolla',
          'vehicle_plate': 'AB-123-CD',
        });
      }
    }
    return res;
  }

  // ── Sign out ────────────────────────────────────────
  static Future<void> signOut() => supabase.auth.signOut();

  // ── Load profile ────────────────────────────────────
  static Future<UserProfile?> loadProfile(String uid) async {
    try {
      final data =
          await supabase.from('profiles').select().eq('id', uid).single();
      return UserProfile.fromMap(data);
    } catch (_) {
      return null;
    }
  }

  // ── Ensure driver row exists ─────────────────────────
  static Future<void> ensureDriverRow(String uid) async {
    final existing =
        await supabase.from('drivers').select('id').eq('id', uid).maybeSingle();
    if (existing == null) {
      await supabase.from('drivers').insert({
        'id': uid,
        'is_online': false,
        'vehicle_make': 'Toyota Corolla',
        'vehicle_plate': 'AB-123-CD',
        'rating': 5.0,
        'total_trips': 0,
      });
    }
  }

  // ── Demo profiles ────────────────────────────────────
  static UserProfile demoProfile(String role) {
    const names = {
      'customer': 'Alex Demo',
      'driver': 'Luca Driver',
      'admin': 'Admin User',
    };
    const uuids = {
      'customer': '123e4567-e89b-12d3-a456-426614174000',
      'driver': '123e4567-e89b-12d3-a456-426614174001',
      'admin': '123e4567-e89b-12d3-a456-426614174002',
    };
    return UserProfile(
      id: uuids[role]!,
      fullName: names[role]!,
      role: role,
      phone: '+1 555 0000',
    );
  }
}
