import '../entities/user_profile.dart';

abstract class ProfileRepository {
  Future<UserProfile?> getProfile();

  Future<UserProfile> createProfile({
    required String displayName,
    String companionName = 'IRA',
    String? representativeName,
    String? representativeGender,
    int? age,
    String? gender,
    String pronouns = 'she/her',
    required String timezone,
    List<String> wellnessGoals = const [],
    double? sleepHoursTarget = 8.0,
    String? activityLevel = 'moderate',
    bool onboardingCompleted = true,
  });

  Future<UserProfile> updateProfile({
    String? displayName,
    String? companionName,
    String? representativeName,
    String? representativeGender,
    int? age,
    String? gender,
    String? pronouns,
    String? timezone,
    List<String>? wellnessGoals,
    double? sleepHoursTarget,
    String? activityLevel,
  });
}
