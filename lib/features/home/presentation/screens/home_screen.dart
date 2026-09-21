import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/ira_card.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authControllerProvider);
    final userName = authState.user?.displayName ?? 'Friend';

    final featureTiles = [
      _FeatureTile(
        title: 'Conversations',
        subtitle: 'Chat with IRA',
        icon: Icons.chat_bubble_outline_rounded,
        color: theme.colorScheme.primary,
        route: '/chat',
      ),
      _FeatureTile(
        title: 'Voice Session',
        subtitle: 'Speak with IRA & Avatar',
        icon: Icons.mic_none_rounded,
        color: theme.colorScheme.secondary,
        route: '/voice',
      ),
      const _FeatureTile(
        title: 'Mood Log',
        subtitle: 'Record daily emotions',
        icon: Icons.sentiment_satisfied_alt_rounded,
        color: Color(0xFFF59E0B),
        route: '/mood',
      ),
      const _FeatureTile(
        title: 'Journal',
        subtitle: 'Daily self-reflection',
        icon: Icons.edit_note_rounded,
        color: Color(0xFF10B981),
        route: '/journal',
      ),
      const _FeatureTile(
        title: 'Goals & Habits',
        subtitle: 'Track lifestyle routines',
        icon: Icons.flag_outlined,
        color: Color(0xFF06B6D4),
        route: '/goals',
      ),
      const _FeatureTile(
        title: 'Analytics',
        subtitle: 'Mood, sleep & stress',
        icon: Icons.bar_chart_rounded,
        color: Color(0xFF8B5CF6),
        route: '/analytics',
      ),
      const _FeatureTile(
        title: 'AI Insights',
        subtitle: 'Preventive wellness tips',
        icon: Icons.auto_awesome_outlined,
        color: Color(0xFFEC4899),
        route: '/insights',
      ),
      const _FeatureTile(
        title: 'Wellness Activities',
        subtitle: 'Meditation, breathwork',
        icon: Icons.self_improvement_rounded,
        color: Color(0xFF14B8A6),
        route: '/wellness',
      ),
      _FeatureTile(
        title: 'Crisis Support',
        subtitle: 'Safety & Emergency info',
        icon: Icons.health_and_safety_outlined,
        color: theme.colorScheme.error,
        route: '/safety',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('IRA AI Companion'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            tooltip: 'Profile',
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppDimensions.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting Banner
              IraCard(
                backgroundColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.space12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.spa_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.space16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, $userName',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'How are you feeling right now?',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.space24),
              Text(
                'Explore Modules',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: AppDimensions.space12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppDimensions.space12,
                  mainAxisSpacing: AppDimensions.space12,
                  childAspectRatio: 1.25,
                ),
                itemCount: featureTiles.length,
                itemBuilder: (context, index) {
                  final tile = featureTiles[index];
                  return IraCard(
                    onTap: () => context.push(tile.route),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(tile.icon, size: 28, color: tile.color),
                        const SizedBox(height: AppDimensions.space8),
                        Text(
                          tile.title,
                          style: theme.textTheme.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          tile.subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: AppDimensions.space24),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureTile {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;

  const _FeatureTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.route,
  });
}
