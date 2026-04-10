import 'package:flutter/material.dart';
import '../core/constants.dart';

class AndroidShell extends StatelessWidget {
  final Widget child;
  final String time;
  final VoidCallback? onBack;
  final VoidCallback? onHome;

  const AndroidShell({
    super.key,
    required this.child,
    this.time = '9:41',
    this.onBack,
    this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      height: 640,
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(36),
        border: Border.all(color: const Color(0xFF1A1A2E), width: 3),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(.3),
              blurRadius: 40,
              offset: const Offset(0, 16))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(33),
        child: Column(
          children: [
            // Camera notch
            _StatusBar(time: time),
            // Screen content
            Expanded(child: child),
            // Android nav bar
            _NavBar(onBack: onBack, onHome: onHome),
          ],
        ),
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  final String time;
  const _StatusBar({required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      color: const Color(0xFF0D0D12),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Camera dot
          Container(
              width: 8, height: 8,
              decoration: const BoxDecoration(
                  color: Color(0xFF333344),
                  shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(time,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700)),
          const Spacer(),
          const Text('📶 🔋 87%',
              style: TextStyle(color: Colors.white, fontSize: 10)),
        ],
      ),
    );
  }
}

class _NavBar extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onHome;
  const _NavBar({this.onBack, this.onHome});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      color: const Color(0xFF0D0D12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: onBack ?? () => Navigator.maybePop(context),
            child: const Text('◀',
                style: TextStyle(color: Colors.white, fontSize: 14)),
          ),
          GestureDetector(
            onTap: onHome,
            child: const Text('⬤',
                style: TextStyle(color: Colors.white, fontSize: 14)),
          ),
          const Text('▬',
              style: TextStyle(color: Colors.white, fontSize: 14)),
        ],
      ),
    );
  }
}
