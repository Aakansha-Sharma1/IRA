import '../../domain/entities/mood_entry.dart';

class MoodEntryModel extends MoodEntry {
  const MoodEntryModel({
    required super.id,
    required super.userId,
    required super.mood,
    required super.intensity,
    super.note,
    required super.entryDate,
    required super.createdAt,
    required super.updatedAt,
  });

  factory MoodEntryModel.fromJson(Map<String, dynamic> json) {
    final moodValue = MoodValueX.fromApiValue(json['mood'] as String? ?? 'neutral');
    return MoodEntryModel(
      id: json['id'] as String,
      userId: json['user_id'] as String? ?? '',
      mood: moodValue,
      intensity: (json['intensity'] as num?)?.toInt() ?? 3,
      note: json['note'] as String?,
      entryDate: DateTime.parse(json['entry_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'mood': mood.apiValue,
      'intensity': intensity,
      'note': note,
      'entry_date': entryDate.toIso8601String().split('T').first,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  MoodEntry toEntity() => this;
}
