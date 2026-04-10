import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
import '../../providers/order_provider.dart';
import '../../widgets/back_button_widget.dart';
import '../../widgets/status_badge.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});
  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(orderProvider.notifier).fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderProvider);

    return Scaffold(
      backgroundColor: kBg,
      body: Column(
        children: [
          Container(
            color: kBg.withOpacity(0.95),
            padding: EdgeInsets.fromLTRB(
                14, MediaQuery.of(context).padding.top + 12, 14, 10),
            child: Row(children: [
              const BackButtonWidget(),
              const SizedBox(width: 10),
              Text('My Orders',
                  style: headStyle(size: 16, weight: FontWeight.w800)),
            ]),
          ),
          Expanded(
            child: orderState.loading
                ? const Center(child: CircularProgressIndicator(color: kCyan))
                : orderState.orders.isEmpty
                    ? Center(
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                          const Text('📦', style: TextStyle(fontSize: 48)),
                          const SizedBox(height: 12),
                          Text('No orders yet',
                              style:
                                  headStyle(size: 16, weight: FontWeight.w800)),
                          Text('Book your first laundry pickup!',
                              style: bodyStyle(size: 13, color: kMuted)),
                        ]),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(14, 10, 14, 24),
                        itemCount: orderState.orders.length,
                        itemBuilder: (_, i) {
                          final o = orderState.orders[i];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                                color: kSurface,
                                border: Border.all(color: kBorder),
                                borderRadius: BorderRadius.circular(rMd),
                                boxShadow: shadowXs),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'ORDER #${o.id.split('-')[0].toUpperCase()}',
                                    style: headStyle(
                                            size: 10,
                                            weight: FontWeight.w700,
                                            color: kMuted)
                                        .copyWith(letterSpacing: 0.5)),
                                const SizedBox(height: 4),
                                Text(
                                    '${o.serviceType[0].toUpperCase()}${o.serviceType.substring(1)} Wash',
                                    style: headStyle(
                                        size: 13, weight: FontWeight.w800)),
                                const SizedBox(height: 2),
                                Text(
                                    'Slot: ${o.pickupSlot} · ${DateFormat('MMM d, y').format(o.createdAt)}',
                                    style: bodyStyle(size: 11, color: kMuted)),
                                const SizedBox(height: 10),
                                const Divider(color: kBorder, height: 1),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('\$${o.total.toStringAsFixed(2)}',
                                        style: headStyle(
                                            size: 15,
                                            weight: FontWeight.w900,
                                            color: kCyan3)),
                                    StatusBadge(status: o.status),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
