import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../widgets/app_toast.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _selectedTime = '10:00';
  int _selectedService = 0;
  bool _recurring = false;
  String _recurringFreq = 'Weekly';

  final List<String> _timeSlots = [
    '08:00', '09:00', '10:00', '11:00',
    '12:00', '14:00', '15:00', '16:00', '17:00',
  ];

  final List<Map<String, dynamic>> _services = [
    {
      'name': 'Basic Wash',
      'price': 14.99,
      'duration': '45 min',
      'icon': '🚿',
      'desc': 'Exterior wash + rinse',
    },
    {
      'name': 'Full Detail',
      'price': 29.99,
      'duration': '90 min',
      'icon': '✨',
      'desc': 'Interior & exterior detailing',
    },
    {
      'name': 'Premium',
      'price': 49.99,
      'duration': '2 hrs',
      'icon': '👑',
      'desc': 'Full detail + wax + polish',
    },
  ];

  final List<String> _freqOptions = ['Weekly', 'Bi-weekly', 'Monthly'];

  List<DateTime> _getNextDays(int count) {
    return List.generate(
        count, (i) => DateTime.now().add(Duration(days: i + 1)));
  }

  String _dayLabel(DateTime d) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[d.weekday - 1];
  }

  String _monthLabel(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[d.month - 1];
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final days = _getNextDays(14);
    final service = _services[_selectedService];

    return Scaffold(
      backgroundColor: kBg,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: kMint,
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
                    colors: [Color(0xFF1E40AF), kMint],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -30,
                      right: -30,
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                          20,
                          MediaQuery.of(context).padding.top + 50,
                          20,
                          20),
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
                                const Icon(Icons.calendar_today,
                                    color: Colors.white, size: 12),
                                const SizedBox(width: 4),
                                Text('SCHEDULE SERVICE',
                                    style: headStyle(
                                        size: 10,
                                        weight: FontWeight.w800,
                                        color: Colors.white)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('Book Your\nWash Ahead',
                              style: headStyle(
                                  size: 26,
                                  weight: FontWeight.w900,
                                  color: Colors.white)),
                          const SizedBox(height: 4),
                          Text('Choose date, time & service',
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
                  // Date picker
                  Text('Select Date',
                      style: headStyle(size: 16, weight: FontWeight.w900)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 76,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: days.length,
                      itemBuilder: (context, i) {
                        final day = days[i];
                        final selected = _isSameDay(day, _selectedDate);
                        return GestureDetector(
                          onTap: () => setState(() => _selectedDate = day),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 56,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: selected ? kCyan : kSurface,
                              border: Border.all(
                                  color: selected ? kCyan : kBorder,
                                  width: selected ? 2 : 1),
                              borderRadius: BorderRadius.circular(rMd),
                              boxShadow: selected ? shadowSm : shadowXs,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _dayLabel(day),
                                  style: headStyle(
                                      size: 10,
                                      weight: FontWeight.w700,
                                      color: selected
                                          ? Colors.white.withOpacity(0.8)
                                          : kMuted),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${day.day}',
                                  style: headStyle(
                                      size: 18,
                                      weight: FontWeight.w900,
                                      color: selected
                                          ? Colors.white
                                          : kText),
                                ),
                                Text(
                                  _monthLabel(day),
                                  style: headStyle(
                                      size: 9,
                                      weight: FontWeight.w600,
                                      color: selected
                                          ? Colors.white.withOpacity(0.7)
                                          : kMuted),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Time slots
                  Text('Select Time',
                      style: headStyle(size: 16, weight: FontWeight.w900)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _timeSlots.map((slot) {
                      final selected = _selectedTime == slot;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedTime = slot),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: selected ? kCyan : kSurface,
                            border: Border.all(
                                color: selected ? kCyan : kBorder,
                                width: selected ? 2 : 1),
                            borderRadius: BorderRadius.circular(rSm),
                            boxShadow: selected ? shadowSm : shadowXs,
                          ),
                          child: Text(
                            slot,
                            style: headStyle(
                                size: 13,
                                weight: FontWeight.w700,
                                color:
                                    selected ? Colors.white : kText),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // Service selection
                  Text('Select Service',
                      style: headStyle(size: 16, weight: FontWeight.w900)),
                  const SizedBox(height: 12),
                  ...List.generate(_services.length, (i) {
                    final s = _services[i];
                    final selected = _selectedService == i;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedService = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color:
                              selected ? kCyan.withOpacity(0.07) : kSurface,
                          border: Border.all(
                              color: selected ? kCyan : kBorder,
                              width: selected ? 2 : 1),
                          borderRadius: BorderRadius.circular(rMd),
                          boxShadow: selected ? shadowSm : shadowXs,
                        ),
                        child: Row(
                          children: [
                            Text(s['icon'] as String,
                                style: const TextStyle(fontSize: 26)),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(s['name'] as String,
                                      style: headStyle(
                                          size: 14,
                                          weight: FontWeight.w800)),
                                  const SizedBox(height: 2),
                                  Text(s['desc'] as String,
                                      style: bodyStyle(
                                          size: 11, color: kMuted)),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '€${(s['price'] as double).toStringAsFixed(2)}',
                                  style: headStyle(
                                      size: 15,
                                      weight: FontWeight.w900,
                                      color: kCyan),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: kBg,
                                    borderRadius:
                                        BorderRadius.circular(20),
                                    border: Border.all(color: kBorder),
                                  ),
                                  child: Text(s['duration'] as String,
                                      style: headStyle(
                                          size: 9,
                                          weight: FontWeight.w700,
                                          color: kMuted)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 20),

                  // Recurring toggle
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: kSurface,
                      border: Border.all(color: kBorder),
                      borderRadius: BorderRadius.circular(rMd),
                      boxShadow: shadowXs,
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: kCyan.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(rSm),
                              ),
                              child: const Icon(Icons.repeat,
                                  color: kCyan, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text('Recurring Schedule',
                                      style: headStyle(
                                          size: 13,
                                          weight: FontWeight.w800)),
                                  Text('Auto-book at this time',
                                      style: bodyStyle(
                                          size: 11, color: kMuted)),
                                ],
                              ),
                            ),
                            Switch(
                              value: _recurring,
                              onChanged: (v) =>
                                  setState(() => _recurring = v),
                              activeColor: kCyan,
                            ),
                          ],
                        ),
                        if (_recurring) ...[
                          const SizedBox(height: 12),
                          const Divider(height: 1),
                          const SizedBox(height: 12),
                          Row(
                            children: _freqOptions.map((freq) {
                              final sel = _recurringFreq == freq;
                              return GestureDetector(
                                onTap: () =>
                                    setState(() => _recurringFreq = freq),
                                child: AnimatedContainer(
                                  duration:
                                      const Duration(milliseconds: 180),
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color:
                                        sel ? kCyan : kBg,
                                    borderRadius:
                                        BorderRadius.circular(rSm),
                                    border: Border.all(
                                        color: sel ? kCyan : kBorder),
                                  ),
                                  child: Text(freq,
                                      style: headStyle(
                                          size: 11,
                                          weight: FontWeight.w700,
                                          color: sel
                                              ? Colors.white
                                              : kMuted)),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Booking summary
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          kCyan.withOpacity(0.08),
                          kCyan.withOpacity(0.03)
                        ],
                      ),
                      border: Border.all(color: kCyan.withOpacity(0.25)),
                      borderRadius: BorderRadius.circular(rMd),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Booking Summary',
                            style: headStyle(
                                size: 13, weight: FontWeight.w800)),
                        const SizedBox(height: 12),
                        _SummaryRow(
                          icon: Icons.calendar_today,
                          label: 'Date',
                          value:
                              '${_dayLabel(_selectedDate)}, ${_selectedDate.day} ${_monthLabel(_selectedDate)}',
                        ),
                        const SizedBox(height: 8),
                        _SummaryRow(
                          icon: Icons.access_time,
                          label: 'Time',
                          value: _selectedTime,
                        ),
                        const SizedBox(height: 8),
                        _SummaryRow(
                          icon: Icons.local_car_wash,
                          label: 'Service',
                          value: service['name'] as String,
                        ),
                        if (_recurring) ...[
                          const SizedBox(height: 8),
                          _SummaryRow(
                            icon: Icons.repeat,
                            label: 'Recurring',
                            value: _recurringFreq,
                          ),
                        ],
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
                  '€${(_services[_selectedService]['price'] as double).toStringAsFixed(2)}',
                  style: headStyle(
                      size: 22,
                      weight: FontWeight.w900,
                      color: kCyan),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  showToast(
                    context,
                    '📅 Scheduled for ${_selectedDate.day} ${_monthLabel(_selectedDate)} at $_selectedTime',
                  );
                  context.pop();
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
                    const Icon(Icons.calendar_today, size: 16),
                    const SizedBox(width: 8),
                    Text('Confirm Booking',
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

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: kCyan),
        const SizedBox(width: 8),
        Text('$label: ', style: bodyStyle(size: 12, color: kMuted)),
        Text(value,
            style: headStyle(size: 12, weight: FontWeight.w700)),
      ],
    );
  }
}
