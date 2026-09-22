import 'package:equatable/equatable.dart';

/// Domain Entity representing an authenticated IRA user
class AuthUser extends Equatable {
  final String id;
  final String email;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const AuthUser({
    required this.id,
    required this.email,
    required this.createdAt,
    this.updatedAt,
  });

  AuthUser copyWith({
    String? id,
    String? email,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AuthUser(
      id: id ?? this.id,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        createdAt,
        updatedAt,
      ];
}
