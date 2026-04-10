import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../state/app_state.dart';
import '../../widgets/shared.dart';

class DriverEarningsScreen extends StatelessWidget {
  final VoidCallback onBack;
  const DriverEarningsScreen({super.key, required this.onBack});

  static const _trips = [
    {'route': 'Via Roma → WashGo Hub', 'time': '14:30', 'earn': 12.50},
    {'route': 'Colosseum → WashGo Hub', 'time': '12:15', 'earn': 15.20},
    {'route': 'Termini → WashGo Hub', 'time': '10:45', 'earn': 9.80},
    {'route': 'Vatican → WashGo Hub', 'time': '09:20', 'earn': 18.40},
  ];

  static const _bars = [40, 55, 35, 65, 80, 70, 90];
  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final weekly =
        _trips.fold<double>(0, (s, t) => s + (t['earn'] as double)) * 2.8;
    return Column(
      children: [
        AppHeader(title: 'Earnings', onBack: onBack),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 30),
            children: [
              // Hero
              Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kCyan3.withOpacity(.12), kMint.withOpacity(.08)],
                  ),
                  border: Border.all(color: kCyan3.withOpacity(.25)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Text(
                      'TOTAL THIS WEEK',
                      style: TextStyle(
                        fontFamily: kFontHead,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: kMuted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      state.fmt(weekly),
                      style: const TextStyle(
                        fontFamily: kFontHead,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: kCyan3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '↑ 23% vs last week',
                      style: TextStyle(
                        fontSize: 11,
                        color: kMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // Bar chart
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: _bars
                    .asMap()
                    .entries
                    .map(
                      (e) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: Column(
                            children: [
                              Container(
                                height: 70 * e.value / 100,
                                decoration: BoxDecoration(
                                  color: e.key % 2 == 0 ? kCyan3 : kMint,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(4),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 4),
              Row(
                children: _days
                    .map(
                      (d) => Expanded(
                        child: Text(
                          d,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 9,
                            color: kMuted,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SecLabel('Recent Trips'),
              Container(
                decoration: BoxDecoration(
                  color: kSurface,
                  border: Border.all(color: kBorder),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: _trips
                      .asMap()
                      .entries
                      .map(
                        (e) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            border: e.key < _trips.length - 1
                                ? const Border(
                                    bottom: BorderSide(color: kBorder),
                                  )
                                : null,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      e.value['route'] as String,
                                      style: const TextStyle(
                                        fontFamily: kFontHead,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      e.value['time'] as String,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: kMuted,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                state.fmt(e.value['earn'] as double),
                                style: const TextStyle(
                                  fontFamily: kFontHead,
                                  fontWeight: FontWeight.w800,
                                  color: kCyan3,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
