class OrderModel {
  final String id;
  final String customerId;
  final String? driverId;
  final String status;
  final String serviceType;
  final Map<String, dynamic> items;
  final double subtotal;
  final double serviceFee;
  final double addonFee;
  final double deliveryFee;
  final double total;
  final String pickupAddress;
  final double? pickupLat;
  final double? pickupLng;
  final String pickupSlot;
  final String paymentMethod;
  final String paymentStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  // Vehicle fields for car wash
  final String? vehicleId;
  final String? vehicleMake;
  final String? vehicleModel;
  final String? vehicleYear;
  final String? vehicleColor;
  final String? licensePlate;
  final String? keyStatus; // with_customer, with_driver, at_wash, returned

  OrderModel({
    required this.id,
    required this.customerId,
    this.driverId,
    required this.status,
    required this.serviceType,
    required this.items,
    required this.subtotal,
    required this.serviceFee,
    required this.addonFee,
    required this.deliveryFee,
    required this.total,
    required this.pickupAddress,
    this.pickupLat,
    this.pickupLng,
    required this.pickupSlot,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.createdAt,
    required this.updatedAt,
    this.vehicleId,
    this.vehicleMake,
    this.vehicleModel,
    this.vehicleYear,
    this.vehicleColor,
    this.licensePlate,
    this.keyStatus,
  });

  factory OrderModel.fromMap(Map<String, dynamic> m) => OrderModel(
    id: m['id'] ?? '',
    customerId: m['customer_id'] ?? '',
    driverId: m['driver_id'],
    status: m['status'] ?? 'pending',
    serviceType: m['service_type'] ?? 'standard',
    items: Map<String, dynamic>.from(m['items'] ?? {}),
    subtotal: (m['subtotal'] ?? 0).toDouble(),
    serviceFee: (m['service_fee'] ?? 0).toDouble(),
    addonFee: (m['addon_fee'] ?? 0).toDouble(),
    deliveryFee: (m['delivery_fee'] ?? 2.99).toDouble(),
    total: (m['total'] ?? 0).toDouble(),
    pickupAddress: m['pickup_address'] ?? '',
    pickupLat: m['pickup_lat']?.toDouble(),
    pickupLng: m['pickup_lng']?.toDouble(),
    pickupSlot: m['pickup_slot'] ?? 'ASAP',
    paymentMethod: m['payment_method'] ?? 'card',
    paymentStatus: m['payment_status'] ?? 'pending',
    createdAt: DateTime.tryParse(m['created_at'] ?? '') ?? DateTime.now(),
    updatedAt: DateTime.tryParse(m['updated_at'] ?? '') ?? DateTime.now(),
    vehicleId: m['vehicle_id'],
    vehicleMake: m['vehicle_make'],
    vehicleModel: m['vehicle_model'],
    vehicleYear: m['vehicle_year'],
    vehicleColor: m['vehicle_color'],
    licensePlate: m['license_plate'],
    keyStatus: m['key_status'],
  );

  int get progressPercent {
    switch (status) {
      case 'pending':
        return 10;
      case 'confirmed':
        return 30;
      case 'pickup':
        return 50;
      case 'washing':
        return 70;
      case 'delivered':
        return 100;
      default:
        return 10;
    }
  }

  bool get isDelivered => status == 'delivered';
  bool get isPending => status == 'pending';
  String get shortId => id.substring(0, 8);
}
