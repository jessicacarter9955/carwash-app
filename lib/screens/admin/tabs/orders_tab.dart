import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants.dart';
import '../../../services/admin_service.dart';
import '../../../state/app_state.dart';

class OrdersTab extends StatefulWidget {
  const OrdersTab({super.key});
  @override
  State<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<OrdersTab> {
  String _filter = 'all';
  List<Map<String, dynamic>> _orders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final o = await AdminService.fetchAllOrders(filter: _filter);
    if (mounted)
      setState(() {
        _orders = o;
        _loading = false;
      });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    const filters = [
      'all',
      'pending',
      'confirmed',
      'pickup',
      'washing',
      'delivered',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filter row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: filters.map((f) {
              final active = _filter == f;
              return GestureDetector(
                onTap: () => setState(() {
                  _filter = f;
                  _loading = true;
                  _load();
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: active ? kCyan3 : Colors.transparent,
                    border: Border.all(color: active ? kCyan3 : kBorder),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: active
                        ? [
                            BoxShadow(
                              color: kCyan3.withOpacity(.3),
                              blurRadius: 10,
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    f[0].toUpperCase() + f.substring(1),
                    style: TextStyle(
                      fontFamily: kFontHead,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: active ? Colors.white : kMuted,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        if (_loading)
          const Center(child: CircularProgressIndicator(color: kCyan3))
        else if (_orders.isEmpty)
          const Center(
            child: Text('No orders', style: TextStyle(color: kMuted)),
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingTextStyle: const TextStyle(
                fontFamily: kFontHead,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: kMuted,
                letterSpacing: .8,
              ),
              dataTextStyle: const TextStyle(fontSize: 12),
              columns: const [
                DataColumn(label: Text('ORDER ID')),
                DataColumn(label: Text('CUSTOMER')),
                DataColumn(label: Text('DRIVER')),
                DataColumn(label: Text('SERVICE')),
                DataColumn(label: Text('AMOUNT')),
                DataColumn(label: Text('STATUS')),
                DataColumn(label: Text('TIME')),
              ],
              rows: _orders.map((o) {
                final st = o['status'] as String? ?? 'pending';
                final stColor = st == 'delivered'
                    ? kMint2
                    : st == 'pending'
                    ? kOrange
                    : kCyan3;
                final id = (o['id'] as String?)?.split('-').first ?? '--';
                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        '#$id',
                        style: const TextStyle(
                          fontFamily: kFontHead,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const DataCell(Text('Customer')),
                    DataCell(Text(o['driver_id'] != null ? 'Driver' : '--')),
                    DataCell(Text(o['service_type'] as String? ?? 'Standard')),
                    DataCell(
                      Text(
                        state.fmt((o['total'] as num?)?.toDouble() ?? 0),
                        style: const TextStyle(
                          fontFamily: kFontHead,
                          fontWeight: FontWeight.w800,
                          color: kCyan3,
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: stColor.withOpacity(.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          st.toUpperCase(),
                          style: TextStyle(
                            fontFamily: kFontHead,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: stColor,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        DateTime.tryParse(
                              o['created_at'] as String? ?? '',
                            )?.toLocal().toString().substring(11, 16) ??
                            '--',
                        style: const TextStyle(
                          color: kMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
