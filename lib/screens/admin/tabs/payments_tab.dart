import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants.dart';
import '../../../services/admin_service.dart';
import '../../../state/app_state.dart';

class PaymentsTab extends StatefulWidget {
  const PaymentsTab({super.key});
  @override
  State<PaymentsTab> createState() => _PaymentsTabState();
}

class _PaymentsTabState extends State<PaymentsTab> {
  List<Map<String, dynamic>> _orders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final o = await AdminService.fetchAllOrders();
    if (mounted)
      setState(() {
        _orders = o;
        _loading = false;
      });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    if (_loading)
      return const Center(child: CircularProgressIndicator(color: kCyan3));
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingTextStyle: const TextStyle(
          fontFamily: kFontHead,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: kMuted,
          letterSpacing: .8,
        ),
        columns: const [
          DataColumn(label: Text('ORDER ID')),
          DataColumn(label: Text('CUSTOMER')),
          DataColumn(label: Text('METHOD')),
          DataColumn(label: Text('AMOUNT')),
          DataColumn(label: Text('STATUS')),
          DataColumn(label: Text('TIME')),
        ],
        rows: _orders.map((o) {
          final pm = o['payment_method'] as String? ?? 'card';
          final ps = o['payment_status'] as String? ?? 'pending';
          final psc = ps == 'paid' ? kMint2 : kOrange;
          final pmEmoji = pm == 'card'
              ? '💳 Card'
              : pm == 'apple'
              ? '🍎 Apple Pay'
              : '💵 Cash';
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
              DataCell(Text(pmEmoji)),
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
                    color: psc.withOpacity(.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    ps.toUpperCase(),
                    style: TextStyle(
                      fontFamily: kFontHead,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: psc,
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
    );
  }
}
