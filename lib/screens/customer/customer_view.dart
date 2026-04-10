// lib/screens/customer/customer_view.dart

import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/screens.dart';
import '../../widgets/android_shell.dart';
import 'splash_screen.dart';
import 'home_screen.dart';
import 'items_screen.dart';
import 'service_screen.dart';
import 'checkout_screen.dart';
import 'searching_screen.dart';
import 'tracking_screen.dart';
import 'status_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';
import 'rating_screen.dart';

class CustomerView extends StatefulWidget {
  const CustomerView({super.key});
  @override
  State<CustomerView> createState() => CustomerViewState();
}

class CustomerViewState extends State<CustomerView> {
  CScreen _current = CScreen.splash;

  static CustomerViewState? of(BuildContext context) =>
      context.findAncestorStateOfType<CustomerViewState>();

  void goScreen(CScreen s) => setState(() => _current = s);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AndroidShell(
          onHome: () => goScreen(CScreen.home),
          onBack: () {
            final prev = _backScreen(_current);
            if (prev != null) goScreen(prev);
          },
          child: _buildScreen(),
        ),
        const SizedBox(width: 28),
        _QuickNav(onNav: goScreen),
      ],
    );
  }

  Widget _buildScreen() {
    switch (_current) {
      case CScreen.splash:
        return SplashScreen(onStart: () => goScreen(CScreen.home));
      case CScreen.home:
        return HomeScreen(onNav: goScreen);
      case CScreen.items:
        return ItemsScreen(
          onBack: () => goScreen(CScreen.home),
          onNext: () => goScreen(CScreen.service),
        );
      case CScreen.service:
        return ServiceScreen(
          onBack: () => goScreen(CScreen.items),
          onNext: () => goScreen(CScreen.checkout),
        );
      case CScreen.checkout:
        return CheckoutScreen(
          onBack: () => goScreen(CScreen.service),
          onOrder: () => goScreen(CScreen.searching),
        );
      case CScreen.searching:
        return SearchingScreen(onFound: () => goScreen(CScreen.tracking));
      case CScreen.tracking:
        return TrackingScreen(
          onDone: () => goScreen(CScreen.rating),
          onClose: () => goScreen(CScreen.home),
        );
      case CScreen.status:
        return StatusScreen(onBack: () => goScreen(CScreen.home));
      case CScreen.orders:
        return OrdersScreen(onBack: () => goScreen(CScreen.home));
      case CScreen.profile:
        return ProfileScreen(
          onBack: () => goScreen(CScreen.home),
          onOrders: () => goScreen(CScreen.orders),
        );
      case CScreen.rating:
        return RatingScreen(onDone: () => goScreen(CScreen.home));
    }
  }

  CScreen? _backScreen(CScreen s) => const {
    CScreen.home: null,
    CScreen.items: CScreen.home,
    CScreen.service: CScreen.items,
    CScreen.checkout: CScreen.service,
    CScreen.orders: CScreen.home,
    CScreen.profile: CScreen.home,
    CScreen.status: CScreen.home,
  }[s];
}

class _QuickNav extends StatelessWidget {
  final Function(CScreen) onNav;
  const _QuickNav({required this.onNav});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Customer App',
              style: TextStyle(
                fontFamily: kFontHead,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: kText,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Real DB writes · Stripe payments · Live tracking',
              style: TextStyle(
                fontSize: 11,
                color: kMuted,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'QUICK NAV'.toUpperCase(),
              style: const TextStyle(
                fontFamily: kFontHead,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: kMuted,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            _navBtn('🗺 Home', () => onNav(CScreen.home)),
            _navBtn('🧺 Items', () => onNav(CScreen.items)),
            _navBtn('💳 Checkout', () => onNav(CScreen.checkout)),
            _navBtn('📋 Orders', () => onNav(CScreen.orders)),
            _navBtn('👤 Profile', () => onNav(CScreen.profile)),
          ],
        ),
      ),
    );
  }

  Widget _navBtn(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 5),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: kSurface,
          border: Border.all(color: kBorder),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: kText,
          ),
        ),
      ),
    );
  }
}
