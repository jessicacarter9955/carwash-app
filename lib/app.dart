import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'core/router.dart';

class WashGoApp extends ConsumerWidget {
  const WashGoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'WashGo',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
