import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/ira_button.dart';
import '../../../../core/widgets/ira_card.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';
import '../controllers/auth_controller.dart';

class AuthenticatedHomePlaceholder extends ConsumerWidget {
  const AuthenticatedHomePlaceholder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authControllerProvider);
    final profileState = ref.watch(profileControllerProvider);
    final user = authState.user;
    final profile = profileState.profile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('IRA AI'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            tooltip: 'View Profile',
            onPressed: () {
              context.push(AppRoutes.profile);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Log Out',
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppDimensions.screenPadding,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_outline_rounded,
                    size: 44,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: AppDimensions.space24),
                Text(
                  profile != null
                      ? 'Welcome, ${profile.displayName}'
                      : 'Authentication Successful',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.space8),
                Text(
                  'PostgreSQL-backed profile & onboarding complete',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.space24),
                IraCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.badge_outlined, color: theme.colorScheme.primary),
                          const SizedBox(width: AppDimensions.space8),
                          Text(
                            'Account & Profile Summary',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      _buildInfoRow('Email', user?.email ?? '—'),
                      const SizedBox(height: 8),
                      _buildInfoRow('Timezone', profile?.timezone ?? 'UTC'),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        'Target Sleep',
                        profile?.sleepHoursTarget != null
                            ? '${profile!.sleepHoursTarget!.toStringAsFixed(1)} hrs/night'
                            : '8.0 hrs/night',
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        'Activity Level',
                        () {
                          final lvl = profile?.activityLevel;
                          if (lvl == null || lvl.isEmpty) return 'Moderate';
                          return lvl[0].toUpperCase() + lvl.substring(1);
                        }(),
                      ),
                      if (profile?.wellnessGoals.isNotEmpty == true) ...[
                        const SizedBox(height: 12),
                        const Text(
                          'Wellness Focus:',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: profile!.wellnessGoals.map((g) {
                            return Chip(
                              label: Text(g, style: const TextStyle(fontSize: 11)),
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.space32),
                IraButton(
                  text: 'View & Edit Profile',
                  onPressed: () {
                    context.push(AppRoutes.profile);
                  },
                ),
                const SizedBox(height: AppDimensions.space12),
                IraButton(
                  text: 'Sign Out',
                  variant: IraButtonVariant.outlined,
                  onPressed: () async {
                    await ref.read(authControllerProvider.notifier).logout();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
