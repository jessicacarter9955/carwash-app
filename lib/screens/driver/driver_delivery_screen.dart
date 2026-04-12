import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../widgets/app_toast.dart';

class DriverDeliveryScreen extends StatefulWidget {
  final VoidCallback onBack, onDone;
  const DriverDeliveryScreen({
    super.key,
    required this.onBack,
    required this.onDone,
  });

  @override
  State<DriverDeliveryScreen> createState() => _DriverDeliveryScreenState();
}

class _DriverDeliveryScreenState extends State<DriverDeliveryScreen> {
  final List<bool> _checks = [false, false, false];

  final List<Map<String, String>> _items = const [
    {'icon': '🚗', 'label': 'Car properly washed'},
    {'icon': '📸', 'label': 'Photo taken at hub'},
    {'icon': '🏷', 'label': 'Order tagged correctly'},
  ];

  @override
  Widget build(BuildContext context) {
    final allChecked = _checks.every((c) => c);

    return Column(
      children: [
        // ── Top bar ───────────────────────────────────────
        Container(
          padding: EdgeInsets.fromLTRB(
            14,
            MediaQuery.of(context).padding.top + 10,
            14,
            10,
          ),
          decoration: BoxDecoration(
            color: kSurface,
            border: Border(bottom: BorderSide(color: kBorder)),
            boxShadow: shadowXs,
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: widget.onBack,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: kBg,
                    border: Border.all(color: kBorder),
                    borderRadius: BorderRadius.circular(rSm),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    size: 14,
                    color: kText,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Drop Off',
                  style: headStyle(size: 16, weight: FontWeight.w900),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: kOrange.withOpacity(0.1),
                  border: Border.all(color: kOrange.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.local_car_wash, size: 12, color: kOrange),
                    const SizedBox(width: 5),
                    Text(
                      'Hub Delivery',
                      style: headStyle(
                        size: 11,
                        weight: FontWeight.w800,
                        color: kOrange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── Body ──────────────────────────────────────────
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
            children: [
              // Drop-off info card
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kCyan.withOpacity(0.08), kCyan.withOpacity(0.03)],
                  ),
                  border: Border.all(color: kCyan.withOpacity(0.25)),
                  borderRadius: BorderRadius.circular(rMd),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: kOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(rSm),
                      ),
                      child: const Icon(
                        Icons.local_car_wash,
                        color: kOrange,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DROP-OFF',
                            style: headStyle(
                              size: 9,
                              weight: FontWeight.w800,
                              color: kMuted,
                            ).copyWith(letterSpacing: 0.6),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'WashGo Hub',
                            style: headStyle(size: 16, weight: FontWeight.w900),
                          ),
                          Text(
                            'Facility confirmed',
                            style: bodyStyle(size: 11, color: kMuted),
                          ),
                        ],
                      ),
                    ),
                    // Progress
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${_checks.where((c) => c).length}/${_checks.length}',
                          style: headStyle(
                            size: 18,
                            weight: FontWeight.w900,
                            color: kCyan,
                          ),
                        ),
                        Text('done', style: bodyStyle(size: 10, color: kMuted)),
                      ],
                    ),
                  ],
                ),
              ),

              // Section label
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  'CHECKLIST',
                  style: headStyle(
                    size: 10,
                    weight: FontWeight.w800,
                    color: kMuted,
                  ).copyWith(letterSpacing: 1.2),
                ),
              ),

              // Checklist items
              ..._items.asMap().entries.map((e) {
                final checked = _checks[e.key];
                return GestureDetector(
                  onTap: () => setState(() => _checks[e.key] = !checked),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: checked ? kCyan.withOpacity(0.06) : kSurface,
                      border: Border.all(
                        color: checked ? kCyan : kBorder,
                        width: checked ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(rMd),
                      boxShadow: checked ? shadowSm : shadowXs,
                    ),
                    child: Row(
                      children: [
                        Text(
                          e.value['icon']!,
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            e.value['label']!,
                            style: headStyle(
                              size: 13,
                              weight: FontWeight.w700,
                              color: checked ? kCyan3 : kText,
                            ),
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: checked ? kCyan : Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: checked ? kCyan : kBorder2,
                              width: 2,
                            ),
                          ),
                          child: checked
                              ? const Icon(
                                  Icons.check,
                                  size: 14,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 10),

              // Tip if not all checked
              if (!allChecked)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: kOrange.withOpacity(0.08),
                    border: Border.all(color: kOrange.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(rSm),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 14, color: kOrange),
                      const SizedBox(width: 8),
                      Text(
                        'Complete all checklist items to confirm',
                        style: bodyStyle(size: 11, color: kOrange),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),

        // ── Bottom bar ────────────────────────────────────
        Container(
          padding: EdgeInsets.fromLTRB(
            14,
            12,
            14,
            MediaQuery.of(context).padding.bottom + 12,
          ),
          decoration: BoxDecoration(
            color: kSurface,
            border: Border(top: BorderSide(color: kBorder)),
            boxShadow: shadowMd,
          ),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: allChecked
                  ? () {
                      showToast(context, '✅ Drop-off confirmed!');
                      Future.delayed(
                        const Duration(milliseconds: 800),
                        widget.onDone,
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: kCyan,
                foregroundColor: Colors.white,
                disabledBackgroundColor: kBorder,
                disabledForegroundColor: kMuted,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(rMd),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_outline, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Confirm Drop-off at Hub',
                    style: headStyle(
                      size: 14,
                      weight: FontWeight.w800,
                      color: allChecked ? Colors.white : kMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
