import 'product_model.dart';

class PriceModel {
  final String id;
  final String productId;
  final String currency;
  final int unitAmount;
  final String type;
  final String? interval;
  final int? intervalCount;
  final int? trialPeriodDays;
  final bool active;
  final ProductModel? product;

  PriceModel({
    required this.id,
    required this.productId,
    required this.currency,
    required this.unitAmount,
    required this.type,
    this.interval,
    this.intervalCount,
    this.trialPeriodDays,
    required this.active,
    this.product,
  });

  factory PriceModel.fromMap(Map<String, dynamic> map) {
    return PriceModel(
      id: map['id'],
      productId: map['product_id'],
      currency: map['currency'],
      unitAmount: map['unit_amount'],
      type: map['type'],
      interval: map['interval'],
      intervalCount: map['interval_count'],
      trialPeriodDays: map['trial_period_days'],
      active: map['active'] ?? true,
      product: map['products'] != null
          ? ProductModel.fromMap(map['products'])
          : null,
    );
  }

  // Prezzo formattato (es. €9.99/mese)
  String get formattedPrice {
    final amount = (unitAmount / 100).toStringAsFixed(2);
    final symbol = currency == 'eur' ? '€' : '\$';
    if (interval != null) {
      return '$symbol$amount/$interval';
    }
    return '$symbol$amount';
  }
}
