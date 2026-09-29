import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/mood_entry_model.dart';

abstract class MoodRemoteDataSource {
  Future<List<MoodEntryModel>> listMoodEntries();
  Future<MoodEntryModel> createMood(Map<String, dynamic> data);
  Future<MoodEntryModel> getMood(String id);
  Future<MoodEntryModel> updateMood(String id, Map<String, dynamic> data);
}

class MoodRemoteDataSourceImpl implements MoodRemoteDataSource {
  final ApiClient apiClient;

  MoodRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<MoodEntryModel>> listMoodEntries() async {
    final response = await apiClient.get<dynamic>(ApiEndpoints.moods);
    final data = response.data;
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(MoodEntryModel.fromJson)
          .toList();
    }
    return const [];
  }

  @override
  Future<MoodEntryModel> createMood(Map<String, dynamic> data) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.moods,
      data: data,
    );
    return MoodEntryModel.fromJson(response.data!);
  }

  @override
  Future<MoodEntryModel> getMood(String id) async {
    final response = await apiClient.get<Map<String, dynamic>>(ApiEndpoints.mood(id));
    return MoodEntryModel.fromJson(response.data!);
  }

  @override
  Future<MoodEntryModel> updateMood(String id, Map<String, dynamic> data) async {
    final response = await apiClient.put<Map<String, dynamic>>(
      ApiEndpoints.mood(id),
      data: data,
    );
    return MoodEntryModel.fromJson(response.data!);
  }
}
