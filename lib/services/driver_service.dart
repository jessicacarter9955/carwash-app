import '../core/supabase_client.dart';

class DriverService {
  static Future<void> setOnline(String driverId, bool online) async {
    try {
      await sb
          .from('drivers')
          .update({'is_online': online})
          .eq('id', driverId);
    } catch (_) {}
  }

  static Future<List<Map<String, dynamic>>> fetchDrivers() async {
    try {
      final data = await sb
          .from('drivers')
          .select('*,profiles(full_name)');
      return List<Map<String, dynamic>>.from(data as List);
    } catch (_) {
      return [];
    }
  }
}
