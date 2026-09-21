import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Supported runtime environments
enum AppEnvironmentType {
  development,
  staging,
  production;

  static AppEnvironmentType fromString(String value) {
    switch (value.toLowerCase().trim()) {
      case 'staging':
        return AppEnvironmentType.staging;
      case 'production':
      case 'prod':
        return AppEnvironmentType.production;
      case 'development':
      case 'dev':
      default:
        return AppEnvironmentType.development;
    }
  }
}

/// Immutable configuration determined by the active environment.
class AppConfig {
  final AppEnvironmentType environment;
  final String apiBaseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final bool enableDebugLogs;
  final bool useMockMode;

  const AppConfig({
    required this.environment,
    required this.apiBaseUrl,
    this.connectTimeout = const Duration(seconds: 15),
    this.receiveTimeout = const Duration(seconds: 15),
    this.enableDebugLogs = true,
    this.useMockMode = true,
  });

  /// Factory resolving configuration from dart-define or default dev settings.
  factory AppConfig.fromEnvironment() {
    const envStr = String.fromEnvironment(
      'APP_ENVIRONMENT',
      defaultValue: 'development',
    );
    final env = AppEnvironmentType.fromString(envStr);

    const defaultDevUrl = 'http://10.0.2.2:8000/api/v1';
    const apiUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: '',
    );

    const useMock = bool.fromEnvironment(
      'USE_MOCK_MODE',
      defaultValue: true,
    );

    final resolvedApiUrl = apiUrl.isNotEmpty ? apiUrl : switch (env) {
      AppEnvironmentType.development => defaultDevUrl,
      AppEnvironmentType.staging => 'https://staging-api.ira-ai.internal/api/v1',
      AppEnvironmentType.production => 'https://api.ira-ai.internal/api/v1',
    };

    return AppConfig(
      environment: env,
      apiBaseUrl: resolvedApiUrl,
      enableDebugLogs: env != AppEnvironmentType.production,
      useMockMode: env == AppEnvironmentType.production ? false : useMock,
    );
  }

  bool get isProduction => environment == AppEnvironmentType.production;
  bool get isDevelopment => environment == AppEnvironmentType.development;
  bool get isStaging => environment == AppEnvironmentType.staging;
}

/// Provider for app configuration
final appConfigProvider = Provider<AppConfig>((ref) {
  return AppConfig.fromEnvironment();
});
