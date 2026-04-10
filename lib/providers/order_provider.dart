import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order_model.dart';
import 'auth_providers.dart';
import 'cart_provider.dart';
import 'location_provider.dart';

class OrderState {
  final OrderModel? currentOrder;
  final List<OrderModel> orders;
  final bool loading;
  final String? error;

  const OrderState(
      {this.currentOrder,
      this.orders = const [],
      this.loading = false,
      this.error});

  OrderState copyWith(
          {OrderModel? currentOrder,
          List<OrderModel>? orders,
          bool? loading,
          String? error}) =>
      OrderState(
        currentOrder: currentOrder ?? this.currentOrder,
        orders: orders ?? this.orders,
        loading: loading ?? this.loading,
        error: error,
      );
}

class OrderNotifier extends StateNotifier<OrderState> {
  final Ref _ref;
  OrderNotifier(this._ref) : super(const OrderState());

  Future<bool> placeOrder() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final sb = _ref.read(supabaseProvider);
      final session = await _ref.read(authStateProvider.future);
      if (session == null) throw Exception('Not authenticated');

      final cart = _ref.read(cartProvider);
      final location = _ref.read(locationProvider);

      final data = await sb
          .from('orders')
          .insert({
            'customer_id': session.user.id,
            'status': 'pending',
            'service_type': cart.selectedService,
            'items': cart.itemsMap,
            'subtotal': cart.itemsTotal,
            'service_fee': cart.serviceExtra,
            'addon_fee': cart.addonExtra,
            'delivery_fee': 2.99,
            'total': cart.total,
            'pickup_address': location.address,
            'pickup_lat': location.lat,
            'pickup_lng': location.lng,
            'pickup_slot': cart.selectedTime,
            'payment_method': cart.selectedPaymentMethod,
            'payment_status': 'pending',
          })
          .select()
          .single();

      final order = OrderModel.fromMap(data);
      state = state.copyWith(currentOrder: order, loading: false);

      // Insert status history
      await sb.from('order_status_history').insert({
        'order_id': order.id,
        'status': 'pending',
      });

      return true;
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      return false;
    }
  }

  Future<void> fetchOrders() async {
    state = state.copyWith(loading: true);
    try {
      final sb = _ref.read(supabaseProvider);
      final session = await _ref.read(authStateProvider.future);
      if (session == null) return;

      final data = await sb
          .from('orders')
          .select()
          .eq('customer_id', session.user.id)
          .order('created_at', ascending: false);

      final orders = (data as List).map((m) => OrderModel.fromMap(m)).toList();
      state = state.copyWith(orders: orders, loading: false);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  void setCurrentOrder(OrderModel order) =>
      state = state.copyWith(currentOrder: order);

  Future<void> submitRating(int rating, List<String> tags) async {
    try {
      final sb = _ref.read(supabaseProvider);
      final session = await _ref.read(authStateProvider.future);
      final order = state.currentOrder;
      if (session == null || order == null) return;

      await sb.from('ratings').insert({
        'order_id': order.id,
        'customer_id': session.user.id,
        'driver_id': order.driverId,
        'rating': rating,
        'tags': tags,
      });
    } catch (_) {}
  }
}

final orderProvider = StateNotifierProvider<OrderNotifier, OrderState>(
  (ref) => OrderNotifier(ref),
);
