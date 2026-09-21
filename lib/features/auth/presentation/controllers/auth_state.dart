import 'package:equatable/equatable.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/auth_user.dart';

enum AuthStatus {
  unknown,
  authenticated,
  unauthenticated,
  loading,
  error,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final AuthUser? user;
  final Failure? failure;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.failure,
  });

  const AuthState.unknown() : this(status: AuthStatus.unknown);

  const AuthState.loading() : this(status: AuthStatus.loading);

  const AuthState.authenticated(AuthUser user)
      : this(status: AuthStatus.authenticated, user: user);

  const AuthState.unauthenticated()
      : this(status: AuthStatus.unauthenticated);

  const AuthState.error(Failure failure)
      : this(status: AuthStatus.error, failure: failure);

  bool get isAuthenticated => status == AuthStatus.authenticated && user != null;
  bool get isUnknown => status == AuthStatus.unknown;
  bool get isLoading => status == AuthStatus.loading;
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;
  bool get hasCompletedOnboarding => user?.isOnboardingCompleted ?? false;

  AuthState copyWith({
    AuthStatus? status,
    AuthUser? user,
    Failure? failure,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      failure: failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [status, user, failure];
}
