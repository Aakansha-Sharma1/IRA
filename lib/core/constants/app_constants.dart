/// Central application constants
abstract final class AppConstants {
  static const String appName = 'IRA AI';
  static const String appTagline = 'Intelligent Responsive Assistant';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String storageKeyAuthToken = 'ira_auth_token';
  static const String storageKeyRefreshToken = 'ira_refresh_token';
  static const String storageKeyUserId = 'ira_user_id';
  static const String storageKeyOnboardingComplete = 'ira_onboarding_complete';
  static const String storageKeyThemeMode = 'ira_theme_mode';

  // Network Timeouts
  static const Duration defaultConnectTimeout = Duration(seconds: 15);
  static const Duration defaultReceiveTimeout = Duration(seconds: 60);
  static const Duration defaultSendTimeout = Duration(seconds: 15);
}
