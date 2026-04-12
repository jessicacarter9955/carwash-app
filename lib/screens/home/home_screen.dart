import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants.dart';
import '../../providers/auth_providers.dart';
import '../../providers/cart_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/pricing_provider.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/app_toast.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final MapController _mapController = MapController();
  bool _showNotificationPrompt = false;
  bool _mapReady = false;
  final TextEditingController _addressCtrl = TextEditingController();
  List<Map<String, dynamic>> _suggestions = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Init notification service
      await NotificationService.init();

      // Load pricing
      final pricing = await ref.read(pricingProvider.future);
      if (pricing.isNotEmpty) {
        ref.read(cartProvider.notifier).updatePricing(pricing);
      }

      // Show notification permission prompt
      await _checkNotificationPermission();
    });
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Move map camera when location changes
    ref.listen(locationProvider, (previous, next) {
      if (!next.loading && _mapReady) {
        _mapController.move(LatLng(next.lat, next.lng), 15);
        // Sync address field if empty or was auto-detected
        if (_addressCtrl.text.isEmpty || previous?.address != next.address) {
          _addressCtrl.text = next.address;
        }
      }
    });
  }

  Future<void> _checkNotificationPermission() async {
    final prefs = await SharedPreferences.getInstance();
    final shown = prefs.getBool('notification_prompt_shown') ?? false;
    if (!shown && mounted) {
      setState(() => _showNotificationPrompt = true);
    }
  }

  Future<void> _requestNotificationPermission() async {
    // Request local notification permission
    await NotificationService.requestPermission();
    // Request FCM permission + save token
    await ref.read(fcmTokenProvider.future);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notification_prompt_shown', true);
    if (mounted) {
      setState(() => _showNotificationPrompt = false);
      showToast(context, '✅ Notifications enabled');
    }
  }

  Future<void> _dismissNotificationPrompt() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notification_prompt_shown', true);
    if (mounted) setState(() => _showNotificationPrompt = false);
  }

  Future<void> _useCurrentLocation() async {
    _addressCtrl.clear();
    setState(() => _suggestions = []);
    await ref.read(locationProvider.notifier).refresh();
    final location = ref.read(locationProvider);
    if (_mapReady) {
      _mapController.move(LatLng(location.lat, location.lng), 15);
    }
    _addressCtrl.text = location.address;
  }

  Future<void> _fetchSuggestions(String query) async {
    if (query.length < 3) {
      setState(() => _suggestions = []);
      return;
    }
    try {
      final url = Uri.parse(
        'https://api.mapbox.com/geocoding/v5/mapbox.places/'
        '${Uri.encodeComponent(query)}.json'
        '?access_token=$mapboxToken'
        '&autocomplete=true'
        '&limit=5'
        '&proximity=$kDefaultLng,$kDefaultLat',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final features = data['features'] as List;
        if (mounted) {
          setState(() => _suggestions = features.cast<Map<String, dynamic>>());
        }
      }
    } catch (e) {
      debugPrint('Suggestions error: $e');
    }
  }

  void _onAddressChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _fetchSuggestions(query);
    });
  }

  Future<void> _selectSuggestion(Map<String, dynamic> suggestion) async {
    final placeName = suggestion['place_name'] as String;
    final center = suggestion['center'] as List;
    final lng = (center[0] as num).toDouble();
    final lat = (center[1] as num).toDouble();

    _addressCtrl.text = placeName;
    if (mounted) setState(() => _suggestions = []);

    await ref.read(locationProvider.notifier).geocodeAddress(placeName);

    if (_mapReady) {
      _mapController.move(LatLng(lat, lng), 15);
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = ref.watch(locationProvider);
    final profile = ref.watch(profileProvider);
    final order = ref.watch(orderProvider).currentOrder;
    final firstName = profile.value?.fullName.split(' ').first ?? 'there';

    return Scaffold(
      body: Stack(
        children: [
          // ── Map ──────────────────────────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: LatLng(location.lat, location.lng),
              zoom: 15,
              interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              onMapReady: () {
                setState(() => _mapReady = true);
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://api.mapbox.com/styles/v1/mapbox/streets-v12/tiles/{z}/{x}/{y}?access_token=$mapboxToken',
                userAgentPackageName: 'com.washgo.app',
              ),
              MarkerLayer(
                markers: [
                  // User marker
                  Marker(
                    point: LatLng(location.lat, location.lng),
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
                  // Simulated nearby drivers
                  ...[
                    [location.lat + 0.008, location.lng + 0.006],
                    [location.lat - 0.006, location.lng + 0.010],
                    [location.lat + 0.012, location.lng - 0.004],
                  ].map(
                    (coords) => Marker(
                      point: LatLng(coords[0], coords[1]),
                      width: 36,
                      height: 36,
                      child: Container(
                        decoration: BoxDecoration(
                          color: kCyan,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: kCyan.withOpacity(0.4),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const Text('🚗', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // ── Location overlay card ─────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 12,
            right: 12,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    border: Border.all(color: kBorder),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: shadowSm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'YOUR LOCATION',
                        style: headStyle(
                          size: 9,
                          weight: FontWeight.w800,
                          color: kMuted,
                        ).copyWith(letterSpacing: 0.8),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _addressCtrl,
                              style: headStyle(
                                size: 12,
                                weight: FontWeight.w700,
                              ),
                              decoration: InputDecoration(
                                hintText: location.loading
                                    ? 'Detecting location...'
                                    : 'Type your address...',
                                hintStyle: headStyle(size: 12, color: kMuted),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                isDense: true,
                              ),
                              onChanged: _onAddressChanged,
                              onSubmitted: (value) async {
                                if (value.trim().isNotEmpty) {
                                  setState(() => _suggestions = []);
                                  await ref
                                      .read(locationProvider.notifier)
                                      .geocodeAddress(value.trim());
                                }
                              },
                            ),
                          ),
                          // Loading indicator
                          if (location.loading)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: kCyan,
                              ),
                            )
                          else
                            GestureDetector(
                              onTap: _useCurrentLocation,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: kCyan.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(rSm),
                                ),
                                child: const Icon(
                                  Icons.my_location,
                                  size: 16,
                                  color: kCyan,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Suggestions dropdown
                if (_suggestions.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    constraints: const BoxConstraints(maxHeight: 200),
                    decoration: BoxDecoration(
                      color: kSurface,
                      border: Border.all(color: kBorder),
                      borderRadius: BorderRadius.circular(rMd),
                      boxShadow: shadowMd,
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      itemCount: _suggestions.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final s = _suggestions[index];
                        final placeName = s['place_name'] as String;
                        // Split into main name and secondary
                        final parts = placeName.split(',');
                        final main = parts.first.trim();
                        final secondary = parts.length > 1
                            ? parts.sublist(1).join(',').trim()
                            : '';
                        return ListTile(
                          dense: true,
                          leading: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: kCyan.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(rSm),
                            ),
                            child: const Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: kCyan,
                            ),
                          ),
                          title: Text(
                            main,
                            style: headStyle(size: 12, weight: FontWeight.w700),
                          ),
                          subtitle: secondary.isNotEmpty
                              ? Text(
                                  secondary,
                                  style: bodyStyle(size: 10, color: kMuted),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                )
                              : null,
                          onTap: () => _selectSuggestion(s),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // ── Bottom sheet ──────────────────────────────────────
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
                border: Border(top: BorderSide(color: kBorder)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 24,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 32,
                    height: 4,
                    decoration: BoxDecoration(
                      color: kBorder2,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Hey, ',
                                style: headStyle(
                                  size: 20,
                                  weight: FontWeight.w900,
                                ),
                              ),
                              TextSpan(
                                text: '$firstName ',
                                style: headStyle(
                                  size: 20,
                                  weight: FontWeight.w900,
                                  color: kCyan,
                                ),
                              ),
                              const TextSpan(
                                text: '👋',
                                style: TextStyle(fontSize: 20),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'What do you need today?',
                      style: bodyStyle(
                        size: 12,
                        weight: FontWeight.w600,
                        color: kMuted,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Service tabs
                  Row(
                    children: [
                      _ServiceTab(
                        icon: Icons.local_laundry_service,
                        label: 'Laundry',
                        active: true,
                        onTap: () => context.push('/items'),
                      ),
                      const SizedBox(width: 8),
                      _ServiceTab(
                        icon: Icons.bolt,
                        label: 'Express',
                        onTap: () => context.push('/express'),
                      ),
                      const SizedBox(width: 8),
                      _ServiceTab(
                        icon: Icons.calendar_today,
                        label: 'Schedule',
                        onTap: () => context.push('/schedule'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Quick grid
                  Row(
                    children: [
                      _QuickTile(
                        icon: Icons.local_shipping,
                        label: 'Track',
                        onTap: () {
                          if (order == null) {
                            showToast(context, '⚠️ No active order to track');
                            context.push('/orders');
                          } else {
                            context.push('/tracking');
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      _QuickTile(
                        icon: Icons.receipt_long,
                        label: 'Orders',
                        onTap: () => context.push('/orders'),
                      ),
                      const SizedBox(width: 8),
                      _QuickTile(
                        icon: Icons.person,
                        label: 'Profile',
                        onTap: () => context.push('/profile'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Notification permission prompt ────────────────────
          if (_showNotificationPrompt)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.all(24),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: kSurface,
                      borderRadius: BorderRadius.circular(rXl),
                      boxShadow: shadowLg,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: kCyan.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.notifications_active,
                            size: 40,
                            color: kCyan,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Stay Updated',
                          style: headStyle(size: 20, weight: FontWeight.w900),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Enable notifications to get real-time updates on your orders and location changes.',
                          style: bodyStyle(size: 13, color: kMuted),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _dismissNotificationPrompt,
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: kBorder),
                                  foregroundColor: kMuted,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(rSm),
                                  ),
                                ),
                                child: Text(
                                  'Not now',
                                  style: headStyle(
                                    size: 13,
                                    weight: FontWeight.w700,
                                    color: kMuted,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _requestNotificationPermission,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kCyan,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(rSm),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  'Enable',
                                  style: headStyle(
                                    size: 13,
                                    weight: FontWeight.w800,
                                    color: Colors.white,
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
              ),
            ),
        ],
      ),
    );
  }
}

// ── _ServiceTab ───────────────────────────────────────────────
class _ServiceTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ServiceTab({
    required this.icon,
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
            color: active ? kCyan.withOpacity(0.08) : kBg,
            border: Border.all(color: active ? kCyan : kBorder, width: 1.5),
            borderRadius: BorderRadius.circular(rSm),
            boxShadow: active
                ? [BoxShadow(color: kCyan.withOpacity(0.15), blurRadius: 10)]
                : [],
          ),
          child: Column(
            children: [
              Icon(icon, size: 20, color: active ? kCyan3 : kMuted),
              const SizedBox(height: 4),
              Text(
                label,
                style: headStyle(
                  size: 10,
                  weight: FontWeight.w700,
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

// ── _QuickTile ────────────────────────────────────────────────
class _QuickTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: kBg,
            border: Border.all(color: kBorder),
            borderRadius: BorderRadius.circular(rSm),
          ),
          child: Column(
            children: [
              Icon(icon, size: 16, color: kMuted),
              const SizedBox(height: 2),
              Text(
                label,
                style: headStyle(
                  size: 9,
                  weight: FontWeight.w700,
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
