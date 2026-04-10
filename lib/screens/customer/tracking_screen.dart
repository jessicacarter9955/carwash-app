import 'dart:async';
import 'package:flutter/material.dart' hide StepState;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../services/routing_service.dart';
import '../../state/app_state.dart';
import '../../widgets/map_widget.dart';
import '../../widgets/timeline_step.dart';
import '../../widgets/toast_overlay.dart';

class TrackingScreen extends StatefulWidget {
  final VoidCallback onDone, onClose;
  const TrackingScreen({
    super.key,
    required this.onDone,
    required this.onClose,
  });
  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final MapController _mapCtrl = MapController();
  List<LatLng> _routeCoords = [];
  List<LatLng> _simCoords = [];
  int _simIdx = 0;
  Timer? _simTimer;
  LatLng? _driverPos;
  String _eta = 'Calculating...';
  StepState _s1 = StepState.done,
      _s2 = StepState.active,
      _s3 = StepState.pending,
      _s4 = StepState.pending,
      _s5 = StepState.pending;

  @override
  void initState() {
    super.initState();
    _initTracking();
  }

  Future<void> _initTracking() async {
    final state = context.read<AppState>();
    final uLat = state.userLat, uLng = state.userLng;
    final dLat = uLat + .01, dLng = uLng + .01;
    _driverPos = LatLng(dLat, dLng);
    final route = await RoutingService.fetchRoute(dLat, dLng, uLat, uLng);
    if (!mounted) return;
    setState(() {
      _routeCoords = route.coords;
      _simCoords = route.coords;
      _eta = '${route.dur} min away';
    });
    _mapCtrl.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds.fromPoints([
          LatLng(dLat, dLng),
          LatLng(uLat, uLng),
        ]),
        padding: const EdgeInsets.all(40),
      ),
    );
    _runSim(state);
  }

  void _runSim(AppState state) {
    _simTimer = Timer.periodic(const Duration(milliseconds: 800), (t) {
      if (_simIdx >= _simCoords.length) {
        t.cancel();
        _simDone();
        return;
      }
      final pos = _simCoords[_simIdx];
      final rem = _simCoords.length - _simIdx;
      setState(() {
        _driverPos = pos;
        _eta = '${(rem * .015).ceil()} min away';
        _simIdx++;
      });
    });
  }

  Future<void> _simDone() async {
    showToast('🚗 Driver arrived at pickup!');
    setState(() {
      _eta = '📍 Arrived!';
      _s2 = StepState.done;
      _s3 = StepState.active;
    });
    await Future.delayed(const Duration(seconds: 2));
    showToast('🧺 Items collected!');
    setState(() {
      _s3 = StepState.done;
      _s4 = StepState.active;
    });
    await Future.delayed(const Duration(seconds: 2));
    showToast('✅ Delivered!');
    setState(() {
      _eta = '🏠 Delivered!';
      _s4 = StepState.done;
      _s5 = StepState.active;
    });
    await Future.delayed(const Duration(seconds: 2));
    widget.onDone();
  }

  @override
  void dispose() {
    _simTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Stack(
      children: [
        // Map
        SizedBox(
          height: 640 * .52,
          child: Stack(
            children: [
              WashGoMap(
                center: _driverPos ?? LatLng(state.userLat, state.userLng),
                controller: _mapCtrl,
                markers: [
                  userMarker(LatLng(state.userLat, state.userLng)),
                  if (_driverPos != null) carMarker(_driverPos!),
                ],
                polylines: _routeCoords.isNotEmpty
                    ? [
                        Polyline(
                          points: _routeCoords,
                          color: kCyan3,
                          strokeWidth: 3,
                        ),
                      ]
                    : [],
              ),
              // Close btn
              Positioned(
                top: 10,
                left: 12,
                child: GestureDetector(
                  onTap: () {
                    _simTimer?.cancel();
                    widget.onClose();
                  },
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: kSurface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: kBorder),
                    ),
                    child: const Center(
                      child: Text('✕', style: TextStyle(fontSize: 14)),
                    ),
                  ),
                ),
              ),
              // ETA badge
              Positioned(
                top: 10,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.92),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: kBorder),
                  ),
                  child: Text(
                    '🕐 $_eta',
                    style: const TextStyle(
                      fontFamily: kFontHead,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Tracking sheet
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            constraints: BoxConstraints(maxHeight: 640 * .5),
            decoration: BoxDecoration(
              color: kSurface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(22),
              ),
              border: const Border(top: BorderSide(color: kBorder)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.08),
                  blurRadius: 24,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 80),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 32,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4DDE6),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Driver info
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(colors: [kCyan3, kMint]),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text('🚗', style: TextStyle(fontSize: 20)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Luca R.',
                              style: TextStyle(
                                fontFamily: kFontHead,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const Text(
                              '★★★★★ 4.9',
                              style: TextStyle(fontSize: 11, color: kMuted),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          _ActBtn(
                            emoji: '📞',
                            onTap: () => showToast('📞 Calling driver...'),
                          ),
                          const SizedBox(width: 8),
                          _ActBtn(
                            emoji: '💬',
                            onTap: () => showToast('💬 Chat opened'),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: kCyan3.withOpacity(.12),
                              border: Border.all(color: kCyan3.withOpacity(.3)),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'AB 123 CD',
                              style: TextStyle(
                                fontFamily: kFontHead,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: kCyan3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: kBorder),
                  const SizedBox(height: 12),
                  // Timeline
                  TimelineStep(
                    dotContent: '✓',
                    name: 'Driver Confirmed',
                    sub: 'Driver accepted your order',
                    state: _s1,
                  ),
                  TimelineStep(
                    dotContent: '🚗',
                    name: 'Driver en Route',
                    sub: 'Approaching your location',
                    state: _s2,
                  ),
                  TimelineStep(
                    dotContent: '📍',
                    name: 'Pickup',
                    sub: 'Your location',
                    state: _s3,
                  ),
                  TimelineStep(
                    dotContent: '🧺',
                    name: 'Washing',
                    sub: 'At the facility',
                    state: _s4,
                  ),
                  TimelineStep(
                    dotContent: '🏠',
                    name: 'Delivered',
                    sub: 'To your door',
                    state: _s5,
                    isLast: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActBtn extends StatelessWidget {
  final String emoji;
  final VoidCallback onTap;
  const _ActBtn({required this.emoji, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: kBg,
          border: Border.all(color: kBorder),
          shape: BoxShape.circle,
        ),
        child: Center(child: Text(emoji, style: const TextStyle(fontSize: 15))),
      ),
    );
  }
}
