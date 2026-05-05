import 'package:json_annotation/json_annotation.dart';

enum UserRole { client, driver, admin }

class UserModel {
  final String id;
  final String fullName;
  final String phone;
  final String? email;
  final UserRole role;
  final String? avatarUrl;
  final String language;
  final bool isOnline;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.phone,
    this.email,
    this.role = UserRole.client,
    this.avatarUrl,
    this.language = 'fr',
    this.isOnline = false,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String?,
      role: _parseRole(json['role'] as String?),
      avatarUrl: json['avatar_url'] as String?,
      language: json['language'] as String? ?? 'fr',
      isOnline: json['is_online'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  static UserRole _parseRole(String? role) {
    switch (role) {
      case 'driver':
        return UserRole.driver;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.client;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'phone': phone,
      'email': email,
      'role': role.name,
      'avatar_url': avatarUrl,
      'language': language,
      'is_online': isOnline,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? fullName,
    String? phone,
    String? email,
    UserRole? role,
    String? avatarUrl,
    String? language,
    bool? isOnline,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      language: language ?? this.language,
      isOnline: isOnline ?? this.isOnline,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
