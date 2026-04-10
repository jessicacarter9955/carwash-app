import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../services/driver_service.dart';
import '../../../widgets/toast_overlay.dart';

class DriversTab extends StatefulWidget {
  const DriversTab({super.key});
  @override
  State<DriversTab> createState() => _DriversTabState();
}

class _DriversTabState extends State<DriversTab> {
  List<Map<String, dynamic>> _drivers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final d = await DriverService.fetchDrivers();
    if (mounted)
      setState(() {
        _drivers = d;
        _loading = false;
      });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading)
      return const Center(child: CircularProgressIndicator(color: kCyan3));
    if (_drivers.isEmpty)
      return const Center(
        child: Text('No drivers', style: TextStyle(color: kMuted)),
      );
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
        dataTextStyle: const TextStyle(fontSize: 12),
        columns: const [
          DataColumn(label: Text('DRIVER')),
          DataColumn(label: Text('STATUS')),
          DataColumn(label: Text('TRIPS')),
          DataColumn(label: Text('EARNINGS')),
          DataColumn(label: Text('RATING')),
          DataColumn(label: Text('ACTION')),
        ],
        rows: _drivers.map((d) {
          final online = d['is_online'] as bool? ?? false;
          final name =
              (d['profiles'] as Map?)?['full_name'] as String? ?? 'Driver';
          return DataRow(
            cells: [
              DataCell(
                Text(
                  name,
                  style: const TextStyle(
                    fontFamily: kFontHead,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              DataCell(
                _Badge(
                  label: online ? 'online' : 'offline',
                  color: online ? kMint2 : kMuted,
                ),
              ),
              DataCell(Text('${d['total_trips'] ?? 0}')),
              DataCell(
                const Text(
                  '\$0',
                  style: TextStyle(
                    fontFamily: kFontHead,
                    fontWeight: FontWeight.w800,
                    color: kCyan3,
                  ),
                ),
              ),
              DataCell(Text('⭐ ${d['rating'] ?? 5.0}')),
              DataCell(
                TextButton(
                  onPressed: () => showToast('📞 Contacting driver'),
                  child: const Text(
                    'Contact',
                    style: TextStyle(color: kCyan3, fontSize: 10),
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

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontFamily: kFontHead,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: .3,
        ),
      ),
    );
  }
}
