import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/mood_entry.dart';
import '../../domain/repositories/mood_repository.dart';
import '../datasources/mood_remote_data_source.dart';

class MoodRepositoryImpl implements MoodRepository {
  final MoodRemoteDataSource remoteDataSource;

  MoodRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<MoodEntry>> listMoodEntries() async {
    final models = await remoteDataSource.listMoodEntries();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<MoodEntry> createMood({
    required MoodValue mood,
    required int intensity,
    String? note,
    required DateTime entryDate,
  }) async {
    final payload = <String, dynamic>{
      'mood': mood.apiValue,
      'intensity': intensity,
      'entry_date': entryDate.toIso8601String().split('T').first,
      if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
    };
    final model = await remoteDataSource.createMood(payload);
    return model.toEntity();
  }

  @override
  Future<MoodEntry> updateMood({
    required String moodId,
    MoodValue? mood,
    int? intensity,
    String? note,
    DateTime? entryDate,
  }) async {
    final payload = <String, dynamic>{
      if (mood != null) 'mood': mood.apiValue,
      if (intensity != null) 'intensity': intensity,
      if (entryDate != null) 'entry_date': entryDate.toIso8601String().split('T').first,
      if (note != null) 'note': note,
    };
    final model = await remoteDataSource.updateMood(moodId, payload);
    return model.toEntity();
  }

  @override
  Future<MoodEntry?> getMood(String id) async {
    try {
      final model = await remoteDataSource.getMood(id);
      return model.toEntity();
    } on ValidationException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    } on ServerException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }
}
