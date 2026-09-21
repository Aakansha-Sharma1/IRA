import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/storage/storage_service.dart';
import '../../../../core/utils/logger.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/datasources/mock_auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

/// Provider for AuthRemoteDataSource
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final config = ref.watch(appConfigProvider);
  if (config.useMockMode) {
    AppLogger.info('AppConfig: Running in Development Mock Mode (No backend required)');
    return MockAuthRemoteDataSource();
  }
  final apiClient = ref.watch(apiClientProvider);
  return AuthRemoteDataSourceImpl(apiClient: apiClient);
});

/// Provider for AuthRepository contract
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  final secureStorage = ref.watch(secureStorageServiceProvider);
  final storageService = ref.watch(storageServiceProvider);

  return AuthRepositoryImpl(
    remoteDataSource: remoteDataSource,
    secureStorage: secureStorage,
    storageService: storageService,
  );
});

/// AuthController managing authentication lifecycle for the entire application
class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthController(this._repository) : super(const AuthState.unknown()) {
    restoreSession();
  }

  /// Initial app launch session check
  Future<void> restoreSession() async {
    state = const AuthState.loading();
    try {
      final user = await _repository.restoreSession();
      if (user != null) {
        state = AuthState.authenticated(user);
      } else {
        state = const AuthState.unauthenticated();
      }
    } catch (e, st) {
      AppLogger.error('Session restoration error', e, st);
      state = const AuthState.unauthenticated();
    }
  }

  /// User login flow
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = const AuthState.loading();
    try {
      final user = await _repository.login(
        email: email.trim(),
        password: password,
      );
      state = AuthState.authenticated(user);
      return true;
    } on AppException catch (e) {
      state = AuthState.error(
        AuthFailure(message: e.message),
      );
      return false;
    } catch (e, st) {
      AppLogger.error('Unexpected login failure', e, st);
      state = const AuthState.error(
        AuthFailure(message: 'Login failed unexpectedly. Please try again.'),
      );
      return false;
    }
  }

  /// User registration flow
  Future<bool> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = const AuthState.loading();
    try {
      final user = await _repository.register(
        email: email.trim(),
        password: password,
        displayName: displayName.trim(),
      );
      state = AuthState.authenticated(user);
      return true;
    } on AppException catch (e) {
      state = AuthState.error(
        AuthFailure(message: e.message),
      );
      return false;
    } catch (e, st) {
      AppLogger.error('Unexpected registration failure', e, st);
      state = const AuthState.error(
        AuthFailure(message: 'Registration failed. Please try again.'),
      );
      return false;
    }
  }

  /// Complete onboarding flow
  Future<void> completeOnboarding() async {
    final currentUser = state.user;
    if (currentUser == null) return;

    await _repository.setOnboardingCompleted(true);

    // Use copyWith to avoid a redundant network call in mock/dev mode
    final updatedUser = currentUser.copyWith(isOnboardingCompleted: true);
    state = AuthState.authenticated(updatedUser);
  }

  /// User logout flow
  Future<void> logout() async {
    state = const AuthState.loading();
    try {
      await _repository.logout();
    } catch (e) {
      AppLogger.warning('Logout non-fatal error', e);
    } finally {
      state = const AuthState.unauthenticated();
    }
  }
}

/// Provider for AuthController
final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthController(repository);
});
