/// Base exception for IRA AI application
sealed class AppException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  const AppException({
    required this.message,
    this.statusCode,
    this.details,
  });

  @override
  String toString() => '$runtimeType(message: $message, statusCode: $statusCode)';
}

/// Network-related errors (no internet, DNS lookup failed, etc.)
class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.statusCode,
    super.details,
  });
}

/// Authentication and token expiration failures
class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.statusCode,
    super.details,
  });
}

/// HTTP request timeouts
class TimeoutException extends AppException {
  const TimeoutException({
    required super.message,
    super.statusCode,
    super.details,
  });
}

/// 4xx validation or bad request errors
class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.statusCode,
    super.details,
  });
}

/// 5xx server-side errors
class ServerException extends AppException {
  const ServerException({
    required super.message,
    super.statusCode,
    super.details,
  });
}

/// Local persistence or cache reading/writing failure
class StorageException extends AppException {
  const StorageException({
    required super.message,
    super.statusCode,
    super.details,
  });
}

/// Unexpected or unhandled exceptions
class UnknownException extends AppException {
  const UnknownException({
    required super.message,
    super.statusCode,
    super.details,
  });
}
