import 'package:equatable/equatable.dart';

/// Domain entity representing the authenticated user's IRA profile.
class UserProfile extends Equatable {
  final String id;
  final String userId;
  final String displayName;
  final int? age;
  final String? gender;
  final String timezone;
  final List<String> wellnessGoals;
  final double? sleepHoursTarget;
  final String? activityLevel;
  final bool onboardingCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.userId,
    required this.displayName,
    this.age,
    this.gender,
    required this.timezone,
    this.wellnessGoals = const [],
    this.sleepHoursTarget = 8.0,
    this.activityLevel = 'moderate',
    required this.onboardingCompleted,
    required this.createdAt,
    required this.updatedAt,
  });

  UserProfile copyWith({
    String? id,
    String? userId,
    String? displayName,
    int? age,
    String? gender,
    String? timezone,
    List<String>? wellnessGoals,
    double? sleepHoursTarget,
    String? activityLevel,
    bool? onboardingCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      timezone: timezone ?? this.timezone,
      wellnessGoals: wellnessGoals ?? this.wellnessGoals,
      sleepHoursTarget: sleepHoursTarget ?? this.sleepHoursTarget,
      activityLevel: activityLevel ?? this.activityLevel,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        displayName,
        age,
        gender,
        timezone,
        wellnessGoals,
        sleepHoursTarget,
        activityLevel,
        onboardingCompleted,
        createdAt,
        updatedAt,
      ];
}
