// lib/widgets/shared.dart
// These are used across multiple screens — import from here

import 'package:flutter/material.dart';
import '../core/constants.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  const AppHeader({super.key, required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: kBg.withOpacity(.95)),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: kSurface,
                border: Border.all(color: kBorder, width: 1.5),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.06),
                    blurRadius: 3,
                  ),
                ],
              ),
              child: const Center(
                child: Text('←', style: TextStyle(fontSize: 14, color: kText)),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontFamily: kFontHead,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: kText,
              letterSpacing: -.4,
            ),
          ),
        ],
      ),
    );
  }
}

class BottomBar extends StatelessWidget {
  final Widget child;
  const BottomBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [kBg, kBg.withOpacity(0)],
          stops: const [.7, 1.0],
        ),
      ),
      child: child,
    );
  }
}

class PrimaryBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  const PrimaryBtn({super.key, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: kCyan3,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 4,
          shadowColor: kCyan3.withOpacity(.35),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: kFontHead,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class SecLabel extends StatelessWidget {
  final String text;
  const SecLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontFamily: kFontHead,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: kMuted,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class AppCard extends StatelessWidget {
  final Widget child;
  const AppCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: kSurface,
        border: Border.all(color: kBorder),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: child,
    );
  }
}
