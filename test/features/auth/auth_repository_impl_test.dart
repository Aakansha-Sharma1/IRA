import 'package:flutter_test/flutter_test.dart';
import 'package:ira_app/core/constants/app_constants.dart';
import 'package:ira_app/core/storage/secure_storage_service.dart';
import 'package:ira_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:ira_app/features/auth/data/models/auth_user_dto.dart';
import 'package:ira_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockSecureStorageService extends Mock implements SecureStorageService {}

void main() {
  late MockAuthRemoteDataSource mockRemote;
  late MockSecureStorageService mockSecureStorage;
  late AuthRepositoryImpl repository;

  final testUserDto = UserDto(
    id: 'user_456',
    email: 'test@ira.ai',
    createdAt: DateTime(2026, 1, 1),
  );

  final testAuthResponse = AuthResponseDto(
    accessToken: 'mock_jwt_token',
    tokenType: 'bearer',
    user: testUserDto,
  );

  setUp(() {
    mockRemote = MockAuthRemoteDataSource();
    mockSecureStorage = MockSecureStorageService();
    repository = AuthRepositoryImpl(
      remoteDataSource: mockRemote,
      secureStorage: mockSecureStorage,
    );
  });

  group('AuthRepositoryImpl Tests', () {
    test('restoreSession returns null when token is null in secure storage', () async {
      when(() => mockSecureStorage.read(AppConstants.storageKeyAuthToken))
          .thenAnswer((_) async => null);

      final result = await repository.restoreSession();

      expect(result, isNull);
      verifyNever(() => mockRemote.getCurrentUser());
    });

    test('restoreSession validates token with backend and returns user when valid', () async {
      when(() => mockSecureStorage.read(AppConstants.storageKeyAuthToken))
          .thenAnswer((_) async => 'valid_token');
      when(() => mockRemote.getCurrentUser()).thenAnswer((_) async => testUserDto);

      final result = await repository.restoreSession();

      expect(result, equals(testUserDto.toDomain()));
      verify(() => mockRemote.getCurrentUser()).called(1);
    });

    test('restoreSession clears token on remote failure and returns null', () async {
      when(() => mockSecureStorage.read(AppConstants.storageKeyAuthToken))
          .thenAnswer((_) async => 'expired_token');
      when(() => mockRemote.getCurrentUser()).thenThrow(Exception('Unauthorized'));
      when(() => mockSecureStorage.delete(any())).thenAnswer((_) async {});

      final result = await repository.restoreSession();

      expect(result, isNull);
      verify(() => mockSecureStorage.delete(AppConstants.storageKeyAuthToken)).called(1);
    });

    test('login persists token and user id in secure storage', () async {
      when(() => mockRemote.login(
            email: 'test@ira.ai',
            password: 'password123',
          )).thenAnswer((_) async => testAuthResponse);
      when(() => mockSecureStorage.write(any(), any())).thenAnswer((_) async {});

      final user = await repository.login(
        email: 'test@ira.ai',
        password: 'password123',
      );

      expect(user, equals(testUserDto.toDomain()));
      verify(() => mockSecureStorage.write(
            AppConstants.storageKeyAuthToken,
            'mock_jwt_token',
          )).called(1);
      verify(() => mockSecureStorage.write(
            AppConstants.storageKeyUserId,
            'user_456',
          )).called(1);
    });

    test('register persists token and returns user', () async {
      when(() => mockRemote.register(
            email: 'test@ira.ai',
            password: 'password123',
          )).thenAnswer((_) async => testAuthResponse);
      when(() => mockSecureStorage.write(any(), any())).thenAnswer((_) async {});

      final user = await repository.register(
        email: 'test@ira.ai',
        password: 'password123',
      );

      expect(user, equals(testUserDto.toDomain()));
      verify(() => mockSecureStorage.write(
            AppConstants.storageKeyAuthToken,
            'mock_jwt_token',
          )).called(1);
    });

    test('logout deletes stored tokens', () async {
      when(() => mockRemote.logout()).thenAnswer((_) async {});
      when(() => mockSecureStorage.delete(any())).thenAnswer((_) async {});

      await repository.logout();

      verify(() => mockSecureStorage.delete(AppConstants.storageKeyAuthToken)).called(1);
      verify(() => mockSecureStorage.delete(AppConstants.storageKeyRefreshToken)).called(1);
      verify(() => mockSecureStorage.delete(AppConstants.storageKeyUserId)).called(1);
    });
  });
}
