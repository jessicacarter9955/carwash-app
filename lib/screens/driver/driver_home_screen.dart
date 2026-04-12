import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../services/driver_service.dart';
import '../../state/app_state.dart';
import '../../widgets/map_widget.dart';
import '../../widgets/stat_tile.dart';
import '../../widgets/toast_overlay.dart';
import 'driver_view.dart';

class DriverHomeScreen extends ConsumerStatefulWidget {
  final Function(DScreen) onNav;
  const DriverHomeScreen({super.key, required this.onNav});
  @override
  ConsumerState<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends ConsumerState<DriverHomeScreen> {
  bool _showReq = false;
  int _countdown = 15;
  Timer? _cdTimer;

  // Mock incoming job
  String _reqCust = 'Alex M.';
  String _reqPrice = '\$12.50';
  String _reqDist = '2.3 km · est. 8 min';

  void _showIncoming() {
    final names = ['Alex M.', 'Sara L.', 'Marco B.', 'Anna T.'];
    final price = (8 + (DateTime.now().millisecond / 1000 * 12))
        .toStringAsFixed(2);
    final dist = (0.5 + (DateTime.now().second / 60 * 5)).toStringAsFixed(1);
    setState(() {
      _showReq = true;
      _reqCust = names[DateTime.now().second % names.length];
      _reqPrice = '\$$price';
      _reqDist = '$dist km · est. ${(5 + DateTime.now().second % 15)} min';
      _countdown = 15;
    });
    _cdTimer?.cancel();
    _cdTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_countdown <= 0) {
        t.cancel();
        _declineReq();
        return;
      }
      setState(() => _countdown--);
    });
  }

  void _declineReq() {
    _cdTimer?.cancel();
    setState(() => _showReq = false);
    showToast('❌ Request declined');
  }

  void _acceptReq() {
    _cdTimer?.cancel();
    setState(() => _showReq = false);
    showToast('✅ Job accepted!');
    widget.onNav(DScreen.active);
  }

  @override
  void dispose() {
    _cdTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Column(
      children: [
        // Top bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          color: kSurface,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.currentProfile?.fullName ?? 'Driver',
                      style: const TextStyle(
                        fontFamily: kFontHead,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Text(
                      '--',
                      style: TextStyle(
                        fontSize: 10,
                        color: kMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () async {
                  state.setDriverOnline(!state.driverOnline);
                  if (state.currentUserId != null) {
                    await DriverService.setOnline(
                      state.currentUserId!,
                      state.driverOnline,
                    );
                  }
                  showToast(
                    state.driverOnline
                        ? '🟢 You are now online'
                        : '🔴 You went offline',
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: state.driverOnline ? kMint.withOpacity(.12) : kBg,
                    border: Border.all(
                      color: state.driverOnline
                          ? kMint.withOpacity(.35)
                          : kBorder,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: state.driverOnline ? kMint2 : kMuted,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        state.driverOnline ? 'Online' : 'Offline',
                        style: TextStyle(
                          fontFamily: kFontHead,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: state.driverOnline ? kMint2 : kMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => context.go('/home'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: kBg,
                    border: Border.all(color: kBorder),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.home, size: 12),
                      SizedBox(width: 4),
                      Text(
                        'Customer',
                        style: TextStyle(
                          fontFamily: kFontHead,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // Map + overlay
        Expanded(
          child: Stack(
            children: [
              WashGoMap(
                center: LatLng(kDefaultLat + .005, kDefaultLng),
                zoom: 14,
                markers: [
                  carMarker(LatLng(kDefaultLat + .004, kDefaultLng + .003)),
                  Marker(
                    point: LatLng(kDefaultLat + .008, kDefaultLng - .005),
                    width: 26,
                    height: 26,
                    child: Container(
                      decoration: BoxDecoration(
                        color: kCyan3.withOpacity(.9),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.directions_car,
                          size: 13,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Bottom overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Color(0xFFF4F5F6), Colors.transparent],
                      stops: [0.6, 1.0],
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                  child: Column(
                    children: [
                      // Stats
                      Row(
                        children: [
                          StatTile(value: '\$0', label: 'Today'),
                          const SizedBox(width: 8),
                          StatTile(value: '0', label: 'Trips'),
                          const SizedBox(width: 8),
                          StatTile(value: '5.0★', label: 'Rating'),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => widget.onNav(DScreen.earnings),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: kBorder),
                                foregroundColor: kText,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.attach_money, size: 16),
                                  SizedBox(width: 6),
                                  Text(
                                    'Earnings',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _showIncoming,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: kBorder),
                                foregroundColor: kText,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.notifications, size: 16),
                                  SizedBox(width: 6),
                                  Text(
                                    'Simulate Job',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Incoming req card
              if (_showReq)
                Positioned(
                  bottom: 50,
                  left: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: kSurface,
                      border: Border.all(color: kBorder, width: 1.5),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.12),
                          blurRadius: 40,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.directions_car, size: 10, color: kCyan3),
                            SizedBox(width: 4),
                            Text(
                              'CAR PICKUP',
                              style: TextStyle(
                                fontFamily: kFontHead,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: kCyan3,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _reqCust,
                          style: const TextStyle(
                            fontFamily: kFontHead,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Row(
                          children: const [
                            Icon(Icons.location_on, size: 12, color: kMuted),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'Via Roma 15 → Car Wash Hub',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: kMuted,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _reqPrice,
                                    style: const TextStyle(
                                      fontFamily: kFontHead,
                                      fontSize: 26,
                                      fontWeight: FontWeight.w900,
                                      color: kCyan3,
                                    ),
                                  ),
                                  Text(
                                    _reqDist,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: kMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '$_countdown',
                              style: const TextStyle(
                                fontFamily: kFontHead,
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: kOrange,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _declineReq,
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: kRed),
                                  foregroundColor: kRed,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'Decline',
                                  style: TextStyle(
                                    fontFamily: kFontHead,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: ElevatedButton(
                                onPressed: _acceptReq,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kCyan3,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'Accept ✓',
                                  style: TextStyle(
                                    fontFamily: kFontHead,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
