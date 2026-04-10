import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../models/order.dart';
import '../state/app_state.dart';

class OrderCard extends StatelessWidget {
  final AppOrder order;
  final AppState state;

  const OrderCard({super.key, required this.order, required this.state});

  @override
  Widget build(BuildContext context) {
    final Color badgeColor = order.isDelivered
        ? kMint
        : order.isPending
            ? kOrange
            : kCyan3;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Order #${order.shortId}',
              style: const TextStyle(
                  fontSize: 11,
                  color: kMuted,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .5)),
          const SizedBox(height: 4),
          Text('${order.serviceType} Wash',
              style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: kText,
                  fontFamily: kFontHead)),
          const SizedBox(height: 4),
          Text(
              'Slot: ${order.pickupSlot ?? '--'} · ${_formatDate(order.createdAt)}',
              style: const TextStyle(
                  fontSize: 11,
                  color: kMuted,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(state.fmt(order.total),
                  style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      color: kCyan3,
                      fontFamily: kFontHead)),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(order.status,
                    style: TextStyle(
                        color: badgeColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 11)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day}/${d.month}/${d.year}';
}
