import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../state/app_state.dart';

class CurrencySwitcher extends StatelessWidget {
  const CurrencySwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Positioned(
      top: 12,
      right: 12,
      child: Container(
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kBorder),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(.08),
                blurRadius: 8)
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CurBtn(
              label: '\$ USD',
              active: state.currency == Currency.usd,
              onTap: () => state.setCurrency(Currency.usd),
            ),
            _CurBtn(
              label: '€ EUR',
              active: state.currency == Currency.eur,
              onTap: () => state.setCurrency(Currency.eur),
            ),
          ],
        ),
      ),
    );
  }
}

class _CurBtn extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _CurBtn(
      {required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? kCyan3 : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
              color: active ? Colors.white : kMuted,
              fontWeight: FontWeight.w700,
              fontSize: 11),
        ),
      ),
    );
  }
}
