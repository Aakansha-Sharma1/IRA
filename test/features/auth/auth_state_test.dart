import 'package:flutter_test/flutter_test.dart';
import 'package:ira_app/core/errors/failure.dart';
import 'package:ira_app/features/auth/domain/entities/auth_user.dart';
import 'package:ira_app/features/auth/presentation/controllers/auth_state.dart';

void main() {
  group('AuthState Unit Tests', () {
    final user = AuthUser(
      id: '123',
      email: 'test@ira.ai',
      createdAt: DateTime(2026, 1, 1),
    );

    test('Initial / Unknown state getters', () {
      const state = AuthState.unknown();
      expect(state.isUnknown, isTrue);
      expect(state.isAuthenticated, isFalse);
      expect(state.isLoading, isFalse);
      expect(state.isUnauthenticated, isFalse);
      expect(state.user, isNull);
      expect(state.failure, isNull);
    });

    test('Loading state getters', () {
      const state = AuthState.loading();
      expect(state.isLoading, isTrue);
      expect(state.isAuthenticated, isFalse);
    });

    test('Authenticated state getters', () {
      final state = AuthState.authenticated(user);
      expect(state.isAuthenticated, isTrue);
      expect(state.user, equals(user));
    });

    test('Unauthenticated state getters', () {
      const state = AuthState.unauthenticated();
      expect(state.isUnauthenticated, isTrue);
      expect(state.isAuthenticated, isFalse);
    });

    test('Error state getters', () {
      const failure = AuthFailure(message: 'Invalid credentials');
      const state = AuthState.error(failure);
      expect(state.status, equals(AuthStatus.error));
      expect(state.failure, equals(failure));
    });

    test('CopyWith retains unchanged properties', () {
      final state = AuthState.authenticated(user);
      final updated = state.copyWith(status: AuthStatus.loading);
      expect(updated.status, equals(AuthStatus.loading));
      expect(updated.user, equals(user));
    });
  });
}
