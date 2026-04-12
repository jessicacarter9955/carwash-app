import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/back_button_widget.dart';

class ServiceScreen extends ConsumerWidget {
  const ServiceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final notifier = ref.read(cartProvider.notifier);

    const services = [
      {
        'key': 'standard',
        'name': 'Standard Wash',
        'desc': 'Exterior + interior · Pickup & delivery included',
        'extra': 0.0,
      },
      {
        'key': 'express',
        'name': 'Express Wash',
        'desc': 'Ready in 2h · Priority service',
        'extra': 4.9,
      },
      {
        'key': 'premium',
        'name': 'Premium Wash',
        'desc': 'Full detail · Wax + polish',
        'extra': 7.5,
      },
    ];

    const addons = [
      {
        'key': 'wax',
        'name': 'Wax Protection',
        'desc': 'Premium carnauba wax',
        'price': 2.0,
      },
      {
        'key': 'interior',
        'name': 'Interior Detailing',
        'desc': 'Deep clean & leather conditioning',
        'price': 1.5,
      },
    ];

    const timeSlots = [
      {'label': 'ASAP', 'sub': '~30 min', 'value': 'ASAP ~30min'},
      {'label': '10:00 – 12:00', 'sub': 'Today', 'value': '10:00 – 12:00'},
      {'label': '14:00 – 16:00', 'sub': 'Today', 'value': '14:00 – 16:00'},
      {'label': '09:00 – 11:00', 'sub': 'Tomorrow', 'value': '09:00 – 11:00'},
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
                  'Service Type',
                  style: headStyle(size: 16, weight: FontWeight.w800),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 100),
              children: [
                _SectionLabel('Select a service'),
                ...services.map(
                  (s) => _SvcOption(
                    label: s['name'] as String,
                    desc: s['desc'] as String,
                    price: s['extra'] as double == 0
                        ? '+\$0'
                        : '+\$${(s['extra'] as double).toStringAsFixed(2)}',
                    selected: cart.selectedService == s['key'],
                    onTap: () => notifier.selectService(s['key'] as String),
                  ),
                ),
                _SectionLabel('Add-ons'),
                ...addons.map(
                  (a) => _SvcOption(
                    label: a['name'] as String,
                    desc: a['desc'] as String,
                    price: '+\$${(a['price'] as double).toStringAsFixed(2)}',
                    selected: cart.addons.contains(a['key']),
                    onTap: () => notifier.toggleAddon(a['key'] as String),
                  ),
                ),
                _SectionLabel('Pickup Time'),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 2.5,
                  children: timeSlots
                      .map(
                        (t) => _TimeSlot(
                          label: t['label']!,
                          sub: t['sub']!,
                          selected: cart.selectedTime == t['value'],
                          onTap: () => notifier.selectTime(t['value']!),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 80),
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
              label: 'Review Order →',
              onTap: () => context.push('/checkout'),
            ),
          ),
        ],
      ),
    );
  }
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

class _SvcOption extends StatelessWidget {
  final String label, desc, price;
  final bool selected;
  final VoidCallback onTap;

  const _SvcOption({
    required this.label,
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
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: kSurface,
          border: Border.all(color: selected ? kCyan : kBorder, width: 1.5),
          borderRadius: BorderRadius.circular(rMd),
          boxShadow: selected
              ? [BoxShadow(color: kCyan.withOpacity(0.15), blurRadius: 12)]
              : shadowXs,
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? kCyan : kBorder2,
                  width: 2,
                ),
                color: selected ? kCyan : Colors.transparent,
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: kCyan.withOpacity(0.2),
                          blurRadius: 6,
                          spreadRadius: 2,
                        ),
                      ]
                    : [],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: headStyle(size: 13, weight: FontWeight.w700),
                  ),
                  Text(desc, style: bodyStyle(size: 11, color: kMuted)),
                ],
              ),
            ),
            Text(
              price,
              style: headStyle(
                size: 13,
                weight: FontWeight.w800,
                color: kCyan3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeSlot extends StatelessWidget {
  final String label, sub;
  final bool selected;
  final VoidCallback onTap;
  const _TimeSlot({
    required this.label,
    required this.sub,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: kSurface,
          border: Border.all(color: selected ? kCyan : kBorder, width: 1.5),
          borderRadius: BorderRadius.circular(rMd),
          boxShadow: shadowXs,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: headStyle(
                size: 12,
                weight: FontWeight.w700,
                color: selected ? kCyan3 : kText,
              ),
            ),
            Text(sub, style: bodyStyle(size: 10, color: kMuted)),
          ],
        ),
      ),
    );
  }
}
