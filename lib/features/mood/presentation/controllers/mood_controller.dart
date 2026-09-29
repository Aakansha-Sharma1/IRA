import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/utils/logger.dart';
import '../../data/datasources/mood_remote_data_source.dart';
import '../../data/repositories/mood_repository_impl.dart';
import '../../domain/entities/mood_entry.dart';
import '../../domain/repositories/mood_repository.dart';
import 'mood_state.dart';

final moodRemoteDataSourceProvider = Provider<MoodRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return MoodRemoteDataSourceImpl(apiClient: apiClient);
});

final moodRepositoryProvider = Provider<MoodRepository>((ref) {
  final remoteDataSource = ref.watch(moodRemoteDataSourceProvider);
  return MoodRepositoryImpl(remoteDataSource: remoteDataSource);
});

class MoodController extends StateNotifier<MoodState> {
  final MoodRepository _repository;

  MoodController(this._repository) : super(const MoodState.initial());

  Future<void> loadMoods() async {
    state = MoodState.loading(entries: state.entries);
    try {
      final entries = await _repository.listMoodEntries();
      final today = _todayEntry(entries);
      state = entries.isEmpty
          ? const MoodState.empty()
          : MoodState.loaded(entries, todayEntry: today);
    } on AppException catch (e) {
      AppLogger.error('Failed to load mood history', e);
      state = MoodState.error(_mapFailure(e), entries: state.entries);
    } catch (e, st) {
      AppLogger.error('Unexpected error loading mood history', e, st);
      state = const MoodState.error(
        ServerFailure(message: 'Unable to load mood history.'),
      );
    }
  }

  Future<MoodEntry?> saveMood({
    required MoodValue mood,
    required int intensity,
    String? note,
    required DateTime entryDate,
    String? moodId,
  }) async {
    state = MoodState.saving(entries: state.entries, todayEntry: state.todayEntry);
    try {
      MoodEntry saved;
      if (moodId != null && moodId.isNotEmpty) {
        saved = await _repository.updateMood(
          moodId: moodId,
          mood: mood,
          intensity: intensity,
          note: note,
          entryDate: entryDate,
        );
      } else {
        saved = await _repository.createMood(
          mood: mood,
          intensity: intensity,
          note: note,
          entryDate: entryDate,
        );
      }
      final entries = [...state.entries];
      final existingIndex = entries.indexWhere((entry) => entry.id == saved.id);
      if (existingIndex >= 0) {
        entries[existingIndex] = saved;
      } else {
        entries.insert(0, saved);
      }
      state = MoodState.saved(saved, entries: entries);
      return saved;
    } on AppException catch (e) {
      AppLogger.error('Failed to save mood', e);
      state = MoodState.error(_mapFailure(e), entries: state.entries, todayEntry: state.todayEntry);
      return null;
    } catch (e, st) {
      AppLogger.error('Unexpected error saving mood', e, st);
      state = MoodState.error(
        const ServerFailure(message: 'Unable to save your mood check-in.'),
        entries: state.entries,
        todayEntry: state.todayEntry,
      );
      return null;
    }
  }

  void clear() {
    state = const MoodState.initial();
  }

  MoodEntry? getTodayEntry() {
    final entries = state.entries;
    return _todayEntry(entries);
  }

  static MoodEntry? _todayEntry(List<MoodEntry> entries) {
    final today = DateTime.now();
    for (final entry in entries) {
      final sameDay = entry.entryDate.year == today.year &&
          entry.entryDate.month == today.month &&
          entry.entryDate.day == today.day;
      if (sameDay) return entry;
    }
    return null;
  }

  static Failure _mapFailure(AppException exception) {
    if (exception is NetworkException) {
      return NetworkFailure(message: exception.message);
    }
    if (exception is TimeoutException) {
      return TimeoutFailure(message: exception.message);
    }
    if (exception is AuthException) {
      return AuthFailure(message: exception.message);
    }
    if (exception is ValidationException) {
      return ValidationFailure(message: exception.message);
    }
    if (exception is ServerException) {
      return ServerFailure(message: exception.message);
    }
    return UnknownFailure(message: exception.message);
  }
}

final moodControllerProvider = StateNotifierProvider<MoodController, MoodState>((ref) {
  final repository = ref.watch(moodRepositoryProvider);
  return MoodController(repository);
});
