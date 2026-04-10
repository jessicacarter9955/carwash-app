// lib/screens/customer/splash_screen.dart

import 'package:flutter/material.dart';
import '../../core/constants.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onStart;
  const SplashScreen({super.key, required this.onStart});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);

    // Auto-advance after 2.2 seconds
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) widget.onStart();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kBg,
      child: FadeTransition(
        opacity: _fade,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo bubble
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                color: kCyan3,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: kCyan3.withOpacity(.38),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Center(
                child: Text('🧺', style: TextStyle(fontSize: 40)),
              ),
            ),
            const SizedBox(height: 22),
            // App name
            const Text(
              'WashGo',
              style: TextStyle(
                fontFamily: kFontHead,
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: kText,
                letterSpacing: -1.2,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Laundry, delivered.',
              style: TextStyle(
                fontSize: 13,
                color: kMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 52),
            // Spinner
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: kCyan3),
            ),
          ],
        ),
      ),
    );
  }
}
