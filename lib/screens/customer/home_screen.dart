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
  String _locText = 'Tap to set your location';
  String _addr = 'Tap to set your location';
  final MapController _mapCtrl = MapController();
  LatLng _userPos = const LatLng(romeLat, romeLng);
  bool _locationDenied = false;
  bool _locLoading = true;

  @override
  void initState() {
    super.initState();
    _detectLocation();
  }

  Future<void> _detectLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() {
          _locationDenied = true;
          _locLoading = false;
          _locText = 'Location not available';
          _addr = 'Enter address below';
        });
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final addr = await RoutingService.reverseGeo(pos.latitude, pos.longitude);
      if (!mounted) return;
      setState(() {
        _userPos = LatLng(pos.latitude, pos.longitude);
        _locText = addr;
        _addr = addr;
        _locLoading = false;
        _locationDenied = false;
      });
      context.read<AppState>().setLocation(pos.latitude, pos.longitude, address: addr);
      _mapCtrl.move(_userPos, 15);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _locationDenied = true;
        _locLoading = false;
        _locText = 'Could not detect location';
        _addr = 'Enter address below';
      });
    }
  }

  void _showAddressDialog() {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          16, 16, 16,
          MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: kBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'PICKUP ADDRESS',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: kMuted,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: ctrl,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              style: const TextStyle(fontSize: 14, color: kText),
              decoration: InputDecoration(
                hintText: 'e.g. 123 Main Street, City',
                hintStyle: const TextStyle(color: kMuted),
                filled: true,
                fillColor: kBg,
                prefixIcon: const Icon(Icons.location_on_outlined, color: kCyan3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: kBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: kBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: kCyan3, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final text = ctrl.text.trim();
                  if (text.isEmpty) return;
                  setState(() {
                    _addr = text;
                    _locText = text;
                    _locationDenied = false;
                  });
                  context.read<AppState>().setAddress(text);
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kCyan3,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Confirm Address',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final screenH = MediaQuery.of(context).size.height;
    final safeBottom = MediaQuery.of(context).padding.bottom;

    return Stack(
      children: [
        // Map — top 48% of screen
        SizedBox(
          height: screenH * .48,
          child: Stack(
            children: [
              WashGoMap(
                center: _userPos,
                zoom: 14,
                controller: _mapCtrl,
                markers: [
                  userMarker(_userPos),
                  carMarker(LatLng(_userPos.latitude + .009, _userPos.longitude - .002)),
                  carMarker(LatLng(_userPos.latitude + .003, _userPos.longitude + .008)),
                  carMarker(LatLng(_userPos.latitude - .005, _userPos.longitude + .003)),
                ],
              ),
              // Location pill on map
              Positioned(
                top: 10,
                left: 12,
                right: 12,
                child: GestureDetector(
                  onTap: _showAddressDialog,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .95),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: kBorder),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: .08),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _locLoading
                              ? Icons.location_searching
                              : _locationDenied
                                  ? Icons.location_off_outlined
                                  : Icons.location_on,
                          color: _locationDenied ? kOrange : kCyan3,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _locLoading ? 'Detecting location...' : _locText,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: kText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: kMuted, size: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Bottom sheet — fills remaining 52%
        Positioned(
          top: screenH * .44,
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            decoration: BoxDecoration(
              color: kSurface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
              border: const Border(top: BorderSide(color: kBorder)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .08),
                  blurRadius: 24,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(14, 14, 14, safeBottom + 16),
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
                  Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(text: 'Hey, '),
                        TextSpan(
                          text: state.currentProfile?.firstName ?? 'there',
                          style: const TextStyle(color: kCyan3),
                        ),
                        const TextSpan(text: ' 👋'),
                      ],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: kText,
                      ),
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
                  const SizedBox(height: 14),

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
                  const SizedBox(height: 12),

                  // Address row — tappable
                  GestureDetector(
                    onTap: _showAddressDialog,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: kBg,
                        border: Border.all(
                          color: _locationDenied ? kOrange.withValues(alpha: .5) : kBorder,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _locationDenied ? kOrange : kCyan3,
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
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: kMuted,
                                    letterSpacing: .8,
                                  ),
                                ),
                                Text(
                                  _addr,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _locationDenied ? kOrange : kText,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.edit_outlined,
                            color: kMuted,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

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
            color: active ? kCyan3.withValues(alpha: .08) : kBg,
            border: Border.all(color: active ? kCyan3 : kBorder, width: 1.5),
            borderRadius: BorderRadius.circular(10),
            boxShadow: active
                ? [BoxShadow(color: kCyan3.withValues(alpha: .15), blurRadius: 10)]
                : null,
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
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
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: kBg,
            border: Border.all(color: kBorder),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
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
