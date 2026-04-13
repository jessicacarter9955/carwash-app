import '../core/supabase_client.dart';

class AdminMetrics {
  final double revenue;
  final int activeOrders;
  final int onlineDrivers;

  const AdminMetrics({
    required this.revenue,
    required this.activeOrders,
    required this.onlineDrivers,
  });
}

class AdminService {
  static Future<AdminMetrics> fetchMetrics() async {
    try {
      final orders =
          await supabaseAdmin.from('orders').select('total,status,created_at');
      final today = (orders as List).where((o) {
        final d = DateTime.parse(o['created_at'] as String);
        final now = DateTime.now();
        return d.year == now.year && d.month == now.month && d.day == now.day;
      }).toList();
      final revenue = today.fold<double>(
          0, (s, o) => s + ((o['total'] as num?)?.toDouble() ?? 0));
      final active = (orders as List)
          .where((o) =>
              !['delivered', 'cancelled'].contains(o['status'] as String?))
          .length;
      final drivers = await supabaseAdmin.from('drivers').select('is_online');
      final online =
          (drivers as List).where((d) => d['is_online'] == true).length;
      return AdminMetrics(
          revenue: revenue, activeOrders: active, onlineDrivers: online);
    } catch (_) {
      return const AdminMetrics(revenue: 0, activeOrders: 0, onlineDrivers: 0);
    }
  }

  static Future<List<Map<String, dynamic>>> fetchAllOrders(
      {String filter = 'all'}) async {
    try {
      var q = supabaseAdmin.from('orders').select('*');
      if (filter != 'all') q = q.eq('status', filter) as dynamic;
      final data = await (q as dynamic).order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(data as List);
    } catch (_) {
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> fetchPricing() async {
    try {
      final data = await supabaseAdmin.from('service_pricing').select('*');
      return List<Map<String, dynamic>>.from(data as List);
    } catch (_) {
      return [];
    }
  }

  static Future<void> savePrice(String itemKey, double price) async {
    await supabaseAdmin
        .from('service_pricing')
        .update({'price': price}).eq('item_key', itemKey);
  }
}
