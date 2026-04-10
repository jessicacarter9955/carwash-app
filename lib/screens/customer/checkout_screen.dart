import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../state/app_state.dart';
import '../../services/order_service.dart';
import '../../widgets/toast_overlay.dart';
import '../../widgets/shared.dart';

class CheckoutScreen extends StatefulWidget {
  final VoidCallback onBack, onOrder;
  const CheckoutScreen({
    super.key,
    required this.onBack,
    required this.onOrder,
  });
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _placing = false;

  Future<void> _placeOrder() async {
    final state = context.read<AppState>();
    if (state.itemsTotal == 0) {
      showToast('⚠️ Add items first');
      return;
    }
    if (state.currentUserId == null) {
      showToast('⚠️ Please sign in');
      return;
    }
    setState(() => _placing = true);
    showToast('💳 Processing payment...');
    await Future.delayed(const Duration(milliseconds: 1500));
    final order = OrderService.placeDemoOrder(
      customerId: state.currentUserId!,
      serviceType: state.selectedService.label.toLowerCase(),
      orderItems: {},
      total: state.grandTotal,
      pickupAddress: 'Demo Address',
      lat: state.userLat,
      lng: state.userLng,
    );
    state.setCurrentOrder(order);
    showToast('✅ Order placed! ${state.fmt(state.grandTotal)}');
    if (mounted) setState(() => _placing = false);
    widget.onOrder();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Column(
      children: [
        AppHeader(title: 'Order Summary', onBack: widget.onBack),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 100),
            children: [
              // Pickup card
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📍 PICKUP',
                      style: TextStyle(
                        fontFamily: kFontHead,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: kMuted,
                        letterSpacing: .5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Detecting...',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Text(
                          '🕐 SLOT: ',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: kMuted,
                          ),
                        ),
                        Text(
                          state.selectedTime,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SecLabel('Price Breakdown'),
              AppCard(
                child: Column(
                  children: [
                    _PriceRow(
                      label: 'Items subtotal',
                      value: state.fmt(state.itemsTotal),
                    ),
                    _PriceRow(
                      label: 'Service upgrade',
                      value: state.fmt(state.serviceExtra),
                    ),
                    _PriceRow(
                      label: 'Add-ons',
                      value: state.fmt(state.addonTotal),
                    ),
                    _PriceRow(
                      label: 'Pickup & Delivery',
                      value: state.fmt(kDeliveryFee),
                    ),
                    _PriceRow(
                      label: 'Total',
                      value: state.fmt(state.grandTotal),
                      isTotal: true,
                    ),
                  ],
                ),
              ),
              const SecLabel('Payment'),
              _PaymentRow(
                id: PaymentMethod.card,
                emoji: '💳',
                label: 'Credit / Debit Card',
                state: state,
              ),
              _PaymentRow(
                id: PaymentMethod.apple,
                emoji: '🍎',
                label: 'Apple Pay',
                state: state,
              ),
              _PaymentRow(
                id: PaymentMethod.cash,
                emoji: '💵',
                label: 'Cash on Pickup',
                state: state,
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  '🔒 Secured by Stripe',
                  style: TextStyle(
                    fontSize: 11,
                    color: kMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        BottomBar(
          child: PrimaryBtn(
            label: _placing
                ? 'Processing...'
                : '🧺 Place Order · ${state.fmt(state.grandTotal)}',
            onTap: _placing ? null : _placeOrder,
          ),
        ),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label, value;
  final bool isTotal;
  const _PriceRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 15 : 13,
              fontWeight: isTotal ? FontWeight.w800 : FontWeight.w400,
              fontFamily: isTotal ? kFontHead : null,
              color: isTotal ? kCyan3 : kText,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: isTotal ? 15 : 13,
              color: isTotal ? kCyan3 : kText,
              fontFamily: isTotal ? kFontHead : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  final PaymentMethod id;
  final String emoji, label;
  final AppState state;
  const _PaymentRow({
    required this.id,
    required this.emoji,
    required this.label,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final sel = state.selectedPM == id;
    return GestureDetector(
      onTap: () => state.selectPM(id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: sel ? kCyan3.withOpacity(.06) : kSurface,
          border: Border.all(
            color: sel ? kCyan3 : kBorder,
            width: sel ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 26,
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A5F),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            AnimatedOpacity(
              opacity: sel ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: const Text(
                '✓',
                style: TextStyle(color: kCyan3, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
