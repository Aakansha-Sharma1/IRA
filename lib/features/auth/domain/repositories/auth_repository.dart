import '../entities/auth_user.dart';

/// Contract for Authentication operations
abstract class AuthRepository {
  /// Check existing session from secure storage and validate with backend
  Future<AuthUser?> restoreSession();

  /// Authenticate with email & password
  Future<AuthUser> login({
    required String email,
    required String password,
  });

  /// Register a new account
  Future<AuthUser> register({
    required String email,
    required String password,
  });

  /// Terminate active session and purge credentials securely
  Future<void> logout();

  /// Retrieve the current user profile from the backend
  Future<AuthUser> getCurrentUser();
}
