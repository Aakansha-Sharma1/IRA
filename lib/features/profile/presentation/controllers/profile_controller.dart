import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/logger.dart';
import '../../data/datasources/profile_remote_data_source.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/repositories/profile_repository.dart';
import 'profile_state.dart';

final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProfileRemoteDataSourceImpl(apiClient: apiClient);
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final remoteDataSource = ref.watch(profileRemoteDataSourceProvider);
  return ProfileRepositoryImpl(remoteDataSource: remoteDataSource);
});

class ProfileController extends StateNotifier<ProfileState> {
  final ProfileRepository _repository;

  ProfileController(this._repository) : super(const ProfileState.initial());

  Future<void> fetchProfile() async {
    state = const ProfileState.loading();
    try {
      final profile = await _repository.getProfile();
      if (profile == null) {
        state = const ProfileState.notFound();
      } else {
        state = ProfileState.loaded(profile);
      }
    } on AppException catch (e) {
      AppLogger.error('Failed to fetch profile', e);
      state = ProfileState.error(ServerFailure(message: e.message));
    } catch (e, st) {
      AppLogger.error('Unexpected error fetching profile', e, st);
      state = const ProfileState.error(
        ServerFailure(message: 'Failed to retrieve profile. Check connection.'),
      );
    }
  }

  Future<bool> createProfile({
    required String displayName,
    int? age,
    String? gender,
    required String timezone,
    List<String> wellnessGoals = const [],
    double? sleepHoursTarget = 8.0,
    String? activityLevel = 'moderate',
  }) async {
    state = ProfileState.saving(state.profile);
    try {
      final profile = await _repository.createProfile(
        displayName: displayName.trim(),
        age: age,
        gender: gender?.trim(),
        timezone: timezone.trim(),
        wellnessGoals: wellnessGoals,
        sleepHoursTarget: sleepHoursTarget,
        activityLevel: activityLevel,
        onboardingCompleted: true,
      );
      state = ProfileState.loaded(profile);
      return true;
    } on AppException catch (e) {
      AppLogger.error('Failed to save onboarding profile', e);
      state = ProfileState.error(
        ServerFailure(message: e.message),
        profile: state.profile,
      );
      return false;
    } catch (e, st) {
      AppLogger.error('Unexpected error saving profile', e, st);
      state = ProfileState.error(
        const ServerFailure(message: 'Unable to save profile to PostgreSQL.'),
        profile: state.profile,
      );
      return false;
    }
  }

  Future<bool> updateProfile({
    String? displayName,
    int? age,
    String? gender,
    String? timezone,
    List<String>? wellnessGoals,
    double? sleepHoursTarget,
    String? activityLevel,
  }) async {
    state = ProfileState.saving(state.profile);
    try {
      final updated = await _repository.updateProfile(
        displayName: displayName?.trim(),
        age: age,
        gender: gender?.trim(),
        timezone: timezone?.trim(),
        wellnessGoals: wellnessGoals,
        sleepHoursTarget: sleepHoursTarget,
        activityLevel: activityLevel,
      );
      state = ProfileState.loaded(updated);
      return true;
    } on AppException catch (e) {
      AppLogger.error('Failed to update profile', e);
      state = ProfileState.error(
        ServerFailure(message: e.message),
        profile: state.profile,
      );
      return false;
    } catch (e, st) {
      AppLogger.error('Unexpected error updating profile', e, st);
      state = ProfileState.error(
        const ServerFailure(message: 'Profile update failed.'),
        profile: state.profile,
      );
      return false;
    }
  }

  void clearProfile() {
    state = const ProfileState.initial();
  }
}

final profileControllerProvider =
    StateNotifierProvider<ProfileController, ProfileState>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return ProfileController(repository);
});
