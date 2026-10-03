import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/voice_session_model.dart';

abstract class VoiceSessionRemoteDataSource {
  Future<VoiceSessionModel> createSession();
}

class VoiceSessionRemoteDataSourceImpl implements VoiceSessionRemoteDataSource {
  final ApiClient apiClient;

  VoiceSessionRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<VoiceSessionModel> createSession() async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.voiceSession,
    );
    return VoiceSessionModel.fromJson(response.data!);
  }
}