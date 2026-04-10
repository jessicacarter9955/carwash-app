import '../core/supabase_client.dart';
import '../models/order.dart';

class OrderService {
  // ── Place order (demo — no real DB write) ────────────
  static AppOrder placeDemoOrder({
    required String customerId,
    required String serviceType,
    required Map<String, dynamic> orderItems,
    required double total,
    required String pickupAddress,
    required double lat,
    required double lng,
  }) {
    return AppOrder(
      id: 'demo-order-${DateTime.now().millisecondsSinceEpoch}',
      customerId: customerId,
      status: 'confirmed',
      serviceType: serviceType,
      total: total,
      pickupAddress: pickupAddress,
      pickupLat: lat,
      pickupLng: lng,
      paymentStatus: 'paid',
      createdAt: DateTime.now(),
    );
  }

  // ── Fetch customer orders ────────────────────────────
  static Future<List<AppOrder>> fetchOrders(String customerId) async {
    try {
      final data = await sb
          .from('orders')
          .select()
          .eq('customer_id', customerId)
          .order('created_at', ascending: false);
      return (data as List)
          .map((m) => AppOrder.fromMap(m as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ── Fetch latest order ───────────────────────────────
  static Future<AppOrder?> fetchLatestOrder(String customerId) async {
    try {
      final data = await sb
          .from('orders')
          .select()
          .eq('customer_id', customerId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();
      if (data != null) return AppOrder.fromMap(data);
    } catch (_) {}
    return null;
  }

  // ── Update status ────────────────────────────────────
  static Future<void> updateStatus(String orderId, String status) async {
    try {
      await sb.from('orders').update({'status': status}).eq('id', orderId);
    } catch (_) {}
  }

  // ── Accept order (driver) ────────────────────────────
  static Future<void> acceptOrder(String orderId, String driverId) async {
    try {
      await sb
          .from('orders')
          .update({'driver_id': driverId, 'status': 'confirmed'})
          .eq('id', orderId);
    } catch (_) {}
  }
}
