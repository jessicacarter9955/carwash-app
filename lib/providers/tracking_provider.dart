import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants.dart';
import '../services/routing_service.dart';
import 'auth_providers.dart';
import 'order_provider.dart';

enum TrackingPhase { idle, toPickup, atPickup, toHub, washing, delivered }

class TrackingState {
  final LatLng userPos;
  final LatLng driverPos;
  final List<LatLng> routeCoords;
  final int simIndex;
  final TrackingPhase phase;
  final int etaMinutes;
  final String driverName;
  final String driverPlate;
  final double driverRating;
  final double driverRotation;
  // Key status for car wash
  final String keyStatus; // with_customer, with_driver, at_wash, returned

  const TrackingState({
    this.userPos = const LatLng(kDefaultLat, kDefaultLng),
    this.driverPos = const LatLng(kDefaultLat + 0.01, kDefaultLng + 0.008),
    this.routeCoords = const [],
    this.simIndex = 0,
    this.phase = TrackingPhase.idle,
    this.etaMinutes = 8,
    this.driverName = 'Luca R.',
    this.driverPlate = 'AB 123 CD',
    this.driverRating = 4.9,
    this.driverRotation = 0,
    this.keyStatus = 'with_customer',
  });

  TrackingState copyWith({
    LatLng? userPos,
    LatLng? driverPos,
    List<LatLng>? routeCoords,
    int? simIndex,
    TrackingPhase? phase,
    int? etaMinutes,
    String? driverName,
    String? driverPlate,
    double? driverRating,
    double? driverRotation,
    String? keyStatus,
  }) => TrackingState(
    userPos: userPos ?? this.userPos,
    driverPos: driverPos ?? this.driverPos,
    routeCoords: routeCoords ?? this.routeCoords,
    simIndex: simIndex ?? this.simIndex,
    phase: phase ?? this.phase,
    etaMinutes: etaMinutes ?? this.etaMinutes,
    driverName: driverName ?? this.driverName,
    driverPlate: driverPlate ?? this.driverPlate,
    driverRating: driverRating ?? this.driverRating,
    driverRotation: driverRotation ?? this.driverRotation,
    keyStatus: keyStatus ?? this.keyStatus,
  );
}

class TrackingNotifier extends StateNotifier<TrackingState> {
  final Ref _ref;
  Timer? _simTimer;
  StreamSubscription? _realtimeSub;

  TrackingNotifier(this._ref) : super(const TrackingState());

  Future<void> startTracking(double userLat, double userLng) async {
    final rnd = Random();
    final driverLat = userLat + (rnd.nextDouble() - 0.5) * 0.02;
    final driverLng = userLng + (rnd.nextDouble() - 0.5) * 0.02;

    final userPos = LatLng(userLat, userLng);
    final driverPos = LatLng(driverLat, driverLng);

    // Fetch actual street-level route from Mapbox
    final routeResult = await RoutingService.fetchRoute(
      driverLat,
      driverLng,
      userLat,
      userLng,
    );

    state = state.copyWith(
      userPos: userPos,
      driverPos: driverPos,
      routeCoords: routeResult.coords,
      simIndex: 0,
      phase: TrackingPhase.toPickup,
      etaMinutes: int.tryParse(routeResult.dur) ?? 8,
      keyStatus: 'with_customer',
    );

    _runSimulation(userPos);
    _subscribeRealtime();
  }

  void updateKeyStatus(String status) {
    state = state.copyWith(keyStatus: status);
    _updateOrderKeyStatus(status);
  }

  Future<void> _updateOrderKeyStatus(String status) async {
    try {
      final order = _ref.read(orderProvider).currentOrder;
      if (order == null) return;
      // Skip backend update for local orders
      if (order.id.startsWith('local-')) return;
      final sb = _ref.read(supabaseProvider);
      await sb.from('orders').update({'key_status': status}).eq('id', order.id);
    } catch (_) {}
  }

  double _calculateRotation(LatLng start, LatLng end) {
    final latDiff = end.latitude - start.latitude;
    final lngDiff = end.longitude - start.longitude;
    final angle = atan2(lngDiff, latDiff);
    return angle * 180 / pi;
  }

  void _runSimulation(LatLng userPos) {
    _simTimer?.cancel();
    _simTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final idx = state.simIndex;
      final coords = state.routeCoords;

      if (idx >= coords.length) {
        timer.cancel();
        _onArrivedAtPickup(userPos);
        return;
      }

      final remaining = coords.length - idx;
      final eta = max(1, (remaining * 0.015).round());
      final newPos = coords[idx];
      final rotation = _calculateRotation(state.driverPos, newPos);

      state = state.copyWith(
        driverPos: newPos,
        simIndex: idx + 1,
        etaMinutes: eta,
        phase: TrackingPhase.toPickup,
        driverRotation: rotation,
      );
    });
  }

  Future<void> _onArrivedAtPickup(LatLng userPos) async {
    state = state.copyWith(phase: TrackingPhase.atPickup, etaMinutes: 0);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    // Phase 2: drive to hub using actual street-level route
    final routeResult = await RoutingService.fetchRoute(
      userPos.latitude,
      userPos.longitude,
      kHubLat,
      kHubLng,
    );

    state = state.copyWith(
      routeCoords: routeResult.coords,
      simIndex: 0,
      phase: TrackingPhase.toHub,
      driverPos: userPos,
    );

    _simTimer = Timer.periodic(const Duration(milliseconds: 600), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final idx = state.simIndex;
      if (idx >= state.routeCoords.length) {
        timer.cancel();
        _onAtHub();
        return;
      }
      final newPos = state.routeCoords[idx];
      final rotation = _calculateRotation(state.driverPos, newPos);
      state = state.copyWith(
        driverPos: newPos,
        simIndex: idx + 1,
        driverRotation: rotation,
      );
    });

    // Update order status
    _updateOrderStatus('pickup');
  }

  Future<void> _onAtHub() async {
    state = state.copyWith(phase: TrackingPhase.washing);
    _updateOrderStatus('washing');
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    state = state.copyWith(phase: TrackingPhase.delivered);
    _updateOrderStatus('delivered');
  }

  Future<void> _updateOrderStatus(String status) async {
    try {
      final order = _ref.read(orderProvider).currentOrder;
      if (order == null) return;
      // Skip backend update for local orders
      if (order.id.startsWith('local-')) return;
      final sb = _ref.read(supabaseProvider);
      await sb
          .from('orders')
          .update({
            'status': status,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', order.id);
      await sb.from('order_status_history').insert({
        'order_id': order.id,
        'status': status,
      });
    } catch (_) {}
  }

  void _subscribeRealtime() {
    try {
      final order = _ref.read(orderProvider).currentOrder;
      if (order == null) return;
      // Skip realtime subscription for local orders
      if (order.id.startsWith('local-')) return;

      final sb = _ref.read(supabaseProvider);
      _realtimeSub?.cancel();
      sb
          .channel('order-${order.id}')
          .onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: 'public',
            table: 'orders',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'id',
              value: order.id,
            ),
            callback: (payload) {
              final newStatus = payload.newRecord['status'] as String?;
              if (newStatus != null) {
                // Status updated from outside (e.g., driver app)
              }
            },
          )
          .subscribe();
    } catch (_) {}
  }

  void stopTracking() {
    _simTimer?.cancel();
    _realtimeSub?.cancel();
    state = const TrackingState(keyStatus: 'with_customer');
  }

  @override
  void dispose() {
    _simTimer?.cancel();
    _realtimeSub?.cancel();
    super.dispose();
  }
}

final trackingProvider = StateNotifierProvider<TrackingNotifier, TrackingState>(
  (ref) => TrackingNotifier(ref),
);
