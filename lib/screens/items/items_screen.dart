import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/back_button_widget.dart';

class ItemsScreen extends ConsumerWidget {
  const ItemsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final notifier = ref.read(cartProvider.notifier);

    return Scaffold(
      backgroundColor: kBg,
      body: Column(
        children: [
          // Header
          Container(
            color: kBg.withOpacity(0.95),
            padding: EdgeInsets.fromLTRB(
              14,
              MediaQuery.of(context).padding.top + 12,
              14,
              10,
            ),
            child: Row(
              children: [
                const BackButtonWidget(),
                const SizedBox(width: 10),
                Text(
                  'Select Service',
                  style: headStyle(size: 16, weight: FontWeight.w800),
                ),
              ],
            ),
          ),

          // Items list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 100),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    'WASH PACKAGES',
                    style: headStyle(
                      size: 10,
                      weight: FontWeight.w800,
                      color: kMuted,
                    ).copyWith(letterSpacing: 1.2),
                  ),
                ),
                ...cart.items.map((item) {
                  final qty = cart.quantities[item.key] ?? 0;
                  return _ItemRow(
                    icon: item.icon,
                    name: item.name,
                    price: item.price,
                    qty: qty,
                    selected: qty > 0,
                    onMinus: () => notifier.changeQty(item.key, -1),
                    onPlus: () => notifier.changeQty(item.key, 1),
                  );
                }),
              ],
            ),
          ),

          // Bottom bar
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [kBg, kBg.withOpacity(0)],
              ),
            ),
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Subtotal',
                      style: bodyStyle(
                        size: 12,
                        weight: FontWeight.w600,
                        color: kMuted,
                      ),
                    ),
                    Text(
                      '\$${cart.itemsTotal.toStringAsFixed(2)}',
                      style: headStyle(
                        size: 14,
                        weight: FontWeight.w800,
                        color: kText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                AppButton(
                  label: 'Choose Service →',
                  onTap: cart.hasItems
                      ? () => context.push('/service')
                      : () => showToast(context, '⚠️ Add at least one item'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  final IconData icon;
  final String name;
  final double price;
  final int qty;
  final bool selected;
  final VoidCallback onMinus, onPlus;

  const _ItemRow({
    required this.icon,
    required this.name,
    required this.price,
    required this.qty,
    required this.selected,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: kSurface,
        border: Border.all(color: selected ? kCyan : kBorder, width: 1.5),
        borderRadius: BorderRadius.circular(rMd),
        boxShadow: shadowXs,
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: kCyan),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: headStyle(size: 13, weight: FontWeight.w700)),
                Text(
                  '\$${price.toStringAsFixed(2)} per item',
                  style: bodyStyle(size: 11, color: kMuted),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _QtyBtn(icon: '−', onTap: onMinus),
              SizedBox(
                width: 28,
                child: Text(
                  '$qty',
                  style: headStyle(size: 13, weight: FontWeight.w800),
                  textAlign: TextAlign.center,
                ),
              ),
              _QtyBtn(icon: '+', onTap: onPlus),
            ],
          ),
        ],
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final String icon;
  final VoidCallback onTap;
  const _QtyBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: kBg,
          border: Border.all(color: kBorder, width: 1.5),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Center(
          child: Text(
            icon,
            style: bodyStyle(size: 14, weight: FontWeight.w600, color: kText2),
          ),
        ),
      ),
    );
  }
}
