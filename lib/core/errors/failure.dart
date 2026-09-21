import 'package:equatable/equatable.dart';

/// Base class for all user-facing domain failures.
/// Failures translate technical exceptions into safe, user-friendly domain states.
sealed class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'Unable to connect. Please check your internet connection and try again.',
    super.code = 'NETWORK_ERROR',
  });
}

class TimeoutFailure extends Failure {
  const TimeoutFailure({
    super.message = 'The request timed out. Please try again.',
    super.code = 'TIMEOUT_ERROR',
  });
}

class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.code = 'AUTH_ERROR',
  });
}

class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.code = 'VALIDATION_ERROR',
  });
}

class ServerFailure extends Failure {
  const ServerFailure({
    super.message = 'A server error occurred. Our team has been notified.',
    super.code = 'SERVER_ERROR',
  });
}

class StorageFailure extends Failure {
  const StorageFailure({
    super.message = 'Failed to read or write local app data.',
    super.code = 'STORAGE_ERROR',
  });
}

class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'An unexpected error occurred. Please try again later.',
    super.code = 'UNKNOWN_ERROR',
  });
}
