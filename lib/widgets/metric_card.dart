import 'package:flutter/material.dart';
import '../core/constants.dart';

class MetricCard extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  final String trend;
  final Color accentColor;

  const MetricCard({
    super.key,
    required this.emoji,
    required this.value,
    required this.label,
    required this.trend,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withOpacity(.25)),
        boxShadow: [
          BoxShadow(
              color: accentColor.withOpacity(.08),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  color: accentColor,
                  fontFamily: kFontHead)),
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  color: kMuted,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(trend,
              style: const TextStyle(
                  fontSize: 10,
                  color: kMuted,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
