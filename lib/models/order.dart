class AppOrder {
  final String id;
  final String customerId;
  final String? driverId;
  final String status;
  final String serviceType;
  final double total;
  final String? pickupAddress;
  final double? pickupLat;
  final double? pickupLng;
  final String? paymentStatus;
  final String? pickupSlot;
  final DateTime createdAt;

  const AppOrder({
    required this.id,
    required this.customerId,
    this.driverId,
    required this.status,
    required this.serviceType,
    required this.total,
    this.pickupAddress,
    this.pickupLat,
    this.pickupLng,
    this.paymentStatus,
    this.pickupSlot,
    required this.createdAt,
  });

  factory AppOrder.fromMap(Map<String, dynamic> m) => AppOrder(
        id: m['id'] as String,
        customerId: m['customer_id'] as String,
        driverId: m['driver_id'] as String?,
        status: m['status'] as String? ?? 'pending',
        serviceType: m['service_type'] as String? ?? 'standard',
        total: (m['total'] as num?)?.toDouble() ?? 0,
        pickupAddress: m['pickup_address'] as String?,
        pickupLat: (m['pickup_lat'] as num?)?.toDouble(),
        pickupLng: (m['pickup_lng'] as num?)?.toDouble(),
        paymentStatus: m['payment_status'] as String?,
        pickupSlot: m['pickup_slot'] as String?,
        createdAt: DateTime.parse(m['created_at'] as String),
      );

  String get shortId => id.split('-').first.toUpperCase();

  bool get isDelivered => status == 'delivered';
  bool get isPending => status == 'pending';

  int get progressPercent => const {
        'pending': 10,
        'confirmed': 30,
        'pickup': 50,
        'washing': 70,
        'delivered': 100,
      }[status] ??
      30;
}
