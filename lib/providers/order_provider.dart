import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order_model.dart';
import 'auth_providers.dart';
import 'cart_provider.dart';
import 'location_provider.dart';
import '../core/supabase_client.dart';

class OrderState {
  final OrderModel? currentOrder;
  final List<OrderModel> orders;
  final bool loading;
  final String? error;

  const OrderState({
    this.currentOrder,
    this.orders = const [],
    this.loading = false,
    this.error,
  });

  OrderState copyWith({
    OrderModel? currentOrder,
    List<OrderModel>? orders,
    bool? loading,
    String? error,
  }) =>
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

  Future<bool> placeOrder({bool localMode = true}) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final cart = _ref.read(cartProvider);
      final location = _ref.read(locationProvider);
      final session = await _ref.read(authStateProvider.future);
      final customerId =
          session?.user.id ?? '00000000-0000-0000-0000-000000000001';

      if (localMode) {
        final order = OrderModel(
          id: 'local-${DateTime.now().millisecondsSinceEpoch}',
          customerId: customerId,
          status: 'pending',
          serviceType: cart.selectedService,
          items: cart.itemsMap,
          subtotal: cart.itemsTotal,
          serviceFee: cart.serviceExtra,
          addonFee: cart.addonExtra,
          deliveryFee: 2.99,
          total: cart.total,
          pickupAddress: location.address,
          pickupLat: location.lat,
          pickupLng: location.lng,
          pickupSlot: cart.selectedTime,
          paymentMethod: cart.selectedPaymentMethod,
          paymentStatus: 'paid',
          driverId: 'demo-driver',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        state = state.copyWith(currentOrder: order, loading: false);
        return true;
      }

      // Backend mode
      final data = await supabaseAdmin
          .from('orders')
          .insert({
            'customer_id': customerId,
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

      await supabaseAdmin.from('order_status_history').insert({
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
      final session = await _ref.read(authStateProvider.future);
      if (session == null) return;

      final data = await supabase
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
      final session = await _ref.read(authStateProvider.future);
      final order = state.currentOrder;
      if (session == null || order == null) return;

      await supabase.from('ratings').insert({
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
