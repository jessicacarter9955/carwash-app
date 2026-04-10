import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../widgets/toast_overlay.dart';
import '../../widgets/shared.dart';

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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: const BoxDecoration(
            color: kSurface,
            border: Border(bottom: BorderSide(color: kBorder)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Drop Off',
                style: TextStyle(
                  fontFamily: kFontHead,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: kMint.withOpacity(.1),
                  border: Border.all(color: kMint.withOpacity(.3)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  '🏭 Hub Delivery',
                  style: TextStyle(
                    fontFamily: kFontHead,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: kMint2,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 100),
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DROP-OFF',
                      style: TextStyle(
                        fontFamily: kFontHead,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: kMint2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'WashGo Hub',
                      style: TextStyle(
                        fontFamily: kFontHead,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 5,
                      decoration: BoxDecoration(
                        color: kBorder,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: .65,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [kCyan3, kMint],
                            ),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SecLabel('Checklist'),
              ...[
                ['👕', 'All items collected'],
                ['📸', 'Photo taken'],
                ['🏷', 'Order tagged correctly'],
              ].asMap().entries.map(
                (e) => GestureDetector(
                  onTap: () => setState(() => _checks[e.key] = !_checks[e.key]),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: _checks[e.key]
                          ? kCyan3.withOpacity(.06)
                          : kSurface,
                      border: Border.all(
                        color: _checks[e.key] ? kCyan3 : kBorder,
                        width: _checks[e.key] ? 1.5 : 1,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Text(e.value[0], style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            e.value[1],
                            style: const TextStyle(
                              fontFamily: kFontHead,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          _checks[e.key] ? '✓' : '○',
                          style: TextStyle(
                            fontSize: 18,
                            color: _checks[e.key] ? kCyan3 : kMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        BottomBar(
          child: ElevatedButton(
            onPressed: () {
              showToast('✅ Drop-off confirmed! Earnings updated');
              Future.delayed(const Duration(milliseconds: 800), widget.onDone);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kCyan3,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              '✓ Confirm Drop-off at Hub',
              style: TextStyle(
                fontFamily: kFontHead,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
