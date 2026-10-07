import 'package:flutter_test/flutter_test.dart';
import 'package:ira_app/features/home/presentation/screens/home_screen.dart';
import 'package:ira_app/features/profile/domain/entities/user_profile.dart';

void main() {
  final timestamp = DateTime.utc(2026, 10, 5);

  UserProfile profile({
    String displayName = 'Member',
    String companionName = 'IRA',
    String? representativeName,
  }) {
    return UserProfile(
      id: 'profile-1',
      userId: 'user-1',
      displayName: displayName,
      companionName: companionName,
      representativeName: representativeName,
      timezone: 'UTC',
      onboardingCompleted: true,
      createdAt: timestamp,
      updatedAt: timestamp,
    );
  }

  group('homeGreetingForHour', () {
    test('uses morning greeting from 05:00 through 11:59', () {
      expect(homeGreetingForHour(5), 'Good morning');
      expect(homeGreetingForHour(11), 'Good morning');
    });

    test('uses afternoon greeting from 12:00 through 16:59', () {
      expect(homeGreetingForHour(12), 'Good afternoon');
      expect(homeGreetingForHour(16), 'Good afternoon');
    });

    test('uses evening greeting from 17:00 through 04:59', () {
      expect(homeGreetingForHour(17), 'Good evening');
      expect(homeGreetingForHour(0), 'Good evening');
      expect(homeGreetingForHour(4), 'Good evening');
    });
  });

  test('uses persisted display and representative names', () {
    final persisted = profile(
      displayName: 'Maya',
      companionName: 'IRA',
      representativeName: 'Asha',
    );

    expect(homeDisplayName(persisted), 'Maya');
    expect(homeRepresentativeName(persisted), 'Asha');
  });

  test('handles missing profile values without inventing identity', () {
    final missingNames = profile(displayName: ' ', companionName: ' ');

    expect(homeDisplayName(null), 'there');
    expect(homeRepresentativeName(null), 'IRA');
    expect(homeDisplayName(missingNames), 'there');
    expect(homeRepresentativeName(missingNames), 'IRA');
  });
}
