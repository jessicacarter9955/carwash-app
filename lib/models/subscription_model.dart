class SubscriptionModel {
  final String id;
  final String userId;
  final String status;
  final String priceId;
  final DateTime currentPeriodEnd;
  final bool cancelAtPeriodEnd;
  final DateTime? trialEnd;

  SubscriptionModel({
    required this.id,
    required this.userId,
    required this.status,
    required this.priceId,
    required this.currentPeriodEnd,
    required this.cancelAtPeriodEnd,
    this.trialEnd,
  });

  factory SubscriptionModel.fromMap(Map<String, dynamic> map) {
    return SubscriptionModel(
      id: map['id'],
      userId: map['user_id'],
      status: map['status'],
      priceId: map['price_id'],
      currentPeriodEnd: DateTime.parse(map['current_period_end']),
      cancelAtPeriodEnd: map['cancel_at_period_end'] ?? false,
      trialEnd: map['trial_end'] != null
          ? DateTime.parse(map['trial_end'])
          : null,
    );
  }

  bool get isActive => status == 'active' || status == 'trialing';
}
