import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../services/admin_service.dart';
import '../../state/app_state.dart';
import '../../widgets/metric_card.dart';
import '../../widgets/toast_overlay.dart';
import 'tabs/overview_tab.dart';
import 'tabs/drivers_tab.dart';
import 'tabs/orders_tab.dart';
import 'tabs/payments_tab.dart';
import 'tabs/pricing_tab.dart';

enum AdminTab { overview, drivers, orders, payments, pricing }

class AdminView extends StatefulWidget {
  const AdminView({super.key});
  @override
  State<AdminView> createState() => _AdminViewState();
}

class _AdminViewState extends State<AdminView> {
  AdminTab _tab = AdminTab.overview;
  AdminMetrics _metrics = const AdminMetrics(
    revenue: 0,
    activeOrders: 0,
    onlineDrivers: 0,
  );
  bool _loading = true;
  String _date = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final metrics = await AdminService.fetchMetrics();
    final now = DateTime.now();
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    if (mounted)
      setState(() {
        _metrics = metrics;
        _date = '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
        _loading = false;
      });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: kSurface,
          border: Border.all(color: kBorder),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(.08), blurRadius: 20),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'WashGo ',
                            style: TextStyle(
                              fontFamily: kFontHead,
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: kText,
                            ),
                          ),
                          TextSpan(
                            text: 'Operations',
                            style: TextStyle(
                              fontFamily: kFontHead,
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: kCyan3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: kMint,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Live · $_date',
                          style: const TextStyle(
                            color: kMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    _loadData();
                    showToast('✅ Data refreshed');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kCyan3,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '⟳ Refresh',
                    style: TextStyle(
                      fontFamily: kFontHead,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Metrics grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.6,
              children: [
                MetricCard(
                  emoji: '💵',
                  value: state.fmt(_metrics.revenue),
                  label: 'Revenue today',
                  trend: '↑ Real data',
                  accentColor: kCyan3,
                ),
                MetricCard(
                  emoji: '📦',
                  value: '${_metrics.activeOrders}',
                  label: 'Active orders',
                  trend: 'Live count',
                  accentColor: kMint2,
                ),
                MetricCard(
                  emoji: '🚗',
                  value: '${_metrics.onlineDrivers}',
                  label: 'Drivers online',
                  trend: '${_metrics.onlineDrivers} available',
                  accentColor: kOrange,
                ),
                MetricCard(
                  emoji: '⚠️',
                  value: '0',
                  label: 'Issues flagged',
                  trend: 'All clear',
                  accentColor: kRed,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Tab switcher
            Container(
              decoration: BoxDecoration(
                color: kBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: kBorder),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: AdminTab.values.map((t) {
                  final label = t.name[0].toUpperCase() + t.name.substring(1);
                  final active = _tab == t;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _tab = t),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: active ? kSurface : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: active
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(.06),
                                    blurRadius: 3,
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: kFontHead,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: active ? kText : kMuted,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Tab content
            switch (_tab) {
              AdminTab.overview => const OverviewTab(),
              AdminTab.drivers => const DriversTab(),
              AdminTab.orders => const OrdersTab(),
              AdminTab.payments => const PaymentsTab(),
              AdminTab.pricing => const PricingTab(),
            },
          ],
        ),
      ),
    );
  }
}
