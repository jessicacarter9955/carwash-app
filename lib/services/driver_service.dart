import '../core/supabase_client.dart';

class DriverService {
  static Future<void> setOnline(String driverId, bool online) async {
    try {
      await supabaseAdmin.from('drivers').update({
        'online': online,
        'updated_at': DateTime.now().toIso8601String()
      }).eq('id', driverId);
    } catch (e) {
      print('Error updating driver status: $e');
    }
  }

  static Future<Map<String, dynamic>?> getDriver(String driverId) async {
    try {
      final data =
          await supabase.from('drivers').select().eq('id', driverId).single();
      return data;
    } catch (e) {
      print('Error fetching driver: $e');
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> fetchDrivers() async {
    try {
      final data = await supabase
          .from('drivers')
          .select('*, profiles(full_name)')
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print('Error fetching drivers: $e');
      return [];
    }
  }
}
