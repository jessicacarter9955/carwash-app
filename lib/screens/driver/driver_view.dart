import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart' as provider;
import '../../core/constants.dart';
import '../../state/app_state.dart';
import 'driver_home_screen.dart';
import 'driver_active_screen.dart';
import 'driver_delivery_screen.dart';
import 'driver_earnings_screen.dart';

enum DScreen { home, active, delivery, earnings }

class DriverView extends ConsumerStatefulWidget {
  const DriverView({super.key});

  @override
  ConsumerState<DriverView> createState() => _DriverViewState();
}

class _DriverViewState extends ConsumerState<DriverView> {
  DScreen _current = DScreen.home;
  void goScreen(DScreen s) => setState(() => _current = s);

  @override
  Widget build(BuildContext context) {
    return provider.ChangeNotifierProvider(
      create: (_) => AppState(),
      child: WillPopScope(
        onWillPop: () async {
          if (_current != DScreen.home) {
            goScreen(DScreen.home);
            return false;
          }
          return true;
        },
        child: SafeArea(child: _buildScreen()),
      ),
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
