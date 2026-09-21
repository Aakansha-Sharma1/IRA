import '../../domain/entities/auth_user.dart';

/// Data Transfer Object for authentication and user profile responses
class AuthUserDto {
  final String id;
  final String email;
  final String displayName;
  final bool isOnboardingCompleted;
  final String? token;
  final String? refreshToken;
  final DateTime createdAt;

  const AuthUserDto({
    required this.id,
    required this.email,
    required this.displayName,
    required this.isOnboardingCompleted,
    this.token,
    this.refreshToken,
    required this.createdAt,
  });

  factory AuthUserDto.fromJson(Map<String, dynamic> json) {
    return AuthUserDto(
      id: (json['id'] ?? json['_id'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      displayName: (json['display_name'] ?? json['displayName'] ?? json['name'] ?? '') as String,
      isOnboardingCompleted: (json['is_onboarding_completed'] ?? json['onboardingCompleted'] ?? false) as bool,
      token: json['token'] as String? ?? json['access_token'] as String?,
      refreshToken: json['refresh_token'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'is_onboarding_completed': isOnboardingCompleted,
      if (token != null) 'token': token,
      if (refreshToken != null) 'refresh_token': refreshToken,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Maps DTO to clean domain entity
  AuthUser toDomain() {
    return AuthUser(
      id: id,
      email: email,
      displayName: displayName,
      isOnboardingCompleted: isOnboardingCompleted,
      createdAt: createdAt,
    );
  }
}
