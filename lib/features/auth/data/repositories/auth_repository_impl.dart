import '../../../../core/constants/app_constants.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final SecureStorageService _secureStorage;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required SecureStorageService secureStorage,
  })  : _remoteDataSource = remoteDataSource,
        _secureStorage = secureStorage;

  @override
  Future<AuthUser?> restoreSession() async {
    final token = await _secureStorage.read(AppConstants.storageKeyAuthToken);
    if (token == null || token.isEmpty) {
      return null;
    }

    try {
      final userDto = await _remoteDataSource.getCurrentUser();
      return userDto.toDomain();
    } catch (e, st) {
      AppLogger.warning('Session restore failed or expired. Clearing token.', e, st);
      await _secureStorage.delete(AppConstants.storageKeyAuthToken);
      await _secureStorage.delete(AppConstants.storageKeyRefreshToken);
      await _secureStorage.delete(AppConstants.storageKeyUserId);
      return null;
    }
  }

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    final response = await _remoteDataSource.login(
      email: email,
      password: password,
    );

    if (response.accessToken.isNotEmpty) {
      await _secureStorage.write(
        AppConstants.storageKeyAuthToken,
        response.accessToken,
      );
    }
    await _secureStorage.write(
      AppConstants.storageKeyUserId,
      response.user.id,
    );

    return response.user.toDomain();
  }

  @override
  Future<AuthUser> register({
    required String email,
    required String password,
  }) async {
    final response = await _remoteDataSource.register(
      email: email,
      password: password,
    );

    if (response.accessToken.isNotEmpty) {
      await _secureStorage.write(
        AppConstants.storageKeyAuthToken,
        response.accessToken,
      );
    }
    await _secureStorage.write(
      AppConstants.storageKeyUserId,
      response.user.id,
    );

    return response.user.toDomain();
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
}
