import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants.dart';
import '../../../services/admin_service.dart';
import '../../../state/app_state.dart';
import '../../../widgets/toast_overlay.dart';

class PricingTab extends StatefulWidget {
  const PricingTab({super.key});
  @override
  State<PricingTab> createState() => _PricingTabState();
}

class _PricingTabState extends State<PricingTab> {
  List<Map<String, dynamic>> _pricing = [];
  bool _loading = true;
  final Map<String, TextEditingController> _ctrls = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await AdminService.fetchPricing();
    if (mounted) {
      setState(() {
        _pricing = p;
        _loading = false;
      });
      for (final row in p) {
        final key = row['item_key'] as String? ?? '';
        _ctrls[key] = TextEditingController(
          text: ((row['price'] as num?)?.toDouble() ?? 0).toStringAsFixed(2),
        );
      }
    }
  }

  Future<void> _saveAll() async {
    showToast('💾 Saving prices...');
    final state = context.read<AppState>();
    for (final entry in _ctrls.entries) {
      final price = double.tryParse(entry.value.text);
      if (price != null && price > 0) {
        await AdminService.savePrice(entry.key, price);
        state.updateItemPrice(entry.key, price);
      }
    }
    showToast('✅ Prices saved!');
  }

  @override
  void dispose() {
    for (final c in _ctrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kBg,
        border: Border.all(color: kBorder),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '🏷 Item Pricing',
                style: TextStyle(
                  fontFamily: kFontHead,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '(editable — saved to Supabase)',
                style: TextStyle(
                  fontSize: 11,
                  color: kMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_loading)
            const Center(child: CircularProgressIndicator(color: kCyan3))
          else if (_pricing.isEmpty)
            const Text('No pricing data', style: TextStyle(color: kMuted))
          else
            ..._pricing.map((p) {
              final key = p['item_key'] as String? ?? '';
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: kBorder)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p['item_name'] as String? ?? key,
                          style: const TextStyle(
                            fontFamily: kFontHead,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Text(
                          'per item',
                          style: TextStyle(fontSize: 10, color: kMuted),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Text(
                          '\$',
                          style: TextStyle(
                            color: kMuted,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(
                          width: 70,
                          child: TextField(
                            controller: _ctrls[key],
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontFamily: kFontHead,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: kBorder),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: kCyan3),
                              ),
                              filled: true,
                              fillColor: kSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: _saveAll,
            style: ElevatedButton.styleFrom(
              backgroundColor: kCyan3,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              '💾 Save All Prices',
              style: TextStyle(
                fontFamily: kFontHead,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
