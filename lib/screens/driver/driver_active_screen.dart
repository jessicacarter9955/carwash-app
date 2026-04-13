import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../services/order_service.dart';
import '../../services/routing_service.dart';
import '../../state/app_state.dart';
import '../../widgets/map_widget.dart';
import '../../widgets/app_toast.dart';

class DriverActiveScreen extends StatefulWidget {
  final VoidCallback onBack, onDelivery;
  const DriverActiveScreen({
    super.key,
    required this.onBack,
    required this.onDelivery,
  });

  @override
  State<DriverActiveScreen> createState() => _DriverActiveScreenState();
}

class _DriverActiveScreenState extends State<DriverActiveScreen> {
  List<LatLng> _routeCoords = [];

  @override
  void initState() {
    super.initState();
    _fetchRoute();
  }

  Future<void> _fetchRoute() async {
    final state = context.read<AppState>();
    try {
      final result = await RoutingService.fetchRoute(
        kRomeLat + 0.004,
        kRomeLng + 0.003,
        state.userLat,
        state.userLng,
      );
      if (mounted) {
        setState(() => _routeCoords = result.coords);
      }
    } catch (e) {
      // Fallback to straight line if routing fails
      if (mounted) {
        setState(() => _routeCoords = [
              LatLng(kRomeLat + 0.004, kRomeLng + 0.003),
              LatLng(state.userLat, state.userLng),
            ]);
      }
    }
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
              GestureDetector(
                onTap: widget.onBack,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: kBg,
                    border: Border.all(color: kBorder),
                    borderRadius: BorderRadius.circular(rSm),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    size: 14,
                    color: kText,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Active Job',
                  style: headStyle(size: 16, weight: FontWeight.w900),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: kCyan.withOpacity(0.1),
                  border: Border.all(color: kCyan.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.directions_car, size: 12, color: kCyan),
                    const SizedBox(width: 5),
                    Text(
                      'Car Pickup',
                      style: headStyle(
                        size: 11,
                        weight: FontWeight.w800,
                        color: kCyan,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── Map ───────────────────────────────────────────
        SizedBox(
          height: 220,
          child: WashGoMap(
            center: LatLng(kRomeLat + 0.004, kRomeLng + 0.003),
            interactive: false,
            markers: [
              carMarker(LatLng(kRomeLat + 0.004, kRomeLng + 0.003)),
              userMarker(LatLng(state.userLat, state.userLng)),
              hubMarker(LatLng(kHubLat, kHubLng)),
            ],
            polylines: [
              if (_routeCoords.length > 1)
                Polyline(
                  points: _routeCoords,
                  color: kCyan,
                  strokeWidth: 4,
                ),
            ],
          ),
        ),

        // ── Body ──────────────────────────────────────────
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),
            children: [
              // Customer card
              _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CUSTOMER',
                      style: headStyle(
                        size: 10,
                        weight: FontWeight.w800,
                        color: kMuted,
                      ).copyWith(letterSpacing: 0.6),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [kCyan, kMint],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: kCyan.withOpacity(0.3),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Demo Customer',
                                style: headStyle(
                                  size: 14,
                                  weight: FontWeight.w800,
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    size: 12,
                                    color: kYellow,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    '4.8 · Tap to call',
                                    style: bodyStyle(size: 11, color: kMuted),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () =>
                              showToast(context, 'Calling customer...'),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: kCyan.withOpacity(0.1),
                              border: Border.all(color: kCyan.withOpacity(0.3)),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.phone,
                              size: 16,
                              color: kCyan,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Divider(height: 1, color: kBorder),
                    const SizedBox(height: 12),
                    // Pickup
                    _LocationRow(
                      icon: Icons.location_on,
                      color: kCyan,
                      label: 'PICKUP',
                      value: 'Via Roma 15, Rome',
                    ),
                    const SizedBox(height: 10),
                    // Drop-off
                    _LocationRow(
                      icon: Icons.local_car_wash,
                      color: kOrange,
                      label: 'DROP-OFF',
                      value: 'Car Wash Hub',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 4),

              // Status update card
              _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'STATUS UPDATE',
                      style: headStyle(
                        size: 10,
                        weight: FontWeight.w800,
                        color: kMuted,
                      ).copyWith(letterSpacing: 0.6),
                    ),
                    const SizedBox(height: 12),
                    _StatusBtn(
                      label: 'Arrived at Pickup',
                      icon: Icons.location_on,
                      color: kCyan,
                      onTap: () async {
                        showToast(context, '📍 Status: pickup');
                        final o = state.currentOrder;
                        if (o != null) {
                          await OrderService.updateOrderStatus(o.id, 'pickup');
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    _StatusBtn(
                      label: 'Car Collected',
                      icon: Icons.directions_car,
                      color: kMint,
                      onTap: () async {
                        showToast(context, '🚗 Status: washing');
                        final o = state.currentOrder;
                        if (o != null) {
                          await OrderService.updateOrderStatus(o.id, 'washing');
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    _StatusBtn(
                      label: 'Wash Complete',
                      icon: Icons.auto_awesome,
                      color: kOrange,
                      onTap: () => showToast(context, '✨ Status: ready'),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          showToast(context, '✅ Delivered!');
                          final o = state.currentOrder;
                          if (o != null) {
                            await OrderService.updateOrderStatus(
                                o.id, 'delivered');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kCyan,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(rMd),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Mark Delivered',
                              style: headStyle(
                                size: 14,
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
              ),

              const SizedBox(height: 4),

              // Earnings card
              _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'YOUR EARNINGS',
                      style: headStyle(
                        size: 10,
                        weight: FontWeight.w800,
                        color: kMuted,
                      ).copyWith(letterSpacing: 0.6),
                    ),
                    const SizedBox(height: 12),
                    _EarningsRow(
                      label: 'Car Wash Pickup',
                      value: '€12.50',
                      bold: false,
                    ),
                    const SizedBox(height: 4),
                    _EarningsRow(
                      label: 'WashGo fee (15%)',
                      value: '-€1.88',
                      muted: true,
                    ),
                    const SizedBox(height: 8),
                    const Divider(height: 1, color: kBorder),
                    const SizedBox(height: 8),
                    _EarningsRow(
                      label: 'Net earnings',
                      value: '€10.62',
                      bold: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── Bottom bar ────────────────────────────────────
        Container(
          padding: EdgeInsets.fromLTRB(
            14,
            12,
            14,
            MediaQuery.of(context).padding.bottom + 12,
          ),
          decoration: BoxDecoration(
            color: kSurface,
            border: Border(top: BorderSide(color: kBorder)),
            boxShadow: shadowMd,
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onBack,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: kBorder),
                    foregroundColor: kText,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(rMd),
                    ),
                  ),
                  child: Text(
                    'Back',
                    style: headStyle(size: 13, weight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: widget.onDelivery,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kCyan,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(rMd),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Arrived at Pickup',
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
        ),
      ],
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────
class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: kSurface,
          border: Border.all(color: kBorder),
          borderRadius: BorderRadius.circular(rMd),
          boxShadow: shadowXs,
        ),
        child: child,
      );
}

class _LocationRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  const _LocationRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(rSm),
          ),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: headStyle(
                size: 9,
                weight: FontWeight.w800,
                color: kMuted,
              ).copyWith(letterSpacing: 0.5),
            ),
            Text(value, style: bodyStyle(size: 13, weight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}

class _StatusBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _StatusBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withOpacity(0.35)),
          backgroundColor: color.withOpacity(0.07),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(rSm),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: headStyle(size: 12, weight: FontWeight.w800, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _EarningsRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final bool muted;
  const _EarningsRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: bold
              ? headStyle(size: 13, weight: FontWeight.w800)
              : bodyStyle(
                  size: 12,
                  color: muted ? kMuted : kText,
                  weight: FontWeight.w500,
                ),
        ),
        Text(
          value,
          style: bold
              ? headStyle(size: 16, weight: FontWeight.w900, color: kCyan)
              : bodyStyle(
                  size: 12,
                  color: muted ? kMuted : kText,
                  weight: FontWeight.w600,
                ),
        ),
      ],
    );
  }
}
