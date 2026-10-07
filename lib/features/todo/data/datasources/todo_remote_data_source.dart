import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/todo_item_model.dart';
class TodoRemoteDataSource {
  final ApiClient apiClient;
  TodoRemoteDataSource({required this.apiClient});
  Future<List<TodoItemModel>> list() async {
    final response = await apiClient.get<dynamic>(ApiEndpoints.todos);
    return (response.data as List).whereType<Map<String, dynamic>>().map(TodoItemModel.fromJson).toList();
  }
  Future<TodoItemModel> create(Map<String, dynamic> data) async {
    final response = await apiClient.post<Map<String, dynamic>>(ApiEndpoints.todos, data: data);
    return TodoItemModel.fromJson(response.data!);
  }
  Future<TodoItemModel> update(String id, Map<String, dynamic> data) async {
    final response = await apiClient.put<Map<String, dynamic>>('${ApiEndpoints.todos}/$id', data: data);
    return TodoItemModel.fromJson(response.data!);
  }
  Future<void> delete(String id) => apiClient.delete<void>('${ApiEndpoints.todos}/$id');
}
