import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme.dart';
import 'core/constants.dart';
import 'core/supabase_client.dart';
import 'state/app_state.dart';
import 'services/auth_service.dart';
import 'services/pricing_service.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/customer/customer_view.dart';
import 'screens/driver/driver_view.dart';
import 'screens/admin/admin_view.dart';
import 'widgets/toast_overlay.dart';
import 'widgets/currency_switcher.dart';

class WashGoApp extends StatelessWidget {
  const WashGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WashGo',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      home: const _AppRoot(),
    );
  }
}

class _AppRoot extends StatefulWidget {
  const _AppRoot();

  @override
  State<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<_AppRoot> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final state = context.read<AppState>();

    // Check existing session
    final session = sb.auth.currentSession;
    if (session != null) {
      final profile = await AuthService.loadProfile(session.user.id);
      state.setProfile(profile, session.user.id, session.user.email);
      if (profile?.isDriver == true) {
        await AuthService.ensureDriverRow(session.user.id);
      }
    }

    // Listen to auth changes
    sb.auth.onAuthStateChange.listen((data) async {
      final event = data.event;
      final sess = data.session;
      if (event == AuthChangeEvent.signedIn && sess != null) {
        final profile = await AuthService.loadProfile(sess.user.id);
        state.setProfile(profile, sess.user.id, sess.user.email);
      } else if (event == AuthChangeEvent.signedOut) {
        state.signOut();
      }
    });

    // Load pricing
    await PricingService.loadFromDB(state);

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Consumer<AppState>(
      builder: (_, state, __) {
        final Widget content = state.currentProfile == null
            ? const AuthScreen()
            : _MainWorkspace(role: state.currentRole);

        return ToastOverlay(
          child: Stack(
            children: [
              content,
              const CurrencySwitcher(),
            ],
          ),
        );
      },
    );
  }
}

class _MainWorkspace extends StatelessWidget {
  final String role;
  const _MainWorkspace({required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D12),
      body: Row(
        children: [
          // Sidebar
          _Sidebar(role: role),
          // Main content
          Expanded(
            child: switch (role) {
              'driver' => const DriverView(),
              'admin'  => const AdminView(),
              _        => const CustomerView(),
            },
          ),
        ],
      ),
    );
  }
}

// ── Sidebar ───────────────────────────────────────────
class _Sidebar extends StatelessWidget {
  final String role;
  const _Sidebar({required this.role});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      color: const Color(0xFF0D0D12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          // Logo
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                    text: 'Wash',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        fontFamily: kFontHead)),
                TextSpan(
                    text: 'Go',
                    style: TextStyle(
                        color: kCyan3,
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        fontFamily: kFontHead)),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Nav sections based on role
          if (role != 'driver') ...[
            _NavLabel('Customer'),
            _NavBtn(
                icon: '📱',
                label: 'Customer App',
                onTap: () {}),
          ],
          if (role == 'driver' || role == 'admin') ...[
            _NavLabel('Driver'),
            _NavBtn(
                icon: '🚗',
                label: 'Driver App',
                onTap: () {}),
          ],
          if (role == 'admin') ...[
            _NavLabel('Operations'),
            _NavBtn(icon: '📊', label: 'Admin Panel', onTap: () {}),
            _NavBtn(icon: '👷', label: 'Drivers', onTap: () {}),
            _NavBtn(icon: '📦', label: 'Orders', onTap: () {}),
            _NavBtn(icon: '💳', label: 'Payments', onTap: () {}),
            _NavBtn(icon: '🏷', label: 'Pricing', onTap: () {}),
          ],

          const Spacer(),
          // User info
          _SidebarUser(),
          const SizedBox(height: 8),
          const Text('WashGo v3.1 · Production',
              style: TextStyle(
                  color: kMuted,
                  fontSize: 9,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _NavLabel extends StatelessWidget {
  final String text;
  const _NavLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 6),
      child: Text(text.toUpperCase(),
          style: const TextStyle(
              color: kMuted,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2)),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;

  const _NavBtn(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white.withOpacity(.05),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _SidebarUser extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final p = state.currentProfile;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(p?.isDriver == true ? '🚗' : '👤',
              style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p?.fullName ?? 'Loading...',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12)),
                Text(p?.role ?? 'customer',
                    style: const TextStyle(
                        color: kMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () async {
              await AuthService.signOut();
              state.signOut();
              showToast('👋 Signed out');
            },
            child: const Text('✕',
                style: TextStyle(color: kMuted, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
