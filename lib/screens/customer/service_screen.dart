import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../state/app_state.dart';
import '../../widgets/service_option.dart';
import '../../widgets/shared.dart';

class ServiceScreen extends StatelessWidget {
  final VoidCallback onBack, onNext;
  const ServiceScreen({super.key, required this.onBack, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Column(
      children: [
        AppHeader(title: 'Service Type', onBack: onBack),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
            children: [
              const SecLabel('Select a service'),
              ServiceOption(
                name: 'Standard Wash',
                desc: 'Ready in 48h · Pickup & delivery included',
                price: '+\$0',
                selected: state.selectedService == ServiceType.standard,
                onTap: () => state.selectService(ServiceType.standard),
              ),
              ServiceOption(
                name: 'Express Wash ⚡',
                desc: 'Ready in 24h · Priority driver',
                price: '+\$4.90',
                selected: state.selectedService == ServiceType.express,
                onTap: () => state.selectService(ServiceType.express),
              ),
              ServiceOption(
                name: 'Dry Cleaning 🌟',
                desc: 'Delicate fabrics · Special treatment',
                price: '+\$7.50',
                selected: state.selectedService == ServiceType.dryclean,
                onTap: () => state.selectService(ServiceType.dryclean),
              ),
              const SecLabel('Add-ons'),
              ...state.addons.values.map(
                (a) => ServiceOption(
                  name: a.name,
                  desc: a.key == 'fold'
                      ? 'Neatly folded in eco bags'
                      : 'Lavender, Cotton Fresh or Sport',
                  price: '+\$${a.price.toStringAsFixed(2)}',
                  selected: a.selected,
                  onTap: () => state.toggleAddon(a.key),
                ),
              ),
              const SecLabel('Pickup Time'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _TimeSlot(label: '⚡ ASAP', sub: '~30 min', state: state),
                  _TimeSlot(label: '10:00 – 12:00', sub: 'Today', state: state),
                  _TimeSlot(label: '14:00 – 16:00', sub: 'Today', state: state),
                  _TimeSlot(
                    label: '09:00 – 11:00',
                    sub: 'Tomorrow',
                    state: state,
                  ),
                ],
              ),
            ],
          ),
        ),
        BottomBar(
          child: PrimaryBtn(label: 'Review Order →', onTap: onNext),
        ),
      ],
    );
  }
}

class _TimeSlot extends StatelessWidget {
  final String label, sub;
  final AppState state;
  const _TimeSlot({
    required this.label,
    required this.sub,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final sel =
        state.selectedTime == label ||
        (label.contains('ASAP') && state.selectedTime.contains('ASAP'));
    return GestureDetector(
      onTap: () => state.selectTime(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: sel ? kCyan3.withOpacity(.08) : kSurface,
          border: Border.all(
            color: sel ? kCyan3 : kBorder,
            width: sel ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: kFontHead,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: sel ? kCyan3 : kText,
              ),
            ),
            Text(sub, style: const TextStyle(fontSize: 10, color: kMuted)),
          ],
        ),
      ),
    );
  }
}
