import 'package:flutter/material.dart' hide StepState;
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../services/order_service.dart';
import '../../state/app_state.dart';
import '../../widgets/timeline_step.dart';
import '../../widgets/shared.dart';

class StatusScreen extends StatefulWidget {
  final VoidCallback onBack;
  const StatusScreen({super.key, required this.onBack});
  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  String _orderId = 'No active order';
  String _status = '';
  int _progress = 30;
  String _placed = 'Just now';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final state = context.read<AppState>();
    if (state.currentUserId == null) return;
    final ord = await OrderService.fetchLatestOrder(state.currentUserId!);
    if (ord != null && mounted) {
      setState(() {
        _orderId = '#${ord.shortId}';
        _status = ord.status;
        _progress = ord.progressPercent;
        _placed = ord.createdAt.toLocal().toString().substring(11, 16);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppHeader(title: 'Track Order', onBack: widget.onBack),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 20),
            children: [
              // Mini map placeholder
              Container(
                height: 160,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F0F8),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: kBorder),
                ),
                child: const Center(
                  child: Text('🗺', style: TextStyle(fontSize: 40)),
                ),
              ),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _orderId,
                          style: const TextStyle(
                            fontFamily: kFontHead,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: kMuted,
                          ),
                        ),
                        if (_status.isNotEmpty) _StatusBadge(status: _status),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Progress bar
                    Container(
                      height: 5,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: kBorder,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: _progress / 100,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [kCyan3, kMint],
                            ),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Est. delivery: ~2 hours',
                      style: TextStyle(
                        fontSize: 11,
                        color: kMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SecLabel('Live Updates'),
              TimelineStep(
                dotContent: '✓',
                name: 'Order Placed',
                sub: _placed,
                state: StepState.done,
              ),
              TimelineStep(
                dotContent: '🚗',
                name: 'Driver Assigned',
                sub: 'Luca R.',
                state: StepState.active,
              ),
              TimelineStep(
                dotContent: '🧺',
                name: 'Items Picked Up',
                sub: 'En route to laundry facility',
                state: StepState.pending,
              ),
              TimelineStep(
                dotContent: '🫧',
                name: 'Washing & Drying',
                sub: '~4 hours',
                state: StepState.pending,
              ),
              TimelineStep(
                dotContent: '📦',
                name: 'Ready for Delivery',
                sub: 'Folded and packaged',
                state: StepState.pending,
              ),
              TimelineStep(
                dotContent: '🏠',
                name: 'Delivered',
                sub: 'To your door',
                state: StepState.pending,
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final Color c = status == 'delivered'
        ? kCyan3
        : status == 'pending'
        ? kOrange
        : kMint2;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withOpacity(.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontFamily: kFontHead,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: c,
          letterSpacing: .5,
        ),
      ),
    );
  }
}
