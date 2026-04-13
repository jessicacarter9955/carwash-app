import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../core/constants.dart';
import '../../providers/order_provider.dart';
import '../../providers/tracking_provider.dart';
import '../../widgets/app_toast.dart';

class TrackingScreen extends ConsumerStatefulWidget {
  const TrackingScreen({super.key});

  @override
  ConsumerState<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends ConsumerState<TrackingScreen> {
  final MapController _mapController = MapController();
  bool _mapReady = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ref.listen<TrackingState>(trackingProvider, (prev, next) {
      // Auto-navigate to rating on delivered
      if (next.phase == TrackingPhase.delivered &&
          prev?.phase != TrackingPhase.delivered) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) context.go('/rating');
        });
      }

      // Keep map centered on driver
      if (_mapReady && prev?.driverPos != next.driverPos) {
        _mapController.move(next.driverPos, 15);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tracking = ref.watch(trackingProvider);
    final order = ref.watch(orderProvider).currentOrder;

    return Scaffold(
      body: Stack(
        children: [
          // ── Map ──────────────────────────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: tracking.driverPos,
              zoom: 15,
              interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              onMapReady: () => setState(() => _mapReady = true),
            ),
            children: [
              TileLayer(
                urlTemplate: mapboxToken.isEmpty
                    ? 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'
                    : 'https://api.mapbox.com/styles/v1/mapbox/streets-v12/tiles/{z}/{x}/{y}?access_token=$mapboxToken',
                userAgentPackageName: 'com.washgo.app',
              ),

              // ── Polylines ─────────────────────────────────
              PolylineLayer(
                polylines: [
                  // Travelled path — grey dashed feel
                  if (tracking.travelledCoords.length > 1)
                    Polyline(
                      points: tracking.travelledCoords,
                      color: Colors.grey.shade400,
                      strokeWidth: 3,
                    ),
                  // Remaining path — blue
                  if (tracking.routeCoords.isNotEmpty &&
                      tracking.simIndex < tracking.routeCoords.length)
                    Polyline(
                      points: tracking.routeCoords.sublist(tracking.simIndex),
                      color: kCyan,
                      strokeWidth: 4,
                    ),
                ],
              ),

              // ── Markers ───────────────────────────────────
              MarkerLayer(
                markers: [
                  // User marker
                  Marker(
                    point: tracking.userPos,
                    width: 36,
                    height: 36,
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
                        size: 16,
                      ),
                    ),
                  ),

                  // Driver marker — car icon, blue
                  Marker(
                    point: tracking.driverPos,
                    width: 32,
                    height: 32,
                    child: const Icon(
                      Icons.directions_car,
                      color: kCyan,
                      size: 24,
                    ),
                  ),

                  // Washing facility marker
                  Marker(
                    point: tracking.hubPos,
                    width: 44,
                    height: 44,
                    child: Column(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: kOrange,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: kOrange.withOpacity(0.4),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.local_car_wash,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          // ── Top bar ───────────────────────────────────────
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
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: kSurface,
                      shape: BoxShape.circle,
                      boxShadow: shadowSm,
                    ),
                    child: const Icon(Icons.close, size: 18, color: kText),
                  ),
                ),
                _PhaseChip(phase: tracking.phase, eta: tracking.etaMinutes),
              ],
            ),
          ),

          // ── Bottom sheet ──────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.48,
              ),
              decoration: BoxDecoration(
                color: kSurface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
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
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: kBorder2,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Driver row
                    _DriverRow(tracking: tracking),
                    const SizedBox(height: 14),
                    const Divider(height: 1, color: kBorder),
                    const SizedBox(height: 14),

                    // Timeline
                    _OrderTimeline(phase: tracking.phase),

                    // Return button (only after delivered)
                    if (tracking.phase == TrackingPhase.delivered) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ref
                                .read(trackingProvider.notifier)
                                .startReturnToUser();
                            showToast(
                              context,
                              '🚗 Driver returning your items!',
                            );
                          },
                          icon: const Icon(Icons.replay, size: 16),
                          label: const Text('Request Return Delivery'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: kCyan,
                            side: const BorderSide(color: kCyan),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(rMd),
                            ),
                          ),
                        ),
                      ),
                    ],
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

// ── Phase chip ────────────────────────────────────────────────
class _PhaseChip extends StatelessWidget {
  final TrackingPhase phase;
  final int eta;
  const _PhaseChip({required this.phase, required this.eta});

  @override
  Widget build(BuildContext context) {
    String label;
    Color color;
    IconData icon;

    switch (phase) {
      case TrackingPhase.toPickup:
        label = '$eta min away';
        color = kCyan;
        icon = Icons.directions_car;
        break;
      case TrackingPhase.atPickup:
        label = 'Driver arrived!';
        color = kMint;
        icon = Icons.location_on;
        break;
      case TrackingPhase.toHub:
        label = 'Heading to facility';
        color = kOrange;
        icon = Icons.local_car_wash;
        break;
      case TrackingPhase.washing:
        label = 'Washing in progress';
        color = kOrange;
        icon = Icons.water_drop;
        break;
      case TrackingPhase.delivered:
        label = 'Done!';
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      default:
        label = 'Tracking...';
        color = kMuted;
        icon = Icons.radio_button_checked;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: color.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(20),
        boxShadow: shadowSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: headStyle(size: 12, weight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }
}

// ── Driver row ────────────────────────────────────────────────
class _DriverRow extends StatelessWidget {
  final TrackingState tracking;
  const _DriverRow({required this.tracking});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [kCyan, kMint]),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: kCyan.withOpacity(0.3), blurRadius: 10),
            ],
          ),
          child: const Icon(
            Icons.directions_car,
            size: 22,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tracking.driverName,
                style: headStyle(size: 14, weight: FontWeight.w800),
              ),
              Row(
                children: [
                  ...List.generate(
                    5,
                    (i) => Icon(
                      Icons.star_rounded,
                      size: 12,
                      color: i < tracking.driverRating.round()
                          ? kYellow
                          : kBorder2,
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
        // Plate
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: kCyan.withOpacity(0.1),
            border: Border.all(color: kCyan.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(rSm),
          ),
          child: Text(
            tracking.driverPlate,
            style: headStyle(
              size: 11,
              weight: FontWeight.w800,
              color: kCyan3,
            ).copyWith(letterSpacing: 0.8),
          ),
        ),
        const SizedBox(width: 8),
        // Phone
        _ActionBtn(
          icon: Icons.phone,
          onTap: () => showToast(context as BuildContext, 'Calling...'),
        ),
      ],
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
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: kBg,
          shape: BoxShape.circle,
          border: Border.all(color: kBorder),
          boxShadow: shadowXs,
        ),
        child: Icon(icon, size: 16, color: kText),
      ),
    );
  }
}

// ── Timeline ──────────────────────────────────────────────────
class _OrderTimeline extends StatelessWidget {
  final TrackingPhase phase;
  const _OrderTimeline({required this.phase});

  @override
  Widget build(BuildContext context) {
    final steps = [
      {
        'phase': TrackingPhase.toPickup,
        'label': 'Driver en Route',
        'sub': 'Heading to your location',
        'icon': Icons.directions_car,
      },
      {
        'phase': TrackingPhase.atPickup,
        'label': 'Pickup',
        'sub': 'Driver at your location',
        'icon': Icons.location_on,
      },
      {
        'phase': TrackingPhase.toHub,
        'label': 'To Wash Facility',
        'sub': 'Heading to washing facility',
        'icon': Icons.local_car_wash,
      },
      {
        'phase': TrackingPhase.washing,
        'label': 'Washing',
        'sub': 'Being cleaned at facility',
        'icon': Icons.water_drop,
      },
      {
        'phase': TrackingPhase.delivered,
        'label': 'Complete',
        'sub': 'All done!',
        'icon': Icons.check_circle,
      },
    ];

    final phaseIndex = TrackingPhase.values.indexOf(phase);

    return Column(
      children: steps.asMap().entries.map((entry) {
        final i = entry.key;
        final step = entry.value;
        final stepPhaseIndex = TrackingPhase.values.indexOf(
          step['phase'] as TrackingPhase,
        );
        final isDone = phaseIndex > stepPhaseIndex;
        final isActive = phaseIndex == stepPhaseIndex;
        final isLast = i == steps.length - 1;

        return _TimelineStep(
          icon: step['icon'] as IconData,
          label: step['label'] as String,
          sub: step['sub'] as String,
          isDone: isDone,
          isActive: isActive,
          isLast: isLast,
        );
      }).toList(),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  final bool isDone;
  final bool isActive;
  final bool isLast;

  const _TimelineStep({
    required this.icon,
    required this.label,
    required this.sub,
    required this.isDone,
    required this.isActive,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final Color dotColor = isDone
        ? kCyan
        : isActive
            ? kOrange
            : kBorder2;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: isDone
                      ? kCyan.withOpacity(0.12)
                      : isActive
                          ? kOrange.withOpacity(0.12)
                          : kBg,
                  shape: BoxShape.circle,
                  border: Border.all(color: dotColor, width: 2),
                ),
                child: Icon(
                  isDone ? Icons.check : icon,
                  size: 16,
                  color: dotColor,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isDone ? kCyan.withOpacity(0.3) : kBorder,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 7, bottom: isLast ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: headStyle(
                      size: 13,
                      weight: isActive ? FontWeight.w800 : FontWeight.w600,
                      color: isActive ? kText : kMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(sub, style: bodyStyle(size: 11, color: kMuted)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
