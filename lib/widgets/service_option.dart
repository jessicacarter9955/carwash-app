import 'package:flutter/material.dart';
import '../core/constants.dart';

class ServiceOption extends StatelessWidget {
  final String name;
  final String desc;
  final String price;
  final bool selected;
  final VoidCallback onTap;

  const ServiceOption({
    super.key,
    required this.name,
    required this.desc,
    required this.price,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? kCyan3.withOpacity(.08) : kSurface,
          border: Border.all(
              color: selected ? kCyan3 : kBorder, width: selected ? 1.5 : 1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            // Radio dot
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: selected ? kCyan3 : kMuted, width: 2),
                color: selected ? kCyan3 : Colors.transparent,
              ),
              child: selected
                  ? const Center(
                      child: Icon(Icons.check, size: 9,
                          color: Colors.white))
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: kText)),
                  Text(desc,
                      style: const TextStyle(
                          fontSize: 11,
                          color: kMuted,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            Text(price,
                style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    color: kCyan3)),
          ],
        ),
      ),
    );
  }
}
