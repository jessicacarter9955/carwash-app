import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../widgets/app_toast.dart';

class ExpressScreen extends StatefulWidget {
  const ExpressScreen({super.key});

  @override
  State<ExpressScreen> createState() => _ExpressScreenState();
}

class _ExpressScreenState extends State<ExpressScreen> {
  int _selectedPlan = 1;

  final List<Map<String, dynamic>> _plans = [
    {
      'name': 'Flash',
      'time': '2 hrs',
      'price': 24.99,
      'icon': '⚡',
      'color': kOrange,
      'features': ['Exterior wash', 'Interior vacuum', 'Window clean'],
    },
    {
      'name': 'Turbo',
      'time': '1 hr',
      'price': 39.99,
      'icon': '🚀',
      'color': kCyan,
      'features': [
        'Full detailing',
        'Wax & polish',
        'Interior deep clean',
        'Tire shine',
      ],
    },
    {
      'name': 'Instant',
      'time': '30 min',
      'price': 59.99,
      'icon': '🔥',
      'color': kRed,
      'features': [
        'Priority dispatch',
        'Full detailing',
        'Premium wax',
        'Interior & exterior',
        'Dedicated washer',
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final plan = _plans[_selectedPlan];

    return Scaffold(
      backgroundColor: kBg,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: kCyan,
            leading: GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(rSm),
                ),
                child: const Icon(Icons.arrow_back_ios_new,
                    color: Colors.white, size: 16),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kCyan3, kCyan],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    // Background circles
                    Positioned(
                      top: -40,
                      right: -40,
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -20,
                      left: -20,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                          20, MediaQuery.of(context).padding.top + 50, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.bolt,
                                    color: Colors.white, size: 14),
                                const SizedBox(width: 4),
                                Text('EXPRESS SERVICE',
                                    style: headStyle(
                                        size: 10,
                                        weight: FontWeight.w800,
                                        color: Colors.white)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('Fast & Premium\nCar Wash',
                              style: headStyle(
                                  size: 26,
                                  weight: FontWeight.w900,
                                  color: Colors.white)),
                          const SizedBox(height: 4),
                          Text('Priority dispatch • Pro washers',
                              style: bodyStyle(
                                  size: 12,
                                  color: Colors.white.withOpacity(0.8))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ETA Banner
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          kOrange.withOpacity(0.12),
                          kOrange.withOpacity(0.04)
                        ],
                      ),
                      border: Border.all(color: kOrange.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(rMd),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: kOrange.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(rSm),
                          ),
                          child: const Icon(Icons.timer_outlined,
                              color: kOrange, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Washer arrives in ~12 min',
                                  style: headStyle(
                                      size: 13, weight: FontWeight.w800)),
                              Text('3 washers available near you',
                                  style:
                                      bodyStyle(size: 11, color: kMuted)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: kOrange,
                            borderRadius: BorderRadius.circular(rSm),
                          ),
                          child: Text('LIVE',
                              style: headStyle(
                                  size: 9,
                                  weight: FontWeight.w800,
                                  color: Colors.white)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text('Choose Your Speed',
                      style: headStyle(size: 16, weight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text('All plans include pickup & delivery',
                      style: bodyStyle(size: 12, color: kMuted)),
                  const SizedBox(height: 12),

                  // Plan cards
                  ...List.generate(_plans.length, (i) {
                    final p = _plans[i];
                    final selected = _selectedPlan == i;
                    final color = p['color'] as Color;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedPlan = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: selected
                              ? color.withOpacity(0.07)
                              : kSurface,
                          border: Border.all(
                            color: selected ? color : kBorder,
                            width: selected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(rMd),
                          boxShadow: selected ? shadowSm : shadowXs,
                        ),
                        child: Row(
                          children: [
                            // Icon
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(rSm),
                              ),
                              child: Center(
                                child: Text(p['icon'] as String,
                                    style:
                                        const TextStyle(fontSize: 24)),
                              ),
                            ),
                            const SizedBox(width: 14),
                            // Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(p['name'] as String,
                                          style: headStyle(
                                              size: 15,
                                              weight: FontWeight.w800)),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 2),
                                        decoration: BoxDecoration(
                                          color: color.withOpacity(0.15),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(p['time'] as String,
                                            style: headStyle(
                                                size: 9,
                                                weight: FontWeight.w700,
                                                color: color)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Wrap(
                                    spacing: 4,
                                    runSpacing: 2,
                                    children: (p['features'] as List<String>)
                                        .map((f) => Text('• $f',
                                            style: bodyStyle(
                                                size: 10,
                                                color: kMuted)))
                                        .toList(),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Price + radio
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '€${(p['price'] as double).toStringAsFixed(2)}',
                                  style: headStyle(
                                      size: 16,
                                      weight: FontWeight.w900,
                                      color: color),
                                ),
                                const SizedBox(height: 6),
                                AnimatedContainer(
                                  duration:
                                      const Duration(milliseconds: 200),
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: selected ? color : Colors.transparent,
                                    border: Border.all(
                                        color: selected ? color : kBorder2,
                                        width: 2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: selected
                                      ? const Icon(Icons.check,
                                          size: 12, color: Colors.white)
                                      : null,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 20),

                  // What's included
                  Text('What\'s Included',
                      style: headStyle(size: 16, weight: FontWeight.w900)),
                  const SizedBox(height: 12),
                  _IncludedGrid(),

                  const SizedBox(height: 20),

                  // Washers nearby
                  Text('Washers Near You',
                      style: headStyle(size: 16, weight: FontWeight.w900)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 110,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: const [
                        _WasherCard(
                            name: 'Marco R.',
                            rating: 4.9,
                            distance: '0.8 km',
                            jobs: 312,
                            emoji: '👨‍🔧'),
                        _WasherCard(
                            name: 'Sofia L.',
                            rating: 4.8,
                            distance: '1.2 km',
                            jobs: 198,
                            emoji: '👩‍🔧'),
                        _WasherCard(
                            name: 'Luca M.',
                            rating: 4.7,
                            distance: '1.5 km',
                            jobs: 245,
                            emoji: '👨‍🔧'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom CTA
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
            16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
        decoration: BoxDecoration(
          color: kSurface,
          border: Border(top: BorderSide(color: kBorder)),
          boxShadow: shadowMd,
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total',
                  style: bodyStyle(size: 11, color: kMuted)),
              Text(
                '€${(_plans[_selectedPlan]['price'] as double).toStringAsFixed(2)}',
                style: headStyle(size: 22, weight: FontWeight.w900, color: kCyan),
              ),
            ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  showToast(context,
                      '⚡ ${_plans[_selectedPlan]['name']} express booked!');
                  context.push('/searching');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kCyan,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(rMd),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.bolt, size: 18),
                    const SizedBox(width: 6),
                    Text('Book Express',
                        style: headStyle(
                            size: 15,
                            weight: FontWeight.w800,
                            color: Colors.white)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IncludedGrid extends StatelessWidget {
  final List<Map<String, dynamic>> items = const [
    {'icon': '🚿', 'label': 'Exterior Wash'},
    {'icon': '🪣', 'label': 'Interior Clean'},
    {'icon': '✨', 'label': 'Wax & Polish'},
    {'icon': '🪟', 'label': 'Window Clean'},
    {'icon': '🛞', 'label': 'Tire Shine'},
    {'icon': '🌿', 'label': 'Eco Products'},
  ];

  const _IncludedGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 1.4,
      children: items
          .map((item) => Container(
                decoration: BoxDecoration(
                  color: kSurface,
                  border: Border.all(color: kBorder),
                  borderRadius: BorderRadius.circular(rSm),
                  boxShadow: shadowXs,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(item['icon'] as String,
                        style: const TextStyle(fontSize: 22)),
                    const SizedBox(height: 4),
                    Text(item['label'] as String,
                        style: headStyle(size: 9, weight: FontWeight.w700),
                        textAlign: TextAlign.center),
                  ],
                ),
              ))
          .toList(),
    );
  }
}

class _WasherCard extends StatelessWidget {
  final String name;
  final double rating;
  final String distance;
  final int jobs;
  final String emoji;

  const _WasherCard({
    required this.name,
    required this.rating,
    required this.distance,
    required this.jobs,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kSurface,
        border: Border.all(color: kBorder),
        borderRadius: BorderRadius.circular(rMd),
        boxShadow: shadowXs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              const Spacer(),
              const Icon(Icons.star_rounded, color: kYellow, size: 13),
              const SizedBox(width: 2),
              Text(rating.toString(),
                  style: headStyle(size: 11, weight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 6),
          Text(name,
              style: headStyle(size: 12, weight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text('$distance • $jobs jobs',
              style: bodyStyle(size: 10, color: kMuted)),
        ],
      ),
    );
  }
}
