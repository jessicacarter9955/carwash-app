import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';

final supabaseProvider =
    Provider<SupabaseClient>((ref) => Supabase.instance.client);

final authStateProvider = StreamProvider<Session?>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange.map((e) => e.session);
});

final profileProvider = FutureProvider<ProfileModel?>((ref) async {
  final session = await ref.watch(authStateProvider.future);
  if (session == null) return null;
  final sb = ref.read(supabaseProvider);
  try {
    final data =
        await sb.from('profiles').select().eq('id', session.user.id).single();
    return ProfileModel.fromMap(data);
  } catch (_) {
    return ProfileModel(
      id: session.user.id,
      fullName: session.user.email?.split('@')[0] ?? 'User',
      phone: '',
      role: 'customer',
    );
  }
});

class AuthNotifier extends StateNotifier<AsyncValue<void>> {
  final SupabaseClient _sb;
  AuthNotifier(this._sb) : super(const AsyncValue.data(null));

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await _sb.auth.signInWithPassword(email: email, password: password);
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> register(
      String name, String email, String phone, String password) async {
    state = const AsyncValue.loading();
    try {
      await _sb.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': name, 'phone': phone, 'role': 'customer'},
      );
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _sb.auth.signOut();
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<void>>(
  (ref) => AuthNotifier(ref.read(supabaseProvider)),
);
