import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/ira_card.dart';
import '../../../../core/widgets/ira_error_view.dart';
import '../../../../core/widgets/ira_icon_container.dart';
import '../../../../core/widgets/ira_loading_indicator.dart';
import '../../../../core/widgets/ira_section_header.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../profile/domain/entities/user_profile.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';

String homeGreetingForHour(int hour) {
  if (hour >= 5 && hour < 12) return 'Good morning';
  if (hour >= 12 && hour < 17) return 'Good afternoon';
  return 'Good evening';
}

String homeDisplayName(UserProfile? profile) {
  final name = profile?.displayName.trim();
  return name == null || name.isEmpty ? 'there' : name;
}

String homeRepresentativeName(UserProfile? profile) {
  final representativeName = profile?.representativeName?.trim();
  if (representativeName != null && representativeName.isNotEmpty) {
    return representativeName;
  }
  final companionName = profile?.companionName.trim();
  if (companionName != null && companionName.isNotEmpty) return companionName;
  return 'IRA';
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileControllerProvider);
    final profile = profileState.profile;

    if (profileState.isLoading || profileState.isInitial) {
      return const Scaffold(
        body: IraLoadingIndicator(message: 'Loading your companion space...'),
      );
    }
    if (profileState.isError && profile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('IRA Companion')),
        body: IraErrorView(
          title: 'Unable to load your profile',
          message: profileState.failure?.message ?? 'Please try again.',
          onRetry: () =>
              ref.read(profileControllerProvider.notifier).fetchProfile(),
        ),
      );
    }

    final representativeGender = profile?.representativeGender;
    final greeting =
        '${homeGreetingForHour(DateTime.now().hour)}, ${homeDisplayName(profile)}';
    final companionName = homeRepresentativeName(profile);
    return Scaffold(
      appBar: AppBar(
        title: const Text('IRA Companion'),
        leading: IconButton(
          icon: const Icon(Icons.chat_bubble_outline_rounded),
          tooltip: 'Open chat',
          onPressed: () => context.go(AppRoutes.chatLanding),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            tooltip: 'Profile',
            onPressed: () => context.push(AppRoutes.profile),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Log out',
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: AppDimensions.screenPadding,
          children: [
            Text(
              greeting,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: AppDimensions.space8),
            Text(
              'A calm place for your journey with $companionName.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.72),
                  ),
            ),
            const SizedBox(height: AppDimensions.space24),
            IraCard(
              child: Column(
                children: [
                  const IraIconContainer(
                    icon: Icons.auto_awesome_rounded,
                    size: 72,
                  ),
                  const SizedBox(height: AppDimensions.space16),
                  Text(
                    'IRA REPRESENTATIVE',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          letterSpacing: 1.4,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: AppDimensions.space8),
                  Text(
                    companionName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: AppDimensions.space4),
                  Text(
                    representativeGender == null
                        ? 'Choose a representative preference in Profile'
                        : _prettyGender(representativeGender),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.space24),
            const IraSectionHeader(
              title: 'JOURNEY',
              subtitle: 'Your personal path starts here',
            ),
            const SizedBox(height: AppDimensions.space8),
            IraCard(
              onTap: () => _showComingSoon(context, 'Journey'),
              child: Row(
                children: [
                  const IraIconContainer(icon: Icons.auto_stories_outlined),
                  const SizedBox(width: AppDimensions.space12),
                  Expanded(
                    child: Text(
                      'Your journey starts here',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.space24),
            const IraSectionHeader(
              title: 'EXPLORE',
              subtitle: 'Small steps toward feeling well',
            ),
            const SizedBox(height: AppDimensions.space8),
            _FeatureCard(
              title: 'Yoga',
              subtitle: 'Move, stretch and breathe',
              icon: Icons.self_improvement_rounded,
              onTap: () => context.push(AppRoutes.yoga),
            ),
            _FeatureCard(
              title: 'Mental Wellness',
              subtitle: 'Take a mindful pause',
              icon: Icons.spa_outlined,
              onTap: () => context.push(AppRoutes.mentalWellness),
            ),
            _FeatureCard(
              title: 'Journal',
              subtitle: 'Write what is on your mind',
              icon: Icons.book_outlined,
              onTap: () => context.push(AppRoutes.journal),
            ),
            _FeatureCard(
              title: 'Todo',
              subtitle: 'Keep track of what matters',
              icon: Icons.check_circle_outline_rounded,
              onTap: () => context.push(AppRoutes.todo),
            ),
          ],
        ),
      ),
    );
  }

  static String _prettyGender(String value) {
    return value
        .split('_')
        .map((part) => part[0].toUpperCase() + part.substring(1))
        .join(' ');
  }

  static void _showComingSoon(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$title entries are coming in the next phase.')),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.space12),
      child: IraCard(
        onTap: onTap,
        child: Row(
          children: [
            IraIconContainer(icon: icon, size: 52),
            const SizedBox(width: AppDimensions.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppDimensions.space4),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}
