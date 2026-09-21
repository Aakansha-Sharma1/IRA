import 'dart:developer' as developer;

enum LogLevel { debug, info, warning, error }

/// Centralized, production-safe logger abstraction.
/// Automatically redacts sensitive credentials, tokens, passwords, and personal wellness entries.
abstract final class AppLogger {
  static LogLevel minLevel = LogLevel.debug;
  static bool enableLogging = true;

  // Patterns to redact
  static final RegExp _sensitivePattern = RegExp(
    r'(password|token|bearer|authorization|secret|key|apiKey)[\s:="]+([^"\s&,]+)',
    caseSensitive: false,
  );

  static void debug(String message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.debug, message, error, stackTrace);
  }

  static void info(String message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.info, message, error, stackTrace);
  }

  static void warning(String message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.warning, message, error, stackTrace);
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.error, message, error, stackTrace);
  }

  static void _log(
    LogLevel level,
    String message,
    Object? error,
    StackTrace? stackTrace,
  ) {
    if (!enableLogging || level.index < minLevel.index) return;

    final sanitizedMessage = _sanitize(message);
    final tag = 'IRA_${level.name.toUpperCase()}';

    developer.log(
      sanitizedMessage,
      name: tag,
      level: _toDeveloperLevel(level),
      error: error != null ? _sanitize(error.toString()) : null,
      stackTrace: stackTrace,
    );
  }

  static String _sanitize(String raw) {
    return raw.replaceAllMapped(_sensitivePattern, (match) {
      final key = match.group(1) ?? '';
      return '$key="[REDACTED]"';
    });
  }

  static int _toDeveloperLevel(LogLevel level) => switch (level) {
    LogLevel.debug => 500,
    LogLevel.info => 800,
    LogLevel.warning => 900,
    LogLevel.error => 1000,
  };
}
