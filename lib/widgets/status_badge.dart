import 'package:flutter/material.dart';
import '../core/constants.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    switch (status) {
      case 'pending':
        bg = kOrange.withOpacity(0.12);
        fg = kOrange;
        break;
      case 'confirmed':
      case 'pickup':
      case 'washing':
        bg = kMint.withOpacity(0.12);
        fg = kMint2;
        break;
      case 'delivered':
        bg = kCyan.withOpacity(0.15);
        fg = kCyan3;
        break;
      default:
        bg = kBorder;
        fg = kMuted;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(
        status.toUpperCase(),
        style: headStyle(size: 10, weight: FontWeight.w800, color: fg)
            .copyWith(letterSpacing: 0.5),
      ),
    );
  }
}
