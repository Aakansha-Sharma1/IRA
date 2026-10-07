import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/journal_remote_data_source.dart';
import '../../domain/entities/journal_entry.dart';

final journalDataSourceProvider = Provider((ref) => JournalRemoteDataSource(apiClient: ref.watch(apiClientProvider)));

class JournalController extends StateNotifier<AsyncValue<List<JournalEntry>>> {
  final JournalRemoteDataSource _source;
  JournalController(this._source) : super(const AsyncLoading());

  Future<void> load() async {
    state = const AsyncLoading();
    try { state = AsyncData(await _source.list()); } catch (error, stack) { state = AsyncError(error, stack); }
  }

  Future<bool> save({String? id, required String title, required String content, String? mood}) async {
    try {
      final data = {'title': title, 'content': content, 'mood': mood};
      if (id == null) {
        await _source.create(data);
      } else {
        await _source.update(id, data);
      }
      await load();
      return true;
    } catch (_) { return false; }
  }

  Future<void> remove(String id) async {
    await _source.delete(id);
    await load();
  }
}

final journalControllerProvider = StateNotifierProvider<JournalController, AsyncValue<List<JournalEntry>>>((ref) {
  final controller = JournalController(ref.watch(journalDataSourceProvider));
  controller.load();
  return controller;
});
