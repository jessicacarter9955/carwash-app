import 'package:flutter/material.dart';
import '../core/constants.dart';

enum StepState { pending, active, done }

class TimelineStep extends StatelessWidget {
  final String dotContent;
  final String name;
  final String sub;
  final StepState state;
  final bool isLast;

  const TimelineStep({
    super.key,
    required this.dotContent,
    required this.name,
    required this.sub,
    this.state = StepState.pending,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color dotColor = state == StepState.done
        ? kMint
        : state == StepState.active
            ? kCyan3
            : kBorder;

    final Color textColor = state == StepState.pending ? kMuted : kText;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: dotColor.withOpacity(
                    state == StepState.pending ? .15 : .2),
                shape: BoxShape.circle,
                border: Border.all(color: dotColor, width: 2),
              ),
              child: Center(
                child: Text(
                  state == StepState.done ? '✓' : dotContent,
                  style: TextStyle(
                      fontSize: state == StepState.done ? 12 : 11,
                      color: dotColor),
                ),
              ),
            ),
            if (!isLast)
              Container(
                  width: 2,
                  height: 32,
                  color: kBorder),
          ],
        ),
        const SizedBox(width: 12),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: textColor)),
              Text(sub,
                  style: const TextStyle(
                      fontSize: 10,
                      color: kMuted,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }
}
