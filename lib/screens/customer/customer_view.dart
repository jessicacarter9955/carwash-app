// lib/screens/customer/customer_view.dart

import 'package:flutter/material.dart';
import '../../core/screens.dart';
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
    return WillPopScope(
      onWillPop: () async {
        final prev = _backScreen(_current);
        if (prev != null) {
          goScreen(prev);
          return false;
        }
        return true;
      },
      child: SafeArea(child: _buildScreen()),
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
    CScreen.splash: null,
    CScreen.items: CScreen.home,
    CScreen.service: CScreen.items,
    CScreen.checkout: CScreen.service,
    CScreen.orders: CScreen.home,
    CScreen.profile: CScreen.home,
    CScreen.status: CScreen.home,
  }[s];
}
