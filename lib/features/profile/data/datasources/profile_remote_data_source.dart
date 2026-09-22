import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/user_profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfileModel> getProfile();
  Future<UserProfileModel> createProfile(Map<String, dynamic> data);
  Future<UserProfileModel> updateProfile(Map<String, dynamic> data);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient apiClient;

  ProfileRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<UserProfileModel> getProfile() async {
    final response = await apiClient.get<Map<String, dynamic>>(ApiEndpoints.profile);
    return UserProfileModel.fromJson(response.data!);
  }

  @override
  Future<UserProfileModel> createProfile(Map<String, dynamic> data) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.profile,
      data: data,
    );
    return UserProfileModel.fromJson(response.data!);
  }

  @override
  Future<UserProfileModel> updateProfile(Map<String, dynamic> data) async {
    final response = await apiClient.put<Map<String, dynamic>>(
      ApiEndpoints.profile,
      data: data,
    );
    return UserProfileModel.fromJson(response.data!);
  }
}
