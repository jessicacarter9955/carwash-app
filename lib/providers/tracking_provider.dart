import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants.dart';
import '../services/routing_service.dart';
import '../providers/notification_provider.dart';
import 'auth_providers.dart';
import 'order_provider.dart';

enum TrackingPhase { idle, toPickup, atPickup, toHub, washing, delivered }

class TrackingState {
  final LatLng userPos;
  final LatLng driverPos;
  final LatLng hubPos; // washing facility near user
  final List<LatLng> routeCoords;
  final List<LatLng> travelledCoords; // already driven - grey
  final int simIndex;
  final TrackingPhase phase;
  final int etaMinutes;
  final String driverName;
  final String driverPlate;
  final double driverRating;
  final double driverRotation;
  final String keyStatus;
  final double
      simSpeedMultiplier; // Speed multiplier for demo (1x = normal, 2x = 2x faster, etc.)

  const TrackingState({
    this.userPos = const LatLng(kDefaultLat, kDefaultLng),
    this.driverPos = const LatLng(kDefaultLat + 0.01, kDefaultLng + 0.008),
    this.hubPos = const LatLng(kDefaultLat + 0.015, kDefaultLng + 0.012),
    this.routeCoords = const [],
    this.travelledCoords = const [],
    this.simIndex = 0,
    this.phase = TrackingPhase.idle,
    this.etaMinutes = 8,
    this.driverName = 'Luca R.',
    this.driverPlate = 'AB 123 CD',
    this.driverRating = 4.9,
    this.driverRotation = 0,
    this.keyStatus = 'with_customer',
    this.simSpeedMultiplier = 1.0,
  });

  TrackingState copyWith({
    LatLng? userPos,
    LatLng? driverPos,
    LatLng? hubPos,
    List<LatLng>? routeCoords,
    List<LatLng>? travelledCoords,
    int? simIndex,
    TrackingPhase? phase,
    int? etaMinutes,
    String? driverName,
    String? driverPlate,
    double? driverRating,
    double? driverRotation,
    String? keyStatus,
    double? simSpeedMultiplier,
  }) =>
      TrackingState(
        userPos: userPos ?? this.userPos,
        driverPos: driverPos ?? this.driverPos,
        hubPos: hubPos ?? this.hubPos,
        routeCoords: routeCoords ?? this.routeCoords,
        travelledCoords: travelledCoords ?? this.travelledCoords,
        simIndex: simIndex ?? this.simIndex,
        phase: phase ?? this.phase,
        etaMinutes: etaMinutes ?? this.etaMinutes,
        driverName: driverName ?? this.driverName,
        driverPlate: driverPlate ?? this.driverPlate,
        driverRating: driverRating ?? this.driverRating,
        driverRotation: driverRotation ?? this.driverRotation,
        keyStatus: keyStatus ?? this.keyStatus,
        simSpeedMultiplier: simSpeedMultiplier ?? this.simSpeedMultiplier,
      );
}

class TrackingNotifier extends StateNotifier<TrackingState> {
  final Ref _ref;
  Timer? _simTimer;
  StreamSubscription? _realtimeSub;

  TrackingNotifier(this._ref) : super(const TrackingState());

  /// Generate a washing facility near the user on a realistic offset
  LatLng _generateHubNearUser(double userLat, double userLng) {
    final rnd = Random();
    // Between 0.008 and 0.018 degrees away (~800m-2km)
    final latOffset =
        (0.008 + rnd.nextDouble() * 0.010) * (rnd.nextBool() ? 1 : -1);
    final lngOffset =
        (0.008 + rnd.nextDouble() * 0.010) * (rnd.nextBool() ? 1 : -1);
    return LatLng(userLat + latOffset, userLng + lngOffset);
  }

  /// Generate driver start position near user
  LatLng _generateDriverNearUser(double userLat, double userLng) {
    final rnd = Random();
    final latOffset =
        (0.005 + rnd.nextDouble() * 0.008) * (rnd.nextBool() ? 1 : -1);
    final lngOffset =
        (0.005 + rnd.nextDouble() * 0.008) * (rnd.nextBool() ? 1 : -1);
    return LatLng(userLat + latOffset, userLng + lngOffset);
  }

  Future<void> startTracking(double userLat, double userLng) async {
    await NotificationService.init();

    final userPos = LatLng(userLat, userLng);
    final driverPos = _generateDriverNearUser(userLat, userLng);
    final hubPos = _generateHubNearUser(userLat, userLng);

    // Route: driver → user
    final routeResult = await RoutingService.fetchRoute(
      driverPos.latitude,
      driverPos.longitude,
      userLat,
      userLng,
    );

    state = state.copyWith(
      userPos: userPos,
      driverPos: driverPos,
      hubPos: hubPos,
      routeCoords: routeResult.coords,
      travelledCoords: [],
      simIndex: 0,
      phase: TrackingPhase.toPickup,
      etaMinutes: int.tryParse(routeResult.dur) ?? 8,
      keyStatus: 'with_customer',
    );

    // Notify start
    await NotificationService.showLocal(
      'Driver on the way!',
      '${state.driverName} is heading to your location · ETA ${state.etaMinutes} min',
    );

    _runPhase1ToPickup(userPos, hubPos);
    _subscribeRealtime();
  }

  double _calculateRotation(LatLng from, LatLng to) {
    final latDiff = to.latitude - from.latitude;
    final lngDiff = to.longitude - from.longitude;
    return atan2(lngDiff, latDiff) * 180 / pi;
  }

  // ── Phase 1: Driver → User ──────────────────────────────────
  void _runPhase1ToPickup(LatLng userPos, LatLng hubPos) {
    _simTimer?.cancel();
    final interval = (700 / state.simSpeedMultiplier).round();
    _simTimer = Timer.periodic(Duration(milliseconds: interval), (
      timer,
    ) async {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final idx = state.simIndex;
      final coords = state.routeCoords;

      if (idx >= coords.length) {
        timer.cancel();
        await _onArrivedAtPickup(userPos, hubPos);
        return;
      }

      final remaining = coords.length - idx;
      final eta = max(1, (remaining * 0.015).round());
      final newPos = coords[idx];
      final rotation = _calculateRotation(state.driverPos, newPos);

      // Build travelled path
      final travelled = List<LatLng>.from(state.travelledCoords)..add(newPos);

      state = state.copyWith(
        driverPos: newPos,
        simIndex: idx + 1,
        etaMinutes: eta,
        phase: TrackingPhase.toPickup,
        driverRotation: rotation,
        travelledCoords: travelled,
      );
    });
  }

  // ── Arrived at pickup ───────────────────────────────────────
  Future<void> _onArrivedAtPickup(LatLng userPos, LatLng hubPos) async {
    state = state.copyWith(
      phase: TrackingPhase.atPickup,
      etaMinutes: 0,
      travelledCoords: [],
    );

    await NotificationService.showLocal(
      'Driver arrived!',
      '${state.driverName} is at your location',
    );

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    // Phase 2: User → Hub (washing facility)
    final routeResult = await RoutingService.fetchRoute(
      userPos.latitude,
      userPos.longitude,
      hubPos.latitude,
      hubPos.longitude,
    );

    state = state.copyWith(
      routeCoords: routeResult.coords,
      travelledCoords: [],
      simIndex: 0,
      phase: TrackingPhase.toHub,
      driverPos: userPos,
    );

    await NotificationService.showLocal(
      'Heading to washing facility',
      'Your items are picked up and on the way to be washed',
    );

    _updateOrderStatus('pickup');
    _runPhase2ToHub(hubPos);
  }

  // ── Phase 2: User → Hub ─────────────────────────────────────
  void _runPhase2ToHub(LatLng hubPos) {
    _simTimer?.cancel();
    final interval = (600 / state.simSpeedMultiplier).round();
    _simTimer = Timer.periodic(Duration(milliseconds: interval), (
      timer,
    ) async {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final idx = state.simIndex;
      if (idx >= state.routeCoords.length) {
        timer.cancel();
        await _onAtHub(hubPos);
        return;
      }

      final newPos = state.routeCoords[idx];
      final rotation = _calculateRotation(state.driverPos, newPos);
      final travelled = List<LatLng>.from(state.travelledCoords)..add(newPos);

      state = state.copyWith(
        driverPos: newPos,
        simIndex: idx + 1,
        driverRotation: rotation,
        travelledCoords: travelled,
      );
    });
  }

  // ── At hub: washing ─────────────────────────────────────────
  Future<void> _onAtHub(LatLng hubPos) async {
    state = state.copyWith(phase: TrackingPhase.washing, travelledCoords: []);

    await NotificationService.showLocal(
      'Washing started!',
      'Your items are now being washed at the facility',
    );

    _updateOrderStatus('washing');

    await Future.delayed(const Duration(seconds: 4));
    if (!mounted) return;

    state = state.copyWith(phase: TrackingPhase.delivered, travelledCoords: []);

    await NotificationService.showLocal(
      'All done!',
      'Your wash is complete. Rate your experience!',
    );

    _updateOrderStatus('delivered');
  }

  // ── Return to user (optional) ───────────────────────────────
  Future<void> startReturnToUser() async {
    final userPos = state.userPos;
    final hubPos = state.hubPos;

    final routeResult = await RoutingService.fetchRoute(
      hubPos.latitude,
      hubPos.longitude,
      userPos.latitude,
      userPos.longitude,
    );

    state = state.copyWith(
      routeCoords: routeResult.coords,
      travelledCoords: [],
      simIndex: 0,
      phase: TrackingPhase.toPickup, // reuse toPickup phase for return
      driverPos: hubPos,
    );

    await NotificationService.showLocal(
      'On the way back!',
      '${state.driverName} is returning your items',
    );

    _runReturnToUser(userPos);
  }

  void _runReturnToUser(LatLng userPos) {
    _simTimer?.cancel();
    final interval = (700 / state.simSpeedMultiplier).round();
    _simTimer = Timer.periodic(Duration(milliseconds: interval), (
      timer,
    ) async {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final idx = state.simIndex;
      if (idx >= state.routeCoords.length) {
        timer.cancel();
        state = state.copyWith(phase: TrackingPhase.delivered);
        await NotificationService.showLocal(
          'Delivered back to you!',
          'Your items have been returned. Enjoy!',
        );
        return;
      }

      final newPos = state.routeCoords[idx];
      final rotation = _calculateRotation(state.driverPos, newPos);
      final travelled = List<LatLng>.from(state.travelledCoords)..add(newPos);

      state = state.copyWith(
        driverPos: newPos,
        simIndex: idx + 1,
        driverRotation: rotation,
        travelledCoords: travelled,
      );
    });
  }

  void updateKeyStatus(String status) {
    state = state.copyWith(keyStatus: status);
    _updateOrderKeyStatus(status);
  }

  Future<void> _updateOrderKeyStatus(String status) async {
    try {
      final order = _ref.read(orderProvider).currentOrder;
      if (order == null || order.id.startsWith('local-')) return;
      final sb = _ref.read(supabaseProvider);
      await sb.from('orders').update({'key_status': status}).eq('id', order.id);
    } catch (_) {}
  }

  Future<void> _updateOrderStatus(String status) async {
    try {
      final order = _ref.read(orderProvider).currentOrder;
      if (order == null || order.id.startsWith('local-')) return;
      final sb = _ref.read(supabaseProvider);
      await sb.from('orders').update({
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', order.id);
      await sb.from('order_status_history').insert({
        'order_id': order.id,
        'status': status,
      });
    } catch (_) {}
  }

  void _subscribeRealtime() {
    try {
      final order = _ref.read(orderProvider).currentOrder;
      if (order == null || order.id.startsWith('local-')) return;
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
            callback: (payload) {},
          )
          .subscribe();
    } catch (_) {}
  }

  void stopTracking() {
    _simTimer?.cancel();
    _realtimeSub?.cancel();
    state = const TrackingState();
  }

  void setSpeedMultiplier(double multiplier) {
    state = state.copyWith(simSpeedMultiplier: multiplier);
    // Restart current phase with new speed if tracking is active
    if (state.phase == TrackingPhase.toPickup && state.routeCoords.isNotEmpty) {
      _runPhase1ToPickup(state.userPos, state.hubPos);
    } else if (state.phase == TrackingPhase.toHub &&
        state.routeCoords.isNotEmpty) {
      _runPhase2ToHub(state.hubPos);
    }
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
