import 'package:flutter/material.dart';
import 'driver_home_screen.dart';
import 'driver_active_screen.dart';
import 'driver_delivery_screen.dart';
import 'driver_earnings_screen.dart';

enum DScreen { home, active, delivery, earnings }

class DriverView extends StatefulWidget {
  const DriverView({super.key});
  @override
  State<DriverView> createState() => _DriverViewState();
}

class _DriverViewState extends State<DriverView> {
  DScreen _current = DScreen.home;
  void goScreen(DScreen s) => setState(() => _current = s);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_current != DScreen.home) {
          goScreen(DScreen.home);
          return false;
        }
        return true;
      },
      child: SafeArea(child: _buildScreen()),
    );
  }

  Widget _buildScreen() {
    switch (_current) {
      case DScreen.home:
        return DriverHomeScreen(onNav: goScreen);
      case DScreen.active:
        return DriverActiveScreen(
          onBack: () => goScreen(DScreen.home),
          onDelivery: () => goScreen(DScreen.delivery),
        );
      case DScreen.delivery:
        return DriverDeliveryScreen(
          onBack: () => goScreen(DScreen.home),
          onDone: () => goScreen(DScreen.earnings),
        );
      case DScreen.earnings:
        return DriverEarningsScreen(onBack: () => goScreen(DScreen.home));
    }
  }
}
