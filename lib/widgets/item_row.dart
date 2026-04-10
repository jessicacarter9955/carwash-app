import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../state/app_state.dart';

class ItemRow extends StatelessWidget {
  final LaundryItem item;
  const ItemRow({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final selected = item.qty > 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: selected
            ? kCyan3.withOpacity(.08)
            : kSurface,
        border: Border.all(
            color: selected ? kCyan3.withOpacity(.4) : kBorder),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Text(item.emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: kText)),
                Text(state.fmt(item.price) + ' per item',
                    style: const TextStyle(
                        fontSize: 11,
                        color: kMuted,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          // Qty controls
          Row(
            children: [
              _QtyBtn(
                label: '−',
                onTap: () => state.changeQty(item.key, -1),
              ),
              SizedBox(
                width: 28,
                child: Text(
                  item.qty.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: kText),
                ),
              ),
              _QtyBtn(
                label: '+',
                onTap: () => state.changeQty(item.key, 1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _QtyBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: kBg,
          border: Border.all(color: kBorder),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: kText))),
      ),
    );
  }
}
