class DriverModel {
  final String id;
  final bool isOnline;
  final String vehicleMake;
  final String vehiclePlate;
  final double rating;
  final int totalTrips;
  final double? currentLat;
  final double? currentLng;
  final String? fullName; // joined from profiles

  const DriverModel({
    required this.id,
    required this.isOnline,
    required this.vehicleMake,
    required this.vehiclePlate,
    required this.rating,
    required this.totalTrips,
    this.currentLat,
    this.currentLng,
    this.fullName,
  });

  factory DriverModel.fromMap(Map<String, dynamic> m) => DriverModel(
    id: m['id'] as String,
    isOnline: m['is_online'] as bool? ?? false,
    vehicleMake: m['vehicle_make'] as String? ?? 'Unknown',
    vehiclePlate: m['vehicle_plate'] as String? ?? '--',
    rating: (m['rating'] as num?)?.toDouble() ?? 5.0,
    totalTrips: m['total_trips'] as int? ?? 0,
    currentLat: (m['current_lat'] as num?)?.toDouble(),
    currentLng: (m['current_lng'] as num?)?.toDouble(),
    fullName: m['profiles']?['full_name'] as String?,
  );
}
