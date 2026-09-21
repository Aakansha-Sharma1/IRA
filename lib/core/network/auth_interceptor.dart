import 'package:dio/dio.dart';

import '../constants/app_constants.dart';
import '../storage/secure_storage_service.dart';
import '../utils/logger.dart';

/// Interceptor that attaches the Bearer token to outgoing HTTP requests
/// and handles 401 unauthorized responses.
class AuthInterceptor extends Interceptor {
  final SecureStorageService _secureStorage;
  final void Function()? onUnauthorized;

  AuthInterceptor({
    required SecureStorageService secureStorage,
    this.onUnauthorized,
  }) : _secureStorage = secureStorage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final token = await _secureStorage.read(AppConstants.storageKeyAuthToken);
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (e) {
      AppLogger.warning('Failed to retrieve auth token for request', e);
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      AppLogger.warning('Received 401 Unauthorized from backend. Invoking session callback.');
      onUnauthorized?.call();
    }
    return handler.next(err);
  }
}
