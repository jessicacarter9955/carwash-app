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

        return ToastOverlay(child: content);
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
      backgroundColor: kBg,
      body: switch (role) {
        'driver' => const DriverView(),
        'admin'  => const AdminView(),
        _        => const CustomerView(),
      },
    );
  }
}
