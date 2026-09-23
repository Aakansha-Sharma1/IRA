import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/router.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/ira_button.dart';
import '../../../../core/widgets/ira_card.dart';
import '../../../../core/widgets/ira_error_view.dart';
import '../../../../core/widgets/ira_loading_indicator.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';
import '../../../chat/presentation/controllers/conversation_list_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Future<void> _startConversation(BuildContext context, WidgetRef ref) async {
    final conversation = await ref
        .read(conversationListControllerProvider.notifier)
        .createConversation();
    if (!context.mounted) return;
    if (conversation == null) {
      final failure = ref.read(conversationListControllerProvider).failure;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            failure?.message ?? 'Unable to start a conversation.',
          ),
        ),
      );
      return;
    }
    context.push(AppRoutes.chatPath(conversation.id));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authControllerProvider);
    final profileState = ref.watch(profileControllerProvider);
    final listState = ref.watch(conversationListControllerProvider);
    final profile = profileState.profile;
    final displayName = profile?.displayName;

    if (profileState.isLoading || profileState.isInitial) {
      return const Scaffold(
        body: IraLoadingIndicator(message: 'Loading your companion space...'),
      );
    }

    if (profileState.isError && profile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('IRA')),
        body: IraErrorView(
          title: 'Unable to load your profile',
          message: profileState.failure?.message ??
              'Your home screen needs your PostgreSQL profile.',
          onRetry: () {
            ref.read(profileControllerProvider.notifier).fetchProfile();
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('IRA'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            tooltip: 'Profile',
            onPressed: () => context.push(AppRoutes.profile),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Log out',
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(profileControllerProvider.notifier).fetchProfile();
          },
          child: ListView(
            padding: AppDimensions.screenPadding,
            children: [
              Text(
                displayName != null && displayName.isNotEmpty
                    ? '${_greeting()}, $displayName'
                    : _greeting(),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppDimensions.space8),
              Text(
                'Your preventive wellness companion is here when you want to talk.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: AppDimensions.space24),
              IraCard(
                backgroundColor:
                    theme.colorScheme.primaryContainer.withValues(alpha: 0.45),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: theme.colorScheme.primary,
                          child: const Icon(Icons.spa_rounded, color: Colors.white),
                        ),
                        const SizedBox(width: AppDimensions.space12),
                        Expanded(
                          child: Text(
                            'IRA Companion',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.space12),
                    Text(
                      'Start a real conversation. Messages are stored privately for your account.',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppDimensions.space16),
                    IraButton(
                      text: listState.isCreating
                          ? 'Starting...'
                          : 'Talk with IRA',
                      isLoading: listState.isCreating,
                      onPressed: listState.isCreating
                          ? null
                          : () => _startConversation(context, ref),
                      icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.space16),
              IraCard(
                onTap: () => context.push(AppRoutes.conversations),
                child: Row(
                  children: [
                    Icon(
                      Icons.forum_outlined,
                      color: theme.colorScheme.secondary,
                    ),
                    const SizedBox(width: AppDimensions.space12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Conversation history',
                            style: theme.textTheme.titleSmall,
                          ),
                          Text(
                            'Open conversations saved for this account',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.65),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.space16),
              IraCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your space',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Divider(height: 24),
                    _HomeMetaRow(
                      label: 'Account',
                      value: authState.user?.email ?? '—',
                    ),
                    const SizedBox(height: 8),
                    _HomeMetaRow(
                      label: 'Timezone',
                      value: profile?.timezone ?? '—',
                    ),
                    const SizedBox(height: 8),
                    _HomeMetaRow(
                      label: 'Activity',
                      value: _prettyActivity(profile?.activityLevel),
                    ),
                    if (profile?.wellnessGoals.isNotEmpty == true) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: profile!.wellnessGoals
                            .map(
                              (goal) => Chip(
                                label: Text(
                                  goal,
                                  style: const TextStyle(fontSize: 11),
                                ),
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                              ),
                            )
                            .toList(),
                      ),
                    ],
                    if (profile != null) ...[
                      const SizedBox(height: AppDimensions.space12),
                      Text(
                        'Updated ${DateFormat.MMMd().add_jm().format(profile.updatedAt.toLocal())}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.space16),
              IraCard(
                onTap: () => context.push(AppRoutes.profile),
                child: Row(
                  children: [
                    Icon(Icons.manage_accounts_outlined,
                        color: theme.colorScheme.primary),
                    const SizedBox(width: AppDimensions.space12),
                    Expanded(
                      child: Text(
                        'Profile & preferences',
                        style: theme.textTheme.titleSmall,
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _prettyActivity(String? value) {
    if (value == null || value.isEmpty) return '—';
    return value[0].toUpperCase() + value.substring(1);
  }
}

class _HomeMetaRow extends StatelessWidget {
  final String label;
  final String value;

  const _HomeMetaRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 88,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
