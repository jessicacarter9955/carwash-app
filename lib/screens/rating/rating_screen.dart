import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../providers/order_provider.dart';
import '../../widgets/app_button.dart';

class RatingScreen extends ConsumerStatefulWidget {
  const RatingScreen({super.key});
  @override
  ConsumerState<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends ConsumerState<RatingScreen> {
  int _rating = 0;
  final Set<String> _tags = {};

  static const _tagOptions = [
    'Great Service 👍',
    'On Time ⏰',
    'Clean & Fresh 🧺',
    'Friendly Driver 😊'
  ];

  Future<void> _submit() async {
    await ref
        .read(orderProvider.notifier)
        .submitRating(_rating, _tags.toList());
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final order = ref.watch(orderProvider).currentOrder;
    final total = order?.total ?? 0;

    return Scaffold(
      backgroundColor: kBg,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('✅', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 14),
              Text('Order Complete!',
                  style: headStyle(size: 22, weight: FontWeight.w900)),
              const SizedBox(height: 6),
              Text('Your laundry is delivered',
                  style: bodyStyle(
                      size: 13, weight: FontWeight.w600, color: kMuted)),
              const SizedBox(height: 16),
              Text('\$${total.toStringAsFixed(2)}',
                  style: headStyle(
                      size: 34, weight: FontWeight.w900, color: kCyan3)),
              Text('Payment confirmed',
                  style: bodyStyle(
                      size: 13, weight: FontWeight.w600, color: kMuted)),
              const SizedBox(height: 20),
              Text('Rate your experience',
                  style: headStyle(size: 14, weight: FontWeight.w800)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                    5,
                    (i) => GestureDetector(
                          onTap: () => setState(() => _rating = i + 1),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              '★',
                              style: TextStyle(
                                  fontSize: 32,
                                  color: i < _rating ? kYellow : kBorder2),
                            ),
                          ),
                        )),
              ),
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.center,
                children: _tagOptions
                    .map((tag) => GestureDetector(
                          onTap: () => setState(() => _tags.contains(tag)
                              ? _tags.remove(tag)
                              : _tags.add(tag)),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            margin: const EdgeInsets.all(4),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: _tags.contains(tag)
                                  ? kCyan.withOpacity(0.1)
                                  : kSurface,
                              border: Border.all(
                                  color: _tags.contains(tag) ? kCyan : kBorder,
                                  width: 1.5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(tag,
                                style: headStyle(
                                    size: 11,
                                    weight: FontWeight.w700,
                                    color:
                                        _tags.contains(tag) ? kCyan3 : kText)),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 24),
              AppButton(label: 'Done 🏠', onTap: _submit, width: 220),
            ],
          ),
        ),
      ),
    );
  }
}
