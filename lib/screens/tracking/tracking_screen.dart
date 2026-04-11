import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../core/constants.dart';
import '../../providers/order_provider.dart';
import '../../providers/tracking_provider.dart';
import '../../widgets/app_toast.dart';

class TrackingScreen extends ConsumerWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracking = ref.watch(trackingProvider);
    final order = ref.watch(orderProvider).currentOrder;

    // Navigate to rating when delivered
    ref.listen<TrackingState>(trackingProvider, (prev, next) {
      if (next.phase == TrackingPhase.delivered &&
          prev?.phase != TrackingPhase.delivered) {
        Future.delayed(const Duration(seconds: 2), () {
          if (context.mounted) context.go('/rating');
        });
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          // Map
          FlutterMap(
            options: MapOptions(
              center: tracking.userPos,
              zoom: 14,
              interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.washgo.app',
              ),
              PolylineLayer(
                polylines: [
                  if (tracking.routeCoords.isNotEmpty)
                    Polyline(
                      points: tracking.routeCoords,
                      color: tracking.phase == TrackingPhase.toHub
                          ? kMint
                          : kCyan,
                      strokeWidth: 3,
                    ),
                ],
              ),
              MarkerLayer(
                markers: [
                  // User marker
                  Marker(
                    point: tracking.userPos,
                    width: 32,
                    height: 32,
                    child: Container(
                      decoration: BoxDecoration(
                        color: kMint,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: kMint.withOpacity(0.4),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                  // Driver marker
                  Marker(
                    point: tracking.driverPos,
                    width: 40,
                    height: 40,
                    child: Container(
                      decoration: BoxDecoration(
                        color: kCyan,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: kCyan.withOpacity(0.4),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: const Text('🚗', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                  // Hub marker
                  if (tracking.phase == TrackingPhase.toHub ||
                      tracking.phase == TrackingPhase.washing)
                    Marker(
                      point: const LatLng(kHubLat, kHubLng),
                      width: 36,
                      height: 36,
                      child: Container(
                        decoration: BoxDecoration(
                          color: kOrange,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Text('🏭', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                ],
              ),
            ],
          ),

          // Close + ETA top overlay
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 12,
            right: 12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    ref.read(trackingProvider.notifier).stopTracking();
                    context.go('/home');
                  },
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: kSurface,
                      shape: BoxShape.circle,
                      boxShadow: shadowSm,
                    ),
                    child: const Icon(Icons.close, size: 16),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    border: Border.all(color: kBorder),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: shadowSm,
                  ),
                  child: Text(
                    tracking.phase == TrackingPhase.delivered
                        ? '🏠 Delivered!'
                        : tracking.phase == TrackingPhase.washing
                        ? '🧺 Washing...'
                        : tracking.phase == TrackingPhase.atPickup
                        ? '📍 Arrived!'
                        : '🕐 ${tracking.etaMinutes} min away',
                    style: headStyle(size: 12, weight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),

          // Bottom tracking sheet
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.45,
              ),
              decoration: BoxDecoration(
                color: kSurface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(22),
                ),
                border: Border(top: BorderSide(color: kBorder)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 24,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 32,
                        height: 4,
                        decoration: BoxDecoration(
                          color: kBorder2,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Driver info
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [kCyan, kMint],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: kCyan.withOpacity(0.3),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.directions_car,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tracking.driverName,
                                style: headStyle(
                                  size: 14,
                                  weight: FontWeight.w800,
                                ),
                              ),
                              Row(
                                children: [
                                  const Text(
                                    '★★★★★',
                                    style: TextStyle(
                                      color: kYellow,
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${tracking.driverRating}',
                                    style: bodyStyle(size: 11, color: kMuted),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            _ActionBtn(
                              icon: Icons.phone,
                              onTap: () =>
                                  showToast(context, 'Calling driver...'),
                            ),
                            const SizedBox(width: 8),
                            _ActionBtn(
                              icon: Icons.message,
                              onTap: () => showToast(context, 'Chat opened'),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: kCyan.withOpacity(0.12),
                                border: Border.all(
                                  color: kCyan.withOpacity(0.3),
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                tracking.driverPlate,
                                style: headStyle(
                                  size: 11,
                                  weight: FontWeight.w800,
                                  color: kCyan3,
                                ).copyWith(letterSpacing: 0.5),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Order timeline
                    _OrderTimeline(phase: tracking.phase, order: order),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: kBg,
          shape: BoxShape.circle,
          border: Border.all(color: kBorder),
          boxShadow: shadowXs,
        ),
        child: Center(child: Icon(icon, size: 16, color: kText)),
      ),
    );
  }
}

class _OrderTimeline extends StatelessWidget {
  final TrackingPhase phase;
  final dynamic order;
  const _OrderTimeline({required this.phase, required this.order});

  @override
  Widget build(BuildContext context) {
    final steps = [
      {
        'id': 'confirmed',
        'label': 'Driver Confirmed',
        'sub': 'Driver accepted your order',
        'icon': 'check',
      },
      {
        'id': 'enroute',
        'label': 'Driver en Route',
        'sub': 'Approaching your location',
        'icon': 'directions_car',
      },
      {
        'id': 'pickup',
        'label': 'Pickup',
        'sub': 'Your location',
        'icon': 'location_on',
      },
      {
        'id': 'washing',
        'label': 'Washing',
        'sub': 'At the facility',
        'icon': 'local_laundry_service',
      },
      {
        'id': 'delivered',
        'label': 'Delivered',
        'sub': 'Completed',
        'icon': 'home',
      },
    ];

    int activeIdx;
    switch (phase) {
      case TrackingPhase.idle:
        activeIdx = -1;
        break;
      case TrackingPhase.toPickup:
        activeIdx = 1;
        break;
      case TrackingPhase.atPickup:
        activeIdx = 2;
        break;
      case TrackingPhase.toHub:
        activeIdx = 2;
        break;
      case TrackingPhase.washing:
        activeIdx = 3;
        break;
      case TrackingPhase.delivered:
        activeIdx = 4;
        break;
    }

    return Column(
      children: steps.asMap().entries.map((entry) {
        final i = entry.key;
        final step = entry.value;
        final isDone = i < activeIdx;
        final isActive = i == activeIdx;

        return _TimelineStep(
          icon: isDone ? 'check' : step['icon']!,
          label: step['label']!,
          sub: step['sub']!,
          isDone: isDone,
          isActive: isActive,
          isLast: i == steps.length - 1,
        );
      }).toList(),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  final String icon, label, sub;
  final bool isDone, isActive, isLast;
  const _TimelineStep({
    required this.icon,
    required this.label,
    required this.sub,
    required this.isDone,
    required this.isActive,
    required this.isLast,
  });

  IconData _getIconFromName(String iconName) {
    switch (iconName) {
      case 'directions_car':
        return Icons.directions_car;
      case 'location_on':
        return Icons.location_on;
      case 'local_laundry_service':
        return Icons.local_laundry_service;
      case 'home':
        return Icons.home;
      default:
        return Icons.circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    Color dotBorder = isDone
        ? kCyan
        : isActive
        ? kMint
        : kBorder2;
    Color dotBg = isDone
        ? kCyan.withOpacity(0.12)
        : isActive
        ? kMint.withOpacity(0.12)
        : kBg;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: dotBg,
              shape: BoxShape.circle,
              border: Border.all(color: dotBorder, width: 2),
            ),
            child: Center(
              child: isDone
                  ? const Icon(Icons.check, size: 18, color: kCyan)
                  : Icon(_getIconFromName(icon), size: 14, color: kText),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 5, bottom: isLast ? 0 : 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: headStyle(size: 12, weight: FontWeight.w700),
                  ),
                  Text(sub, style: bodyStyle(size: 10, color: kMuted)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
