import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/auth_user_dto.dart';

abstract class AuthRemoteDataSource {
  Future<AuthUserDto> login({
    required String email,
    required String password,
  });

  Future<AuthUserDto> register({
    required String email,
    required String password,
    required String displayName,
  });

  Future<AuthUserDto> getCurrentUser();

  Future<void> logout();

  Future<void> updateOnboardingStatus(bool completed);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSourceImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<AuthUserDto> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.login,
      data: {
        'email': email,
        'password': password,
      },
    );

    return AuthUserDto.fromJson(response.data!);
  }

  @override
  Future<AuthUserDto> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.register,
      data: {
        'email': email,
        'password': password,
        'display_name': displayName,
      },
    );

    return AuthUserDto.fromJson(response.data!);
  }

  @override
  Future<AuthUserDto> getCurrentUser() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.currentUser,
    );

    return AuthUserDto.fromJson(response.data!);
  }

  @override
  Future<void> logout() async {
    await _apiClient.post<dynamic>(ApiEndpoints.logout);
  }

  @override
  Future<void> updateOnboardingStatus(bool completed) async {
    await _apiClient.patch<dynamic>(
      ApiEndpoints.onboarding,
      data: {'completed': completed},
    );
  }
}
