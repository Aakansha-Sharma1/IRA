import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserProfile?> getProfile() async {
    try {
      final model = await remoteDataSource.getProfile();
      return model.toEntity();
    } on ValidationException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    } on ServerException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<UserProfile> createProfile({
    required String displayName,
    int? age,
    String? gender,
    required String timezone,
    List<String> wellnessGoals = const [],
    double? sleepHoursTarget = 8.0,
    String? activityLevel = 'moderate',
    bool onboardingCompleted = true,
  }) async {
    final payload = {
      'display_name': displayName,
      if (age != null) 'age': age,
      if (gender != null && gender.isNotEmpty) 'gender': gender,
      'timezone': timezone,
      'wellness_goals': wellnessGoals,
      'sleep_hours_target': sleepHoursTarget,
      'activity_level': activityLevel,
      'onboarding_completed': onboardingCompleted,
    };
    final model = await remoteDataSource.createProfile(payload);
    return model.toEntity();
  }

  @override
  Future<UserProfile> updateProfile({
    String? displayName,
    int? age,
    String? gender,
    String? timezone,
    List<String>? wellnessGoals,
    double? sleepHoursTarget,
    String? activityLevel,
  }) async {
    final payload = <String, dynamic>{
      if (displayName != null) 'display_name': displayName,
      if (age != null) 'age': age,
      if (gender != null) 'gender': gender,
      if (timezone != null) 'timezone': timezone,
      if (wellnessGoals != null) 'wellness_goals': wellnessGoals,
      if (sleepHoursTarget != null) 'sleep_hours_target': sleepHoursTarget,
      if (activityLevel != null) 'activity_level': activityLevel,
    };
    final model = await remoteDataSource.updateProfile(payload);
    return model.toEntity();
  }
}
