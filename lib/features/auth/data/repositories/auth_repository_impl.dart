import '../../../../core/constants/app_constants.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/storage/storage_service.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final SecureStorageService _secureStorage;
  final StorageService _storageService;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required SecureStorageService secureStorage,
    required StorageService storageService,
  })  : _remoteDataSource = remoteDataSource,
        _secureStorage = secureStorage,
        _storageService = storageService;

  @override
  Future<AuthUser?> restoreSession() async {
    final token = await _secureStorage.read(AppConstants.storageKeyAuthToken);
    if (token == null || token.isEmpty) {
      return null;
    }

    try {
      final userDto = await _remoteDataSource.getCurrentUser();
      await _storageService.setBool(
        AppConstants.storageKeyOnboardingComplete,
        userDto.isOnboardingCompleted,
      );
      return userDto.toDomain();
    } catch (e, st) {
      AppLogger.warning('Session restore failed or expired. Clearing tokens.', e, st);
      await _secureStorage.delete(AppConstants.storageKeyAuthToken);
      await _secureStorage.delete(AppConstants.storageKeyRefreshToken);
      return null;
    }
  }

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    final userDto = await _remoteDataSource.login(
      email: email,
      password: password,
    );

    if (userDto.token != null) {
      await _secureStorage.write(AppConstants.storageKeyAuthToken, userDto.token!);
    }
    if (userDto.refreshToken != null) {
      await _secureStorage.write(
        AppConstants.storageKeyRefreshToken,
        userDto.refreshToken!,
      );
    }
    await _secureStorage.write(AppConstants.storageKeyUserId, userDto.id);
    await _storageService.setBool(
      AppConstants.storageKeyOnboardingComplete,
      userDto.isOnboardingCompleted,
    );

    return userDto.toDomain();
  }

  @override
  Future<AuthUser> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final userDto = await _remoteDataSource.register(
      email: email,
      password: password,
      displayName: displayName,
    );

    if (userDto.token != null) {
      await _secureStorage.write(AppConstants.storageKeyAuthToken, userDto.token!);
    }
    if (userDto.refreshToken != null) {
      await _secureStorage.write(
        AppConstants.storageKeyRefreshToken,
        userDto.refreshToken!,
      );
    }
    await _secureStorage.write(AppConstants.storageKeyUserId, userDto.id);
    await _storageService.setBool(
      AppConstants.storageKeyOnboardingComplete,
      userDto.isOnboardingCompleted,
    );

    return userDto.toDomain();
  }

  @override
  Future<void> logout() async {
    try {
      await _remoteDataSource.logout();
    } catch (e) {
      AppLogger.warning('Remote logout call error', e);
    } finally {
      await _secureStorage.delete(AppConstants.storageKeyAuthToken);
      await _secureStorage.delete(AppConstants.storageKeyRefreshToken);
      await _secureStorage.delete(AppConstants.storageKeyUserId);
    }
  }

  @override
  Future<AuthUser> getCurrentUser() async {
    final userDto = await _remoteDataSource.getCurrentUser();
    return userDto.toDomain();
  }

  @override
  Future<void> setOnboardingCompleted(bool completed) async {
    await _storageService.setBool(
      AppConstants.storageKeyOnboardingComplete,
      completed,
    );
    try {
      await _remoteDataSource.updateOnboardingStatus(completed);
    } catch (e) {
      AppLogger.warning('Failed to sync onboarding state with server', e);
    }
  }
}
