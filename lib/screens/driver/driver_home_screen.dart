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
import '../../widgets/app_toast.dart';
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

  String _reqCust = 'Alex M.';
  String _reqPrice = '€12.50';
  String _reqDist = '2.3 km · est. 8 min';

  void _showIncoming() {
    final names = ['Alex M.', 'Sara L.', 'Marco B.', 'Anna T.'];
    final price = (8 + (DateTime.now().millisecond / 1000 * 12))
        .toStringAsFixed(2);
    final dist = (0.5 + (DateTime.now().second / 60 * 5)).toStringAsFixed(1);
    setState(() {
      _showReq = true;
      _reqCust = names[DateTime.now().second % names.length];
      _reqPrice = '€$price';
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
    showToast(context, '❌ Request declined');
  }

  void _acceptReq() {
    _cdTimer?.cancel();
    setState(() => _showReq = false);
    showToast(context, '✅ Job accepted!');
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
        // ── Top bar ───────────────────────────────────────
        Container(
          padding: EdgeInsets.fromLTRB(
            14,
            MediaQuery.of(context).padding.top + 10,
            14,
            10,
          ),
          decoration: BoxDecoration(
            color: kSurface,
            border: Border(bottom: BorderSide(color: kBorder)),
            boxShadow: shadowXs,
          ),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [kCyan, kMint]),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: kCyan.withOpacity(0.3), blurRadius: 8),
                  ],
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.currentProfile?.fullName ?? 'Driver',
                      style: headStyle(size: 15, weight: FontWeight.w900),
                    ),
                    Text(
                      'WashGo Driver',
                      style: bodyStyle(size: 11, color: kMuted),
                    ),
                  ],
                ),
              ),
              // Online toggle
              GestureDetector(
                onTap: () async {
                  state.setDriverOnline(!state.driverOnline);
                  if (state.currentUserId != null) {
                    await DriverService.setOnline(
                      state.currentUserId!,
                      state.driverOnline,
                    );
                  }
                  if (mounted) {
                    showToast(
                      context,
                      state.driverOnline
                          ? '🟢 You are now online'
                          : '🔴 You went offline',
                    );
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: state.driverOnline ? kMint.withOpacity(0.1) : kBg,
                    border: Border.all(
                      color: state.driverOnline
                          ? kMint.withOpacity(0.4)
                          : kBorder,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: state.driverOnline ? kMint2 : kMuted,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        state.driverOnline ? 'Online' : 'Offline',
                        style: headStyle(
                          size: 12,
                          weight: FontWeight.w800,
                          color: state.driverOnline ? kMint2 : kMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Switch to customer
              GestureDetector(
                onTap: () => context.go('/home'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: kBg,
                    border: Border.all(color: kBorder),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.swap_horiz, size: 14, color: kMuted),
                      const SizedBox(width: 4),
                      Text(
                        'Customer',
                        style: headStyle(
                          size: 11,
                          weight: FontWeight.w700,
                          color: kMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Map + overlay ─────────────────────────────────
        Expanded(
          child: Stack(
            children: [
              WashGoMap(
                center: LatLng(kDefaultLat + 0.005, kDefaultLng),
                zoom: 14,
                markers: [
                  carMarker(LatLng(kDefaultLat + 0.004, kDefaultLng + 0.003)),
                  Marker(
                    point: LatLng(kDefaultLat + 0.008, kDefaultLng - 0.005),
                    width: 32,
                    height: 32,
                    child: Container(
                      decoration: BoxDecoration(
                        color: kCyan,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: kCyan.withOpacity(0.4),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.directions_car,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              // Bottom gradient overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [kBg, kBg.withOpacity(0.95), Colors.transparent],
                      stops: const [0.0, 0.6, 1.0],
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(14, 20, 14, 16),
                  child: Column(
                    children: [
                      // Stats
                      Row(
                        children: [
                          StatTile(value: '€0', label: 'Today'),
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
                            child: OutlinedButton.icon(
                              onPressed: () => widget.onNav(DScreen.earnings),
                              icon: const Icon(Icons.bar_chart, size: 16),
                              label: Text(
                                'Earnings',
                                style: headStyle(
                                  size: 12,
                                  weight: FontWeight.w700,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: kBorder),
                                foregroundColor: kText,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(rSm),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _showIncoming,
                              icon: const Icon(
                                Icons.notifications_active,
                                size: 16,
                              ),
                              label: Text(
                                'Simulate Job',
                                style: headStyle(
                                  size: 12,
                                  weight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kCyan,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(rSm),
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

              // ── Incoming request card ─────────────────
              if (_showReq)
                Positioned(
                  bottom: 100,
                  left: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: kSurface,
                      border: Border.all(color: kBorder, width: 1.5),
                      borderRadius: BorderRadius.circular(rXl),
                      boxShadow: shadowLg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Badge
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: kCyan.withOpacity(0.1),
                                border: Border.all(
                                  color: kCyan.withOpacity(0.3),
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.directions_car,
                                    size: 11,
                                    color: kCyan,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'CAR PICKUP',
                                    style: headStyle(
                                      size: 9,
                                      weight: FontWeight.w800,
                                      color: kCyan,
                                    )..copyWith(letterSpacing: 0.8),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            // Countdown
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: kOrange.withOpacity(0.1),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: kOrange.withOpacity(0.4),
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '$_countdown',
                                  style: headStyle(
                                    size: 16,
                                    weight: FontWeight.w900,
                                    color: kOrange,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _reqCust,
                          style: headStyle(size: 18, weight: FontWeight.w900),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 13,
                              color: kMuted,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'Via Roma 15 → Car Wash Hub',
                                style: bodyStyle(size: 12, color: kMuted),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _reqPrice,
                                    style: headStyle(
                                      size: 28,
                                      weight: FontWeight.w900,
                                      color: kCyan,
                                    ),
                                  ),
                                  Text(
                                    _reqDist,
                                    style: bodyStyle(size: 11, color: kMuted),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _declineReq,
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: kRed.withOpacity(0.5),
                                  ),
                                  foregroundColor: kRed,
                                  backgroundColor: kRed.withOpacity(0.05),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 13,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(rSm),
                                  ),
                                ),
                                child: Text(
                                  'Decline',
                                  style: headStyle(
                                    size: 13,
                                    weight: FontWeight.w800,
                                    color: kRed,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 2,
                              child: ElevatedButton(
                                onPressed: _acceptReq,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kCyan,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 13,
                                  ),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(rSm),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.check_circle, size: 16),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Accept',
                                      style: headStyle(
                                        size: 13,
                                        weight: FontWeight.w800,
                                        color: Colors.white,
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
            ],
          ),
        ),
      ],
    );
  }
}
