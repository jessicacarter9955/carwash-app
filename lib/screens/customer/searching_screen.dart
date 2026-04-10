import 'package:flutter/material.dart';
import '../../core/constants.dart';

class SearchingScreen extends StatefulWidget {
  final VoidCallback onFound;
  const SearchingScreen({super.key, required this.onFound});
  @override
  State<SearchingScreen> createState() => _SearchingScreenState();
}

class _SearchingScreenState extends State<SearchingScreen>
    with SingleTickerProviderStateMixin {
  double _progress = 0;
  late AnimationController _spin;

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _runSearch();
  }

  Future<void> _runSearch() async {
    while (_progress < 100 && mounted) {
      await Future.delayed(const Duration(milliseconds: 160));
      setState(
        () => _progress =
            (_progress + 4 + (20 * (DateTime.now().millisecond / 1000))).clamp(
              0,
              95,
            ),
      );
    }
    if (!mounted) return;
    await Future.delayed(const Duration(milliseconds: 400));
    setState(() => _progress = 100);
    await Future.delayed(const Duration(milliseconds: 600));
    widget.onFound();
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kBg,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RotationTransition(
            turns: _spin,
            child: const Text('🔄', style: TextStyle(fontSize: 56)),
          ),
          const SizedBox(height: 20),
          const Text(
            'Finding your driver...',
            style: TextStyle(
              fontFamily: kFontHead,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          const Text(
            'Scanning nearby drivers',
            style: TextStyle(
              color: kMuted,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          // Progress bar
          Container(
            width: 180,
            height: 5,
            decoration: BoxDecoration(
              color: kBorder,
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: _progress / 100,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [kCyan3, kMint]),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
