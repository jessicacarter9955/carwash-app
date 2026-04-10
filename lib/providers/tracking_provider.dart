import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants.dart';
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
  }) =>
      TrackingState(
        userPos: userPos ?? this.userPos,
        driverPos: driverPos ?? this.driverPos,
        routeCoords: routeCoords ?? this.routeCoords,
        simIndex: simIndex ?? this.simIndex,
        phase: phase ?? this.phase,
        etaMinutes: etaMinutes ?? this.etaMinutes,
        driverName: driverName ?? this.driverName,
        driverPlate: driverPlate ?? this.driverPlate,
        driverRating: driverRating ?? this.driverRating,
      );
}

class TrackingNotifier extends StateNotifier<TrackingState> {
  final Ref _ref;
  Timer? _simTimer;
  StreamSubscription? _realtimeSub;

  TrackingNotifier(this._ref) : super(const TrackingState());

  void startTracking(double userLat, double userLng) {
    final rnd = Random();
    final driverLat = userLat + (rnd.nextDouble() - 0.5) * 0.02;
    final driverLng = userLng + (rnd.nextDouble() - 0.5) * 0.02;

    final userPos = LatLng(userLat, userLng);
    final driverPos = LatLng(driverLat, driverLng);
    final route = _interpolate(driverPos, userPos, 60);

    state = state.copyWith(
      userPos: userPos,
      driverPos: driverPos,
      routeCoords: route,
      simIndex: 0,
      phase: TrackingPhase.toPickup,
      etaMinutes: 8,
    );

    _runSimulation(userPos);
    _subscribeRealtime();
  }

  List<LatLng> _interpolate(LatLng from, LatLng to, int steps) {
    final coords = <LatLng>[];
    for (int i = 0; i <= steps; i++) {
      final t = i / steps;
      coords.add(LatLng(
        from.latitude + (to.latitude - from.latitude) * t,
        from.longitude + (to.longitude - from.longitude) * t,
      ));
    }
    return coords;
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

      state = state.copyWith(
        driverPos: coords[idx],
        simIndex: idx + 1,
        etaMinutes: eta,
        phase: TrackingPhase.toPickup,
      );
    });
  }

  Future<void> _onArrivedAtPickup(LatLng userPos) async {
    state = state.copyWith(phase: TrackingPhase.atPickup, etaMinutes: 0);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    // Phase 2: drive to hub
    final hubPos = const LatLng(kHubLat, kHubLng);
    final route = _interpolate(userPos, hubPos, 80);
    state = state.copyWith(
        routeCoords: route, simIndex: 0, phase: TrackingPhase.toHub);

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
      state =
          state.copyWith(driverPos: state.routeCoords[idx], simIndex: idx + 1);
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
      final sb = _ref.read(supabaseProvider);
      final order = _ref.read(orderProvider).currentOrder;
      if (order == null) return;
      await sb.from('orders').update({
        'status': status,
        'updated_at': DateTime.now().toIso8601String()
      }).eq('id', order.id);
      await sb
          .from('order_status_history')
          .insert({'order_id': order.id, 'status': status});
    } catch (_) {}
  }

  void _subscribeRealtime() {
    try {
      final sb = _ref.read(supabaseProvider);
      final order = _ref.read(orderProvider).currentOrder;
      if (order == null) return;

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
                value: order.id),
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
    state = const TrackingState();
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
