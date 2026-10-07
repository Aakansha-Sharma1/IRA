import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/todo_remote_data_source.dart';
import '../../domain/entities/todo_item.dart';
final todoDataSourceProvider = Provider((ref) => TodoRemoteDataSource(apiClient: ref.watch(apiClientProvider)));
class TodoController extends StateNotifier<AsyncValue<List<TodoItem>>> {
  final TodoRemoteDataSource _source;
  TodoController(this._source): super(const AsyncLoading());
  Future<void> load() async { state = const AsyncLoading(); try { state = AsyncData(await _source.list()); } catch (e, s) { state = AsyncError(e, s); } }
  Future<void> save({String? id, required String title, String? description, DateTime? dueDate, bool? isCompleted}) async {
    final data = {'title': title, 'description': description, 'due_date': dueDate?.toIso8601String().split('T').first, 'is_completed': isCompleted};
    if (id == null) { await _source.create(data); } else { await _source.update(id, data); }
    await load();
  }
  Future<void> remove(String id) async { await _source.delete(id); await load(); }
}
final todoControllerProvider = StateNotifierProvider<TodoController, AsyncValue<List<TodoItem>>>((ref) { final c = TodoController(ref.watch(todoDataSourceProvider)); c.load(); return c; });
