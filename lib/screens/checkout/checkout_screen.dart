import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../providers/cart_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/order_provider.dart';
import '../../services/stripe_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/back_button_widget.dart';

class CheckoutScreen extends ConsumerWidget {
  const CheckoutScreen({super.key});

  // Demo mode flag - set to true to bypass payment
  static const bool _demoMode = true;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final location = ref.watch(locationProvider);
    final orderState = ref.watch(orderProvider);
    final notifier = ref.read(cartProvider.notifier);

    const paymentMethods = [
      {
        'key': 'card',
        'icon': Icons.credit_card,
        'label': 'Credit / Debit Card',
      },
      {'key': 'cash', 'icon': Icons.payments, 'label': 'Cash on Pickup'},
    ];

    return Scaffold(
      backgroundColor: kBg,
      body: Column(
        children: [
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
                  'Order Summary',
                  style: headStyle(size: 16, weight: FontWeight.w800),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 100),
              children: [
                // Pickup info
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 10, color: kMuted),
                          const SizedBox(width: 4),
                          Text(
                            'PICKUP',
                            style: headStyle(
                              size: 10,
                              weight: FontWeight.w800,
                              color: kMuted,
                            ).copyWith(letterSpacing: 0.5),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        location.address,
                        style: bodyStyle(size: 13, weight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 10, color: kMuted),
                          const SizedBox(width: 4),
                          Text(
                            'SLOT: ${cart.selectedTime}',
                            style: headStyle(
                              size: 10,
                              weight: FontWeight.w700,
                              color: kMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _SectionLabel('Price Breakdown'),
                _Card(
                  child: Column(
                    children: [
                      _PriceRow(
                        'Items subtotal',
                        '\$${cart.itemsTotal.toStringAsFixed(2)}',
                      ),
                      _PriceRow(
                        'Service upgrade',
                        '\$${cart.serviceExtra.toStringAsFixed(2)}',
                      ),
                      _PriceRow(
                        'Add-ons',
                        '\$${cart.addonExtra.toStringAsFixed(2)}',
                      ),
                      _PriceRow('Pickup & Delivery', '\$2.99'),
                      const Divider(height: 16, color: kBorder),
                      _PriceRow(
                        'Total',
                        '\$${cart.total.toStringAsFixed(2)}',
                        isTotal: true,
                      ),
                    ],
                  ),
                ),
                _SectionLabel('Payment'),
                ...paymentMethods.map(
                  (pm) => _PaymentRow(
                    icon: pm['icon'] as IconData,
                    label: pm['label'] as String,
                    selected: cart.selectedPaymentMethod == pm['key'] as String,
                    onTap: () => notifier.selectPayment(pm['key'] as String),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock, size: 12, color: kMuted),
                    const SizedBox(width: 4),
                    Text(
                      'Secured by Stripe',
                      style: bodyStyle(
                        size: 11,
                        weight: FontWeight.w600,
                        color: kMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [kBg, kBg.withOpacity(0)],
              ),
            ),
            child: AppButton(
              label: _demoMode
                  ? 'Place Order (Demo) · \$${cart.total.toStringAsFixed(2)}'
                  : 'Place Order · \$${cart.total.toStringAsFixed(2)}',
              loading: orderState.loading,
              onTap: () async {
                if (cart.selectedPaymentMethod == 'card' && !_demoMode) {
                  // Stripe payment flow
                  try {
                    final stripeService = StripeService();
                    await stripeService.presentPaymentSheet(
                      amount: (cart.total * 100).toInt(), // Convert to cents
                      currency: 'eur',
                      description: 'WashGo Order',
                    );
                    showToast(context, 'Payment successful!');
                  } catch (e) {
                    showToast(context, 'Payment failed: $e');
                    return;
                  }
                } else if (_demoMode) {
                  showToast(context, 'Demo mode: Payment bypassed');
                }

                final success = await ref
                    .read(orderProvider.notifier)
                    .placeOrder(localMode: true);
                if (success && context.mounted) {
                  ref.read(cartProvider.notifier).reset();
                  context.push('/searching');
                } else if (context.mounted) {
                  showToast(
                    context,
                    'Error: ${ref.read(orderProvider).error ?? 'Failed to place order'}',
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: kSurface,
          border: Border.all(color: kBorder),
          borderRadius: BorderRadius.circular(rMd),
          boxShadow: shadowXs,
        ),
        child: child,
      );
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 8),
        child: Text(
          text.toUpperCase(),
          style: headStyle(
            size: 10,
            weight: FontWeight.w800,
            color: kMuted,
          ).copyWith(letterSpacing: 1.2),
        ),
      );
}

class _PriceRow extends StatelessWidget {
  final String label, value;
  final bool isTotal;
  const _PriceRow(this.label, this.value, {this.isTotal = false});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: isTotal
                  ? headStyle(size: 15, weight: FontWeight.w800)
                  : bodyStyle(size: 13),
            ),
            Text(
              value,
              style: isTotal
                  ? headStyle(size: 15, weight: FontWeight.w800, color: kCyan3)
                  : bodyStyle(size: 13, weight: FontWeight.w700),
            ),
          ],
        ),
      );
}

class _PaymentRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _PaymentRow({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
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
            Icon(icon, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: bodyStyle(size: 13, weight: FontWeight.w600),
              ),
            ),
            AnimatedOpacity(
              opacity: selected ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: const Icon(Icons.check_circle, color: kCyan, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
