import '../../domain/entities/auth_user.dart';

/// Data Transfer Object representing the user entity returned from the API
class UserDto {
  final String id;
  final String email;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const UserDto({
    required this.id,
    required this.email,
    required this.createdAt,
    this.updatedAt,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: (json['id'] ?? json['_id'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'created_at': createdAt.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  AuthUser toDomain() {
    return AuthUser(
      id: id,
      email: email,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

/// Data Transfer Object for authentication endpoints returning tokens and user data
class AuthResponseDto {
  final String accessToken;
  final String tokenType;
  final UserDto user;

  const AuthResponseDto({
    required this.accessToken,
    this.tokenType = 'bearer',
    required this.user,
  });

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) {
    final token = (json['access_token'] ?? json['token'] ?? '') as String;
    final tokenType = (json['token_type'] ?? 'bearer') as String;

    final userJson = json['user'] is Map<String, dynamic>
        ? json['user'] as Map<String, dynamic>
        : json;

    return AuthResponseDto(
      accessToken: token,
      tokenType: tokenType,
      user: UserDto.fromJson(userJson),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'token_type': tokenType,
      'user': user.toJson(),
    };
  }
}
