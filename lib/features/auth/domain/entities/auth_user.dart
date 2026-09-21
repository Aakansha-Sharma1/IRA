import 'package:equatable/equatable.dart';

/// Domain Entity representing an authenticated IRA user
class AuthUser extends Equatable {
  final String id;
  final String email;
  final String displayName;
  final bool isOnboardingCompleted;
  final DateTime createdAt;

  const AuthUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.isOnboardingCompleted,
    required this.createdAt,
  });

  AuthUser copyWith({
    String? id,
    String? email,
    String? displayName,
    bool? isOnboardingCompleted,
    DateTime? createdAt,
  }) {
    return AuthUser(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      isOnboardingCompleted: isOnboardingCompleted ?? this.isOnboardingCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        displayName,
        isOnboardingCompleted,
        createdAt,
      ];
}
