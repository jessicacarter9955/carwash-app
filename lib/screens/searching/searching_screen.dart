import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../providers/location_provider.dart';
import '../../providers/tracking_provider.dart';

class SearchingScreen extends ConsumerStatefulWidget {
  const SearchingScreen({super.key});
  @override
  ConsumerState<SearchingScreen> createState() => _SearchingScreenState();
}

class _SearchingScreenState extends ConsumerState<SearchingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _progress;
  double _displayProgress = 0;

  @override
  void initState() {
    super.initState();
    _ctrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _progress = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    _ctrl.addListener(() => setState(() => _displayProgress = _progress.value));
    _ctrl.forward().then((_) {
      if (mounted) _onFound();
    });
  }

  void _onFound() {
    final location = ref.read(locationProvider);
    ref
        .read(trackingProvider.notifier)
        .startTracking(location.lat, location.lng);
    context.go('/tracking');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RotationTransition(
                turns: Tween(begin: 0.0, end: 1.0).animate(
                  AnimationController(
                      vsync: this, duration: const Duration(seconds: 3))
                    ..repeat(),
                ),
                child: const Text('🔄', style: TextStyle(fontSize: 56)),
              ),
              const SizedBox(height: 20),
              Text('Finding your driver...',
                  style: headStyle(size: 20, weight: FontWeight.w900),
                  textAlign: TextAlign.center),
              const SizedBox(height: 6),
              Text('Scanning nearby drivers',
                  style: bodyStyle(
                      size: 13, weight: FontWeight.w600, color: kMuted)),
              const SizedBox(height: 24),
              Container(
                width: 180,
                height: 5,
                decoration: BoxDecoration(
                    color: kBorder, borderRadius: BorderRadius.circular(3)),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _displayProgress,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [kCyan, kMint]),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
