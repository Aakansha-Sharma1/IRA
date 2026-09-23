import 'package:flutter_test/flutter_test.dart';
import 'package:ira_app/app/router.dart';
import 'package:ira_app/features/auth/domain/entities/auth_user.dart';
import 'package:ira_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:ira_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:ira_app/features/auth/presentation/controllers/auth_state.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  test('chat route helper uses backend conversation id', () {
    expect(AppRoutes.conversations, '/conversations');
    expect(AppRoutes.chat, '/chat/:conversationId');
    expect(AppRoutes.chatPath('abc-123'), '/chat/abc-123');
    expect(AppRoutes.home, '/home');
  });

  test('logout callback clears protected state hooks', () async {
    final repository = MockAuthRepository();
    when(() => repository.restoreSession()).thenAnswer((_) async => AuthUser(
          id: 'user-1',
          email: 'user@ira.ai',
          createdAt: DateTime.utc(2026, 1, 1),
        ));
    when(() => repository.logout()).thenAnswer((_) async {});

    var logoutCalled = false;
    final controller = AuthController(
      repository,
      onLogout: () => logoutCalled = true,
    );
    await Future<void>.delayed(Duration.zero);
    expect(controller.state.status, AuthStatus.authenticated);

    await controller.logout();

    expect(logoutCalled, isTrue);
    expect(controller.state.status, AuthStatus.unauthenticated);
    expect(controller.state.user, isNull);
  });
}
