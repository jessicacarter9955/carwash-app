class VehicleModel {
  final String id;
  final String customerId;
  final String make;
  final String model;
  final String year;
  final String color;
  final String licensePlate;
  final String? photoUrl;
  final DateTime createdAt;

  VehicleModel({
    required this.id,
    required this.customerId,
    required this.make,
    required this.model,
    required this.year,
    required this.color,
    required this.licensePlate,
    this.photoUrl,
    required this.createdAt,
  });

  factory VehicleModel.fromMap(Map<String, dynamic> map) {
    return VehicleModel(
      id: map['id'] as String,
      customerId: map['customer_id'] as String,
      make: map['make'] as String,
      model: map['model'] as String,
      year: map['year'] as String,
      color: map['color'] as String,
      licensePlate: map['license_plate'] as String,
      photoUrl: map['photo_url'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_id': customerId,
      'make': make,
      'model': model,
      'year': year,
      'color': color,
      'license_plate': licensePlate,
      'photo_url': photoUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get displayName => '$year $make $model';
  String get shortName => '$make $model';
}
