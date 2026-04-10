import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/screens.dart';
import '../../services/routing_service.dart';
import '../../state/app_state.dart';
import '../../widgets/map_widget.dart';

class HomeScreen extends StatefulWidget {
  final Function(CScreen) onNav;
  const HomeScreen({super.key, required this.onNav});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _locText = 'Detecting location...';
  String _addr = 'Detecting...';
  final MapController _mapCtrl = MapController();
  LatLng _userPos = const LatLng(romeLat, romeLng);

  @override
  void initState() {
    super.initState();
    _detectLocation();
  }

  Future<void> _detectLocation() async {
    try {
      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever)
        return;
      final pos = await Geolocator.getCurrentPosition();
      final addr = await RoutingService.reverseGeo(pos.latitude, pos.longitude);
      if (!mounted) return;
      setState(() {
        _userPos = LatLng(pos.latitude, pos.longitude);
        _locText = addr;
        _addr = addr;
      });
      context.read<AppState>().setLocation(pos.latitude, pos.longitude);
      _mapCtrl.move(_userPos, 15);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Stack(
      children: [
        // Map (52% height)
        SizedBox(
          height: 640 * .52,
          child: Stack(
            children: [
              WashGoMap(
                center: _userPos,
                zoom: 14,
                controller: _mapCtrl,
                markers: [
                  userMarker(_userPos),
                  carMarker(LatLng(romeLat + .009, romeLng - .002)),
                  carMarker(LatLng(romeLat + .003, romeLng + .008)),
                  carMarker(LatLng(romeLat - .005, romeLng + .003)),
                ],
              ),
              // Location pill
              Positioned(
                top: 10,
                left: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.08),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'YOUR LOCATION',
                        style: TextStyle(
                          fontFamily: kFontHead,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: kMuted,
                          letterSpacing: .8,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _locText,
                        style: const TextStyle(
                          fontFamily: kFontHead,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: kText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Bottom sheet
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
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
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
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
                const SizedBox(height: 12),
                // Greeting
                RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Hey, ',
                        style: TextStyle(
                          fontFamily: kFontHead,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: kText,
                        ),
                      ),
                      TextSpan(
                        text: state.currentProfile?.firstName ?? 'there',
                        style: const TextStyle(
                          fontFamily: kFontHead,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: kCyan3,
                        ),
                      ),
                      const TextSpan(
                        text: ' 👋',
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                ),
                const Text(
                  'What do you need today?',
                  style: TextStyle(
                    color: kMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),

                // Service tabs
                Row(
                  children: [
                    _ServiceTab(
                      emoji: '🧺',
                      label: 'Laundry',
                      active: true,
                      onTap: () => widget.onNav(CScreen.items),
                    ),
                    const SizedBox(width: 8),
                    _ServiceTab(emoji: '⚡', label: 'Express', onTap: () {}),
                    const SizedBox(width: 8),
                    _ServiceTab(emoji: '🗓', label: 'Schedule', onTap: () {}),
                  ],
                ),
                const SizedBox(height: 10),

                // Address row
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: kBg,
                    border: Border.all(color: kBorder, width: 1.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: kCyan3,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'PICKUP ADDRESS',
                              style: TextStyle(
                                fontFamily: kFontHead,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: kMuted,
                                letterSpacing: .8,
                              ),
                            ),
                            Text(
                              _addr,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: kText,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const Text(
                        '›',
                        style: TextStyle(color: kMuted, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Quick grid
                Row(
                  children: [
                    _QuickTile(
                      emoji: '📦',
                      label: 'Track',
                      onTap: () => widget.onNav(CScreen.tracking),
                    ),
                    const SizedBox(width: 8),
                    _QuickTile(
                      emoji: '📋',
                      label: 'Orders',
                      onTap: () => widget.onNav(CScreen.orders),
                    ),
                    const SizedBox(width: 8),
                    _QuickTile(
                      emoji: '👤',
                      label: 'Profile',
                      onTap: () => widget.onNav(CScreen.profile),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ServiceTab extends StatelessWidget {
  final String emoji, label;
  final bool active;
  final VoidCallback onTap;
  const _ServiceTab({
    required this.emoji,
    required this.label,
    this.active = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            color: active ? kCyan3.withOpacity(.08) : kBg,
            border: Border.all(color: active ? kCyan3 : kBorder, width: 1.5),
            borderRadius: BorderRadius.circular(10),
            boxShadow: active
                ? [BoxShadow(color: kCyan3.withOpacity(.15), blurRadius: 10)]
                : null,
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: kFontHead,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: active ? kCyan3 : kMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickTile extends StatelessWidget {
  final String emoji, label;
  final VoidCallback onTap;
  const _QuickTile({
    required this.emoji,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: kBg,
            border: Border.all(color: kBorder),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: kFontHead,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: kMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
