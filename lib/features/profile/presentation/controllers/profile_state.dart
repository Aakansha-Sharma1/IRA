import 'package:equatable/equatable.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/user_profile.dart';

enum ProfileStatus {
  initial,
  loading,
  notFound,
  loaded,
  saving,
  saved,
  error,
}

class ProfileState extends Equatable {
  final ProfileStatus status;
  final UserProfile? profile;
  final Failure? failure;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile,
    this.failure,
  });

  const ProfileState.initial() : this(status: ProfileStatus.initial);

  const ProfileState.loading() : this(status: ProfileStatus.loading);

  const ProfileState.notFound() : this(status: ProfileStatus.notFound);

  const ProfileState.loaded(UserProfile profile)
      : this(status: ProfileStatus.loaded, profile: profile);

  const ProfileState.saving(UserProfile? currentProfile)
      : this(status: ProfileStatus.saving, profile: currentProfile);

  const ProfileState.saved(UserProfile profile)
      : this(status: ProfileStatus.saved, profile: profile);

  const ProfileState.error(Failure failure, {UserProfile? profile})
      : this(status: ProfileStatus.error, failure: failure, profile: profile);

  bool get isInitial => status == ProfileStatus.initial;
  bool get isLoading => status == ProfileStatus.loading;
  bool get isNotFound => status == ProfileStatus.notFound;
  bool get isLoaded => status == ProfileStatus.loaded && profile != null;
  bool get isSaving => status == ProfileStatus.saving;
  bool get isSaved => status == ProfileStatus.saved;
  bool get isError => status == ProfileStatus.error;

  bool get hasCompletedOnboarding =>
      profile != null && profile!.onboardingCompleted;

  ProfileState copyWith({
    ProfileStatus? status,
    UserProfile? profile,
    Failure? failure,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      failure: failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [status, profile, failure];
}
