import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../services/order_service.dart';
import '../../state/app_state.dart';
import '../../widgets/map_widget.dart';
import '../../widgets/toast_overlay.dart';
import '../../widgets/shared.dart';

class DriverActiveScreen extends StatelessWidget {
  final VoidCallback onBack, onDelivery;
  const DriverActiveScreen({
    super.key,
    required this.onBack,
    required this.onDelivery,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Column(
      children: [
        // Topbar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: const BoxDecoration(
            color: kSurface,
            border: Border(bottom: BorderSide(color: kBorder)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Active Job',
                style: TextStyle(
                  fontFamily: kFontHead,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: kCyan3.withOpacity(.12),
                  border: Border.all(color: kCyan3.withOpacity(.3)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  '🧺 Laundry Pickup',
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
        ),
        // Map
        SizedBox(
          height: 220,
          child: WashGoMap(
            center: LatLng(romeLat + .004, romeLng + .003),
            interactive: false,
            markers: [
              carMarker(LatLng(romeLat + .004, romeLng + .003)),
              userMarker(LatLng(state.userLat, state.userLng)),
            ],
            polylines: [
              Polyline(
                points: [
                  LatLng(romeLat + .004, romeLng + .003),
                  LatLng(state.userLat, state.userLng),
                ],
                color: kCyan3,
                strokeWidth: 4,
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 100),
            children: [
              // Customer card
              AppCard(
                child: Column(
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'CUSTOMER',
                        style: TextStyle(
                          fontFamily: kFontHead,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: kMuted,
                          letterSpacing: .5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(colors: [kCyan3, kMint]),
                          ),
                          child: const Center(
                            child: Text('👤', style: TextStyle(fontSize: 18)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Demo Customer',
                                style: TextStyle(
                                  fontFamily: kFontHead,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                '📞 Tap to call',
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
                          onTap: () => showToast('📞 Calling customer...'),
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: kBg,
                              border: Border.all(color: kBorder),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Text('📞', style: TextStyle(fontSize: 15)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20, color: kBorder),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'PICKUP',
                        style: TextStyle(
                          fontFamily: kFontHead,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: kMuted,
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      '📍 Via Roma 15, Rome',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'DROP-OFF',
                        style: TextStyle(
                          fontFamily: kFontHead,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: kMuted,
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      '🏭 WashGo Hub',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // Status update
              AppCard(
                child: Column(
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'STATUS UPDATE',
                        style: TextStyle(
                          fontFamily: kFontHead,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: kMuted,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _StatusBtn(
                      label: '✓ Arrived at Pickup',
                      color: kCyan3,
                      onTap: () async {
                        showToast('✅ Status: pickup');
                        final o = state.currentOrder;
                        if (o != null)
                          await OrderService.updateStatus(o.id, 'pickup');
                      },
                    ),
                    const SizedBox(height: 6),
                    _StatusBtn(
                      label: '🧺 Items Collected',
                      color: kMint2,
                      onTap: () async {
                        showToast('✅ Status: washing');
                        final o = state.currentOrder;
                        if (o != null)
                          await OrderService.updateStatus(o.id, 'washing');
                      },
                    ),
                    const SizedBox(height: 6),
                    _StatusBtn(
                      label: '📦 Ready for Delivery',
                      color: kOrange,
                      onTap: () {
                        showToast('✅ Status: ready');
                      },
                    ),
                    const SizedBox(height: 6),
                    ElevatedButton(
                      onPressed: () async {
                        showToast('✅ Delivered!');
                        final o = state.currentOrder;
                        if (o != null)
                          await OrderService.updateStatus(o.id, 'delivered');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kCyan3,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '✅ Mark Delivered',
                        style: TextStyle(
                          fontFamily: kFontHead,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Earnings
              AppCard(
                child: Column(
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'YOUR EARNINGS',
                        style: TextStyle(
                          fontFamily: kFontHead,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: kMuted,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Laundry Pickup',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Text(
                          '\$12.50',
                          style: TextStyle(
                            fontFamily: kFontHead,
                            fontWeight: FontWeight.w800,
                            color: kCyan3,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'WashGo fee (15%)',
                          style: TextStyle(
                            fontSize: 12,
                            color: kMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Text(
                          '-\$1.88',
                          style: TextStyle(
                            fontSize: 12,
                            color: kMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: kBorder),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Net',
                          style: TextStyle(
                            fontFamily: kFontHead,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Text(
                          '\$10.62',
                          style: TextStyle(
                            fontFamily: kFontHead,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: kCyan3,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        BottomBar(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onBack,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: kBorder),
                    foregroundColor: kText,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('← Back'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: onDelivery,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kCyan3,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Arrived at Pickup ✓',
                    style: TextStyle(
                      fontFamily: kFontHead,
                      fontWeight: FontWeight.w800,
                    ),
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

class _StatusBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _StatusBtn({
    required this.label,
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
          side: BorderSide(color: color.withOpacity(.3)),
          backgroundColor: color.withOpacity(.1),
          padding: const EdgeInsets.symmetric(vertical: 11),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: kFontHead,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ),
    );
  }
}
