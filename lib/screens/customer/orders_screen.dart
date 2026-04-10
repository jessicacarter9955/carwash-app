// lib/screens/customer/orders_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';
import '../../state/app_state.dart';
import '../../widgets/order_card.dart';
import '../../widgets/shared.dart';

class OrdersScreen extends StatefulWidget {
  final VoidCallback onBack;
  const OrdersScreen({super.key, required this.onBack});
  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<AppOrder> _orders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = context.read<AppState>().currentUserId;
    if (uid == null) {
      setState(() => _loading = false);
      return;
    }
    final orders = await OrderService.fetchOrders(uid);
    if (mounted)
      setState(() {
        _orders = orders;
        _loading = false;
      });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Column(
      children: [
        AppHeader(title: 'My Orders', onBack: widget.onBack),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: kCyan3))
              : _orders.isEmpty
              ? const Center(
                  child: Text(
                    'No orders yet',
                    style: TextStyle(color: kMuted, fontSize: 13),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 20),
                  itemCount: _orders.length,
                  itemBuilder: (_, i) =>
                      OrderCard(order: _orders[i], state: state),
                ),
        ),
      ],
    );
  }
}
