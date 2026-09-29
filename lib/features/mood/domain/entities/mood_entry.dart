import 'package:equatable/equatable.dart';

enum MoodValue {
  veryLow,
  low,
  neutral,
  good,
  veryGood,
}

extension MoodValueX on MoodValue {
  String get apiValue {
    switch (this) {
      case MoodValue.veryLow:
        return 'very_low';
      case MoodValue.low:
        return 'low';
      case MoodValue.neutral:
        return 'neutral';
      case MoodValue.good:
        return 'good';
      case MoodValue.veryGood:
        return 'very_good';
    }
  }

  String get label {
    switch (this) {
      case MoodValue.veryLow:
        return 'Very low';
      case MoodValue.low:
        return 'Low';
      case MoodValue.neutral:
        return 'Neutral';
      case MoodValue.good:
        return 'Good';
      case MoodValue.veryGood:
        return 'Very good';
    }
  }

  static MoodValue fromApiValue(String value) {
    switch (value.trim().toLowerCase()) {
      case 'very_low':
        return MoodValue.veryLow;
      case 'low':
        return MoodValue.low;
      case 'neutral':
        return MoodValue.neutral;
      case 'good':
        return MoodValue.good;
      case 'very_good':
        return MoodValue.veryGood;
      default:
        return MoodValue.neutral;
    }
  }
}

class MoodEntry extends Equatable {
  final String id;
  final String userId;
  final MoodValue mood;
  final int intensity;
  final String? note;
  final DateTime entryDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MoodEntry({
    required this.id,
    required this.userId,
    required this.mood,
    required this.intensity,
    this.note,
    required this.entryDate,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        mood,
        intensity,
        note,
        entryDate,
        createdAt,
        updatedAt,
      ];
}
