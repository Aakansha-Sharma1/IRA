import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/journal_entry_model.dart';

class JournalRemoteDataSource {
  final ApiClient apiClient;
  JournalRemoteDataSource({required this.apiClient});

  Future<List<JournalEntryModel>> list() async {
    final response = await apiClient.get<dynamic>(ApiEndpoints.journal);
    return (response.data as List)
        .whereType<Map<String, dynamic>>()
        .map(JournalEntryModel.fromJson)
        .toList();
  }

  Future<JournalEntryModel> create(Map<String, dynamic> data) async {
    final response = await apiClient.post<Map<String, dynamic>>(ApiEndpoints.journal, data: data);
    return JournalEntryModel.fromJson(response.data!);
  }

  Future<JournalEntryModel> update(String id, Map<String, dynamic> data) async {
    final response = await apiClient.put<Map<String, dynamic>>('${ApiEndpoints.journal}/$id', data: data);
    return JournalEntryModel.fromJson(response.data!);
  }

  Future<void> delete(String id) => apiClient.delete<void>('${ApiEndpoints.journal}/$id');
}
