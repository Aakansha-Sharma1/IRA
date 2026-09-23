import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/utils/logger.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';
import '../../../chat/presentation/controllers/chat_controller.dart';
import '../../../chat/presentation/controllers/conversation_list_controller.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

/// Provider for AuthRemoteDataSource (always real backend)
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRemoteDataSourceImpl(apiClient: apiClient);
});

/// Provider for AuthRepository contract
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  final secureStorage = ref.watch(secureStorageServiceProvider);

  return AuthRepositoryImpl(
    remoteDataSource: remoteDataSource,
    secureStorage: secureStorage,
  );
});

/// AuthController managing authentication lifecycle for the entire application
class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final void Function()? _onAuthenticated;
  final void Function()? _onLogout;

  AuthController(
    this._repository, {
    void Function()? onAuthenticated,
    void Function()? onLogout,
  })  : _onAuthenticated = onAuthenticated,
        _onLogout = onLogout,
        super(const AuthState.unknown()) {
    restoreSession();
  }

  /// Initial app launch session check
  Future<void> restoreSession() async {
    state = const AuthState.loading();
    try {
      final user = await _repository.restoreSession();
      if (user != null) {
        state = AuthState.authenticated(user);
        _onAuthenticated?.call();
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
      _onAuthenticated?.call();
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
  }) async {
    state = const AuthState.loading();
    try {
      final user = await _repository.register(
        email: email.trim(),
        password: password,
      );
      state = AuthState.authenticated(user);
      _onAuthenticated?.call();
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

  /// User logout flow
  Future<void> logout() async {
    state = const AuthState.loading();
    try {
      await _repository.logout();
    } catch (e) {
      AppLogger.warning('Logout non-fatal error', e);
    } finally {
      _onLogout?.call();
      state = const AuthState.unauthenticated();
    }
  }
}

/// Provider for AuthController
final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthController(
    repository,
    onAuthenticated: () {
      ref.read(profileControllerProvider.notifier).fetchProfile();
    },
    onLogout: () {
      ref.read(profileControllerProvider.notifier).clearProfile();
      ref.read(conversationListControllerProvider.notifier).clear();
      ref.invalidate(chatControllerProvider);
    },
  );
});
