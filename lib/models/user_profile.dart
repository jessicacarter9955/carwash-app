class UserProfile {
  final String id;
  final String fullName;
  final String role; // 'customer' | 'driver' | 'admin'
  final String phone;

  const UserProfile({
    required this.id,
    required this.fullName,
    required this.role,
    required this.phone,
  });

  factory UserProfile.fromMap(Map<String, dynamic> m) => UserProfile(
    id: m['id'] as String,
    fullName: m['full_name'] as String? ?? 'Friend',
    role: m['role'] as String? ?? 'customer',
    phone: m['phone'] as String? ?? '',
  );

  String get firstName => fullName.split(' ').first;
  bool get isDriver => role == 'driver';
  bool get isAdmin => role == 'admin';
}
