import '../../domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    required super.userId,
    required super.displayName,
    super.age,
    super.gender,
    required super.timezone,
    super.wellnessGoals,
    super.sleepHoursTarget,
    super.activityLevel,
    required super.onboardingCompleted,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      displayName: json['display_name'] as String,
      age: json['age'] as int?,
      gender: json['gender'] as String?,
      timezone: json['timezone'] as String? ?? 'UTC',
      wellnessGoals: (json['wellness_goals'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      sleepHoursTarget: (json['sleep_hours_target'] as num?)?.toDouble() ?? 8.0,
      activityLevel: json['activity_level'] as String? ?? 'moderate',
      onboardingCompleted: json['onboarding_completed'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'display_name': displayName,
      'age': age,
      'gender': gender,
      'timezone': timezone,
      'wellness_goals': wellnessGoals,
      'sleep_hours_target': sleepHoursTarget,
      'activity_level': activityLevel,
      'onboarding_completed': onboardingCompleted,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserProfile toEntity() => this;
}
