import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../state/app_state.dart';

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
    final weekly = _trips.fold<double>(
        0, (s, t) => s + (t['earn'] as double)) *
        2.8;

    return Column(
      children: [
        // ── Top bar ───────────────────────────────────────
        Container(
          padding: EdgeInsets.fromLTRB(
              14, MediaQuery.of(context).padding.top + 10, 14, 10),
          decoration: BoxDecoration(
            color: kSurface,
            border: Border(bottom: BorderSide(color: kBorder)),
            boxShadow: shadowXs,
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: onBack,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: kBg,
                    border: Border.all(color: kBorder),
                    borderRadius: BorderRadius.circular(rSm),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new,
                      size: 14, color: kText),
                ),
              ),
              const SizedBox(width: 12),
              Text('Earnings',
                  style:
                      headStyle(size: 16, weight: FontWeight.w900)),
            ],
          ),
        ),

        // ── Body ──────────────────────────────────────────
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 30),
            children: [
              // Hero card
              Container(
                padding: const EdgeInsets.all(22),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [kCyan3, kCyan],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(rXl),
                  boxShadow: [
                    BoxShadow(
                      color: kCyan.withOpacity(0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text('TOTAL THIS WEEK',
                        style: headStyle(
                            size: 11,
                            weight: FontWeight.w800,
                            color: Colors.white.withOpacity(0.7))
                          ..copyWith(letterSpacing: 0.8)),
                    const SizedBox(height: 8),
                    Text(
                      state.fmt(weekly),
                      style: headStyle(
                          size: 38,
                          weight: FontWeight.w900,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.trending_up,
                              size: 13, color: Colors.white),
                          const SizedBox(width: 4),
                          Text('↑ 23% vs last week',
                              style: headStyle(
                                  size: 11,
                                  weight: FontWeight.w700,
                                  color: Colors.white)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Quick stats
              Row(
                children: [
                  _StatCard(
                      label: 'Trips', value: '${_trips.length * 7}'),
                  const SizedBox(width: 8),
                  _StatCard(
                      label: 'Avg/Trip',
                      value: state.fmt(weekly / (_trips.length * 7))),
                  const SizedBox(width: 8),
                  _StatCard(label: 'Rating', value: '4.9★'),
                ],
              ),
              const SizedBox(height: 16),

              // Bar chart
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kSurface,
                  border: Border.all(color: kBorder),
                  borderRadius: BorderRadius.circular(rMd),
                  boxShadow: shadowXs,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('This Week',
                        style: headStyle(
                            size: 13, weight: FontWeight.w800)),
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: _bars.asMap().entries.map((e) {
                        final isToday = e.key == 4; // Friday
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 3),
                            child: Column(
                              children: [
                                Container(
                                  height: 70 * e.value / 100,
                                  decoration: BoxDecoration(
                                    color: isToday
                                        ? kCyan
                                        : kCyan.withOpacity(0.3),
                                    borderRadius:
                                        const BorderRadius.vertical(
                                      top: Radius.circular(4),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: _days
                          .map((d) => Expanded(
                                child: Text(d,
                                    textAlign: TextAlign.center,
                                    style: headStyle(
                                        size: 9,
                                        weight: FontWeight.w700,
                                        color: kMuted)),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Recent trips
              Text('RECENT TRIPS',
                  style: headStyle(
                          size: 10,
                          weight: FontWeight.w800,
                          color: kMuted)
                      .copyWith(letterSpacing: 1.2)),
              const SizedBox(height: 10),

              Container(
                decoration: BoxDecoration(
                  color: kSurface,
                  border: Border.all(color: kBorder),
                  borderRadius: BorderRadius.circular(rMd),
                  boxShadow: shadowXs,
                ),
                child: Column(
                  children: _trips.asMap().entries.map((e) {
                    final isLast = e.key == _trips.length - 1;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        border: !isLast
                            ? const Border(
                                bottom:
                                    BorderSide(color: kBorder))
                            : null,
                      ),
                      child: Row(
                        children: [
                          Container(
                