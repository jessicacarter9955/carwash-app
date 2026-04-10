import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../widgets/android_shell.dart';
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AndroidShell(
          onHome: () => goScreen(DScreen.home),
          onBack: () => goScreen(DScreen.home),
          child: _buildScreen(),
        ),
        const SizedBox(width: 28),
        _DriverQuickNav(onNav: goScreen),
      ],
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

class _DriverQuickNav extends StatelessWidget {
  final Function(DScreen) onNav;
  const _DriverQuickNav({required this.onNav});

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
              'Driver App',
              style: TextStyle(
                fontFamily: kFontHead,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Real GPS · DB writes · Live earnings',
              style: TextStyle(
                fontSize: 11,
                color: kMuted,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 14),
            _dBtn('🏠 Dashboard', () => onNav(DScreen.home)),
            _dBtn('📍 Active Job', () => onNav(DScreen.active)),
            _dBtn('🏭 Hub Delivery', () => onNav(DScreen.delivery)),
            _dBtn('💰 Earnings', () => onNav(DScreen.earnings)),
          ],
        ),
      ),
    );
  }

  Widget _dBtn(String label, VoidCallback onTap) => GestureDetector(
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
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    ),
  );
}
