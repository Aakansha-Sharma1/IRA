import '../entities/user_profile.dart';

abstract class ProfileRepository {
  Future<UserProfile?> getProfile();

  Future<UserProfile> createProfile({
    required String displayName,
    int? age,
    String? gender,
    required String timezone,
    List<String> wellnessGoals = const [],
    double? sleepHoursTarget = 8.0,
    String? activityLevel = 'moderate',
    bool onboardingCompleted = true,
  });

  Future<UserProfile> updateProfile({
    String? displayName,
    int? age,
    String? gender,
    String? timezone,
    List<String>? wellnessGoals,
    double? sleepHoursTarget,
    String? activityLevel,
  });
}
