import '../core/supabase_client.dart';
import '../models/order_model.dart';

class OrderService {
  static Future<OrderModel?> getOrder(String orderId) async {
    try {
      final data =
          await supabase.from('orders').select().eq('id', orderId).single();
      return OrderModel.fromMap(data);
    } catch (e) {
      print('Error fetching order: $e');
      return null;
    }
  }

  static Future<List<OrderModel>> getCustomerOrders(String customerId) async {
    try {
      final data = await supabase
          .from('orders')
          .select()
          .eq('customer_id', customerId)
          .order('created_at', ascending: false);
      return (data as List).map((m) => OrderModel.fromMap(m)).toList();
    } catch (e) {
      print('Error fetching orders: $e');
      return [];
    }
  }

  static Future<List<OrderModel>> getDriverOrders(String driverId) async {
    try {
      final data = await supabase
          .from('orders')
          .select()
          .eq('driver_id', driverId)
          .order('created_at', ascending: false);
      return (data as List).map((m) => OrderModel.fromMap(m)).toList();
    } catch (e) {
      print('Error fetching driver orders: $e');
      return [];
    }
  }

  static Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await supabaseAdmin
          .from('orders')
          .update({'status': status}).eq('id', orderId);
    } catch (e) {
      print('Error updating order status: $e');
    }
  }

  // ✅ ADD THIS - alias so driver_active_screen.dart calls work
  static Future<void> updateStatus(String orderId, String status) async {
    return updateOrderStatus(orderId, status);
  }

  static Future<void> assignDriver(String orderId, String driverId) async {
    try {
      await supabaseAdmin.from('orders').update(
          {'driver_id': driverId, 'status': 'assigned'}).eq('id', orderId);
    } catch (e) {
      print('Error assigning driver: $e');
    }
  }
}
