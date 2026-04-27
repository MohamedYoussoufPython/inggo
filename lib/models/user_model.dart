class UserModel {
  final String name;
  final String phone;
  final String email;
  final String gender;
  final String country;
  final String avatarUrl;

  const UserModel({
    required this.name,
    required this.phone,
    required this.email,
    required this.gender,
    required this.country,
    required this.avatarUrl,
  });

  UserModel copyWith({
    String? name,
    String? phone,
    String? email,
    String? gender,
    String? country,
    String? avatarUrl,
  }) {
    return UserModel(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      country: country ?? this.country,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
