import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../errors/exceptions.dart';
import '../storage/secure_storage_service.dart';
import '../utils/logger.dart';
import 'auth_interceptor.dart';

/// Centralized HTTP client abstraction utilizing Dio.
class ApiClient {
  final Dio _dio;

  ApiClient({
    required AppConfig config,
    required SecureStorageService secureStorage,
    void Function()? onUnauthorized,
  }) : _dio = Dio(
          BaseOptions(
            baseUrl: config.apiBaseUrl,
            connectTimeout: config.connectTimeout,
            receiveTimeout: config.receiveTimeout,
            sendTimeout: config.connectTimeout,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        ) {
    _dio.interceptors.add(
      AuthInterceptor(
        secureStorage: secureStorage,
        onUnauthorized: onUnauthorized,
      ),
    );

    if (config.enableDebugLogs) {
      _dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            AppLogger.debug('HTTP [${options.method}] => ${options.uri}');
            return handler.next(options);
          },
          onResponse: (response, handler) {
            AppLogger.debug(
              'HTTP [${response.statusCode}] <= ${response.requestOptions.uri}',
            );
            return handler.next(response);
          },
          onError: (DioException error, handler) {
            AppLogger.error(
              'HTTP Error [${error.response?.statusCode}] on ${error.requestOptions.uri}: ${error.message}',
            );
            return handler.next(error);
          },
        ),
      );
    }
  }

  // Visible for testing / mocking
  Dio get dio => _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _execute(() => _dio.get<T>(
          path,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
        ));
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _execute(() => _dio.post<T>(
          path,
          data: data,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
        ));
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _execute(() => _dio.put<T>(
          path,
          data: data,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
        ));
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _execute(() => _dio.patch<T>(
          path,
          data: data,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
        ));
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _execute(() => _dio.delete<T>(
          path,
          data: data,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
        ));
  }

  Future<Response<T>> _execute<T>(Future<Response<T>> Function() call) async {
    try {
      return await call();
    } on DioException catch (dioError) {
      throw _handleDioError(dioError);
    } on SocketException catch (e) {
      throw NetworkException(
        message: 'Unable to connect to IRA server. Check network connection.',
        details: e,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException(
        message: 'An unexpected networking failure occurred.',
        details: e,
      );
    }
  }

  AppException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException(
          message: 'Connection timed out while contacting server.',
          statusCode: error.response?.statusCode,
          details: error.error,
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode ?? 500;
        final message = _extractErrorMessage(error.response?.data) ??
            'Server responded with error status $statusCode.';

        if (statusCode == 401 || statusCode == 403) {
          return AuthException(
            message: message,
            statusCode: statusCode,
            details: error.response?.data,
          );
        }

        if (statusCode >= 400 && statusCode < 500) {
          return ValidationException(
            message: message,
            statusCode: statusCode,
            details: error.response?.data,
          );
        }

        return ServerException(
          message: message,
          statusCode: statusCode,
          details: error.response?.data,
        );

      case DioExceptionType.connectionError:
        return const NetworkException(
          message: 'No internet connection or server unreachable.',
        );

      case DioExceptionType.cancel:
        return const UnknownException(message: 'Request was cancelled.');

      case DioExceptionType.badCertificate:
        return const NetworkException(message: 'Security certificate validation failed.');

      case DioExceptionType.unknown:
      default:
        if (error.error is SocketException) {
          return const NetworkException(
            message: 'No internet connection detected.',
          );
        }
        return UnknownException(
          message: error.message ?? 'An unknown network error occurred.',
          details: error.error,
        );
    }
  }

  String? _extractErrorMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data['detail'] is String) return data['detail'] as String;
      if (data['message'] is String) return data['message'] as String;
      if (data['error'] is String) return data['error'] as String;
    }
    return null;
  }
}

/// Provider for centralized ApiClient
final apiClientProvider = Provider<ApiClient>((ref) {
  final config = ref.watch(appConfigProvider);
  final secureStorage = ref.watch(secureStorageServiceProvider);
  return ApiClient(
    config: config,
    secureStorage: secureStorage,
  );
});
