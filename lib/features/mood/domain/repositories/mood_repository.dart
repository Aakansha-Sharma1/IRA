import '../entities/mood_entry.dart';

abstract class MoodRepository {
  Future<List<MoodEntry>> listMoodEntries();
  Future<MoodEntry> createMood({
    required MoodValue mood,
    required int intensity,
    String? note,
    required DateTime entryDate,
  });
  Future<MoodEntry> updateMood({
    required String moodId,
    MoodValue? mood,
    int? intensity,
    String? note,
    DateTime? entryDate,
  });
  Future<MoodEntry?> getMood(String id);
}
