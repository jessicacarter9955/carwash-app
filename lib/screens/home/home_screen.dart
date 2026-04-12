import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
  final _mapController = MapController();
  final _addressController = TextEditingController();
  bool _showNotificationPrompt = false;
  bool _editingAddress = false;

  @override
  void initState() {
    super.initState();
    // Load pricing and update cart
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final pricing = await ref.read(pricingProvider.future);
      if (pricing.isNotEmpty) {
        ref.read(cartProvider.notifier).updatePricing(pricing);
      }
      // Show notification permission prompt
      _checkNotificationPermission();
      // Initialize address controller
      final location = ref.read(locationProvider);
      _addressController.text = location.address;
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Move map camera when location changes
    ref.listen(locationProvider, (previous, next) {
      if (previous != null && previous.lat != next.lat) {
        _mapController.move(LatLng(next.lat, next.lng), 15);
      }
    });
  }

  Future<void> _checkNotificationPermission() async {
    // Check if we should show the prompt (only show once)
    final prefs = await SharedPreferences.getInstance();
    final shown = prefs.getBool('notification_prompt_shown') ?? false;
    if (!shown) {
      setState(() => _showNotificationPrompt = true);
    }
  }

  Future<void> _requestNotificationPermission() async {
    await ref.read(fcmTokenProvider.future);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notification_prompt_shown', true);
    setState(() => _showNotificationPrompt = false);
    showToast(context, '✅ Notifications enabled');
  }

  Future<void> _dismissNotificationPrompt() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notification_prompt_shown', true);
    setState(() => _showNotificationPrompt = false);
  }

  @override
  Widget build(BuildContext context) {
    final location = ref.watch(locationProvider);
    final profile = ref.watch(profileProvider);
    final firstName = profile.value?.fullName.split(' ').first ?? 'there';

    return Scaffold(
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: LatLng(location.lat, location.lng),
              zoom: 15,
              interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.washgo.app',
              ),
              MarkerLayer(
                markers: [
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

          // Location overlay card
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
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
                  const SizedBox(height: 2),
                  Text(
                    location.loading
                        ? 'Detecting location...'
                        : location.address,
                    style: headStyle(size: 12, weight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
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
                  // Handle
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
                      'What does your car need today?',
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
                        icon: Icons.directions_car,
                        label: 'Car Wash',
                        active: true,
                        onTap: () => context.push('/items'),
                      ),
                      const SizedBox(width: 8),
                      _ServiceTab(
                        icon: Icons.flash_on,
                        label: 'Express',
                        onTap: () =>
                            showToast(context, '⚡ Express coming soon!'),
                      ),
                      const SizedBox(width: 8),
                      _ServiceTab(
                        icon: Icons.calendar_month,
                        label: 'Schedule',
                        onTap: () =>
                            showToast(context, '🗓 Schedule coming soon!'),
                      ),
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
                      borderRadius: BorderRadius.circular(rSm),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: kCyan,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PICKUP ADDRESS',
                                style: headStyle(
                                  size: 9,
                                  weight: FontWeight.w800,
                                  color: kMuted,
                                ).copyWith(letterSpacing: 0.8),
                              ),
                              TextField(
                                controller: _addressController,
                                style: bodyStyle(
                                  size: 12,
                                  weight: FontWeight.w600,
                                ),
                                decoration: const InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                  border: InputBorder.none,
                                  hintText: 'Enter address...',
                                ),
                                onSubmitted: (value) async {
                                  if (value.trim().isNotEmpty) {
                                    await ref
                                        .read(locationProvider.notifier)
                                        .geocodeAddress(value.trim());
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Quick grid
                  Row(
                    children: [
                      _QuickTile(
                        icon: Icons.local_shipping,
                        label: 'Track',
                        onTap: () {
                          // Check if there's an active order
                          final orderState = ref.read(orderProvider);
                          if (orderState.currentOrder != null) {
                            context.push('/tracking');
                          } else {
                            showToast(context, 'No active order to track');
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      _QuickTile(
                        icon: Icons.list_alt,
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
          // Notification permission prompt
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
                        const Icon(
                          Icons.notifications_active,
                          size: 48,
                          color: kCyan,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Enable Notifications',
                          style: headStyle(size: 18, weight: FontWeight.w800),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Get updates on your order status',
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
                                  foregroundColor: kText,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(rSm),
                                  ),
                                ),
                                child: const Text('Not now'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _requestNotificationPermission,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kCyan3,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(rSm),
                                  ),
                                ),
                                child: const Text('Enable'),
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
