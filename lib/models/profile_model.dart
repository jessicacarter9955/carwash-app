class ProfileModel {
  final String id;
  final String fullName;
  final String phone;
  final String role;
  final String? avatarUrl;

  ProfileModel({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.role,
    this.avatarUrl,
  });

  factory ProfileModel.fromMap(Map<String, dynamic> m) => ProfileModel(
        id: m['id'] ?? '',
        fullName: m['full_name'] ?? 'User',
        phone: m['phone'] ?? '',
        role: m['role'] ?? 'customer',
        avatarUrl: m['avatar_url'],
      );
}
