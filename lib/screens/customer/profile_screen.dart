// lib/screens/customer/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../services/auth_service.dart';
import '../../state/app_state.dart';
import '../../widgets/toast_overlay.dart';
import '../../widgets/shared.dart';

class ProfileScreen extends StatelessWidget {
  final VoidCallback onBack, onOrders;
  const ProfileScreen({
    super.key,
    required this.onBack,
    required this.onOrders,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final p = state.currentProfile;
    return Column(
      children: [
        AppHeader(title: 'Profile', onBack: onBack),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
            children: [
              // Hero
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text('👤', style: TextStyle(fontSize: 50)),
                    const SizedBox(height: 10),
                    Text(
                      p?.fullName ?? '--',
                      style: const TextStyle(
                        fontFamily: kFontHead,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      state.currentUserEmail ?? '--',
                      style: const TextStyle(fontSize: 12, color: kMuted),
                    ),
                    Text(
                      p?.phone ?? '--',
                      style: const TextStyle(fontSize: 12, color: kMuted),
                    ),
                  ],
                ),
              ),
              // Menu
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: kSurface,
                  border: Border.all(color: kBorder),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    _MenuItem(icon: '✏️', label: 'Edit Profile', onTap: () {}),
                    _MenuItem(icon: '📦', label: 'My Orders', onTap: onOrders),
                    _MenuItem(
                      icon: '💳',
                      label: 'Payment Methods',
                      onTap: () {},
                    ),
                    _MenuItem(icon: '🔔', label: 'Notifications', onTap: () {}),
                    _MenuItem(
                      icon: '❓',
                      label: 'Help & Support',
                      onTap: () {},
                      isLast: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  children: [
                    const SecLabel('Currency'),
                    Row(
                      children: [
                        _CurrencyOpt(
                          symbol: '\$',
                          label: 'USD',
                          active: state.currency == Currency.usd,
                          onTap: () => state.setCurrency(Currency.usd),
                        ),
                        const SizedBox(width: 8),
                        _CurrencyOpt(
                          symbol: '€',
                          label: 'EUR',
                          active: state.currency == Currency.eur,
                          onTap: () => state.setCurrency(Currency.eur),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          await AuthService.signOut();
                          state.signOut();
                          showToast('👋 Signed out');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kRed,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Sign Out',
                          style: TextStyle(
                            fontFamily: kFontHead,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final String icon, label;
  final VoidCallback onTap;
  final bool isLast;
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  child: Text(
                    icon,
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Text('›', style: TextStyle(color: kMuted, fontSize: 16)),
              ],
            ),
          ),
        ),
        if (!isLast) const Divider(height: 1, color: kBorder, indent: 56),
      ],
    );
  }
}

class _CurrencyOpt extends StatelessWidget {
  final String symbol, label;
  final bool active;
  final VoidCallback onTap;
  const _CurrencyOpt({
    required this.symbol,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? kCyan3.withOpacity(.08) : kSurface,
            border: Border.all(
              color: active ? kCyan3 : kBorder,
              width: active ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(symbol, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: kFontHead,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
