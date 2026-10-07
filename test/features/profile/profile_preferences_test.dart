import 'package:flutter_test/flutter_test.dart';
import 'package:ira_app/features/profile/data/models/user_profile_model.dart';
import 'package:ira_app/features/profile/domain/entities/user_profile.dart';

void main() {
  final profileJson = <String, dynamic>{
    'id': 'profile-1',
    'user_id': 'user-1',
    'display_name': 'Member',
    'companion_name': 'IRA',
    'representative_name': 'Asha',
    'representative_gender': 'female',
    'age': null,
    'gender': null,
    'pronouns': 'they/them',
    'timezone': 'UTC',
    'wellness_goals': <String>[],
    'sleep_hours_target': 8.0,
    'activity_level': 'moderate',
    'onboarding_completed': true,
    'created_at': '2026-10-05T00:00:00Z',
    'updated_at': '2026-10-05T00:00:00Z',
  };

  test('loads representative preferences from the profile API shape', () {
    final profile = UserProfileModel.fromJson(profileJson);

    expect(profile.representativeName, 'Asha');
    expect(profile.representativeGender, 'female');
    expect(profile.gender, isNull);
  });

  test('profile copy preserves representative preferences across restoration',
      () {
    final profile = UserProfile(
      id: 'profile-1',
      userId: 'user-1',
      displayName: 'Member',
      representativeName: 'Asha',
      representativeGender: 'female',
      timezone: 'UTC',
      onboardingCompleted: true,
      createdAt: DateTime.utc(2026, 10, 5),
      updatedAt: DateTime.utc(2026, 10, 5),
    );

    final restored = profile.copyWith(displayName: 'Updated Member');

    expect(restored.representativeName, 'Asha');
    expect(restored.representativeGender, 'female');
    expect(restored.displayName, 'Updated Member');
  });
}
