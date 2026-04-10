import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_providers.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    authState.when(
      data: (session) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          if (session == null) {
            context.go('/login');
          } else {
            context.go('/home');
          }
        });
      },
      loading: () {},
      error: (_, __) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          context.go('/login');
        });
      },
    );

    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
