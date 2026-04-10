import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../state/app_state.dart';
import '../../widgets/item_row.dart';
import '../../widgets/toast_overlay.dart';
import '../../widgets/shared.dart';

class ItemsScreen extends StatelessWidget {
  final VoidCallback onBack, onNext;
  const ItemsScreen({super.key, required this.onBack, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Column(
      children: [
        // Header
        AppHeader(title: 'Select Items', onBack: onBack),
        // Scroll body
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
            children: [
              const SecLabel('Clothing'),
              ...state.items.values.map((item) => ItemRow(item: item)),
            ],
          ),
        ),
        // Bottom bar
        BottomBar(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Subtotal',
                    style: TextStyle(
                      color: kMuted,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    state.fmt(state.itemsTotal),
                    style: const TextStyle(
                      fontFamily: kFontHead,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              PrimaryBtn(
                label: 'Choose Service →',
                onTap: () {
                  if (state.itemsTotal == 0) {
                    showToast('⚠️ Add at least one item');
                    return;
                  }
                  onNext();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
