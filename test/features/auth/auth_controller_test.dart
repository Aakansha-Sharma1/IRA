import 'package:flutter_test/flutter_test.dart';
import 'package:ira_app/core/errors/exceptions.dart';
import 'package:ira_app/features/auth/domain/entities/auth_user.dart';
import 'package:ira_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:ira_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:ira_app/features/auth/presentation/controllers/auth_state.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepository;

  final testUser = AuthUser(
    id: 'user_123',
    email: 'test@ira.ai',
    displayName: 'Aakansha',
    isOnboardingCompleted: true,
    createdAt: DateTime(2026, 1, 1),
  );

  setUp(() {
    mockRepository = MockAuthRepository();
  });

  group('AuthController Tests', () {
    test('Initial state checks session and sets authenticated when session exists', () async {
      when(() => mockRepository.restoreSession()).thenAnswer((_) async => testUser);

      final controller = AuthController(mockRepository);

      // Wait for restoreSession to complete
      await Future<void>.delayed(Duration.zero);

      expect(controller.state.status, equals(AuthStatus.authenticated));
      expect(controller.state.user, equals(testUser));
    });

    test('Initial state sets unauthenticated when no session exists', () async {
      when(() => mockRepository.restoreSession()).thenAnswer((_) async => null);

      final controller = AuthController(mockRepository);

      await Future<void>.delayed(Duration.zero);

      expect(controller.state.status, equals(AuthStatus.unauthenticated));
      expect(controller.state.user, isNull);
    });

    test('Login success updates state to authenticated', () async {
      when(() => mockRepository.restoreSession()).thenAnswer((_) async => null);
      when(() => mockRepository.login(
            email: 'test@ira.ai',
            password: 'password123',
          )).thenAnswer((_) async => testUser);

      final controller = AuthController(mockRepository);
      await Future<void>.delayed(Duration.zero);

      final result = await controller.login(
        email: 'test@ira.ai',
        password: 'password123',
      );

      expect(result, isTrue);
      expect(controller.state.status, equals(AuthStatus.authenticated));
      expect(controller.state.user, equals(testUser));
    });

    test('Login failure updates state to error with domain message', () async {
      when(() => mockRepository.restoreSession()).thenAnswer((_) async => null);
      when(() => mockRepository.login(
            email: 'wrong@ira.ai',
            password: 'wrongpassword',
          )).thenThrow(const AuthException(message: 'Invalid credentials.'));

      final controller = AuthController(mockRepository);
      await Future<void>.delayed(Duration.zero);

      final result = await controller.login(
        email: 'wrong@ira.ai',
        password: 'wrongpassword',
      );

      expect(result, isFalse);
      expect(controller.state.status, equals(AuthStatus.error));
      expect(controller.state.failure?.message, equals('Invalid credentials.'));
    });

    test('Logout resets state to unauthenticated', () async {
      when(() => mockRepository.restoreSession()).thenAnswer((_) async => testUser);
      when(() => mockRepository.logout()).thenAnswer((_) async {});

      final controller = AuthController(mockRepository);
      await Future<void>.delayed(Duration.zero);

      await controller.logout();

      expect(controller.state.status, equals(AuthStatus.unauthenticated));
      expect(controller.state.user, isNull);
    });
  });
}
