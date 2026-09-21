import '../models/auth_user_dto.dart';
import 'auth_remote_data_source.dart';

/// In-memory mock implementation of [AuthRemoteDataSource] for frontend testing
/// without requiring a live backend server.
class MockAuthRemoteDataSource implements AuthRemoteDataSource {
  AuthUserDto? _currentUser;

  @override
  Future<AuthUserDto> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));

    final name = email.contains('@') ? email.split('@').first : 'Explorer';
    final user = AuthUserDto(
      id: 'mock_user_${email.hashCode.abs()}',
      email: email,
      displayName: name[0].toUpperCase() + name.substring(1),
      isOnboardingCompleted: false,
      token: 'mock_bearer_token_${DateTime.now().millisecondsSinceEpoch}',
      refreshToken: 'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
    );

    _currentUser = user;
    return user;
  }

  @override
  Future<AuthUserDto> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));

    final user = AuthUserDto(
      id: 'mock_user_${email.hashCode.abs()}',
      email: email,
      displayName: displayName.isNotEmpty ? displayName : 'Explorer',
      isOnboardingCompleted: false,
      token: 'mock_bearer_token_${DateTime.now().millisecondsSinceEpoch}',
      refreshToken: 'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
    );

    _currentUser = user;
    return user;
  }

  @override
  Future<AuthUserDto> getCurrentUser() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));

    if (_currentUser != null) {
      return _currentUser!;
    }

    return AuthUserDto(
      id: 'mock_user_default',
      email: 'wellness.user@ira-ai.internal',
      displayName: 'Wellness Explorer',
      isOnboardingCompleted: false,
      token: 'mock_bearer_token_default',
      refreshToken: 'mock_refresh_token_default',
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<void> logout() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    _currentUser = null;
  }

  @override
  Future<void> updateOnboardingStatus(bool completed) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    if (_currentUser != null) {
      _currentUser = AuthUserDto(
        id: _currentUser!.id,
        email: _currentUser!.email,
        displayName: _currentUser!.displayName,
        isOnboardingCompleted: completed,
        token: _currentUser!.token,
        refreshToken: _currentUser!.refreshToken,
        createdAt: _currentUser!.createdAt,
      );
    }
  }
}
