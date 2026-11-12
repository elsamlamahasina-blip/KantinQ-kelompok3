enum UserRole {
  buyer,
  seller,
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String avatarUrl;
  final String campusLocation;
  final String memberTier;
  final UserRole role;
  final String? sellerCanteenId;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.avatarUrl,
    this.campusLocation = 'Kantin Utama — Gedung A Lt. 1',
    this.memberTier = 'KantinQ Gold Member',
    this.role = UserRole.buyer,
    this.sellerCanteenId,
  });

  bool get isSeller => role == UserRole.seller;

  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    String? campusLocation,
    String? memberTier,
    UserRole? role,
    String? sellerCanteenId,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      campusLocation: campusLocation ?? this.campusLocation,
      memberTier: memberTier ?? this.memberTier,
      role: role ?? this.role,
      sellerCanteenId: sellerCanteenId ?? this.sellerCanteenId,
    );
  }
}

