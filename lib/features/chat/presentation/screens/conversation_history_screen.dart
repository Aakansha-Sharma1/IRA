import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/router.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/ira_card.dart';
import '../../../../core/widgets/ira_error_view.dart';
import '../../../../core/widgets/ira_loading_indicator.dart';
import '../controllers/conversation_list_controller.dart';
import '../controllers/conversation_list_state.dart';

class ConversationHistoryScreen extends ConsumerStatefulWidget {
  const ConversationHistoryScreen({super.key});

  @override
  ConsumerState<ConversationHistoryScreen> createState() =>
      _ConversationHistoryScreenState();
}

class _ConversationHistoryScreenState
    extends ConsumerState<ConversationHistoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(conversationListControllerProvider.notifier).loadConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(conversationListControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversations'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: state.isCreating
            ? null
            : () async {
                final conversation = await ref
                    .read(conversationListControllerProvider.notifier)
                    .createConversation();
                if (!context.mounted) return;
                if (conversation == null) {
                  final failure =
                      ref.read(conversationListControllerProvider).failure;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        failure?.message ?? 'Unable to create conversation.',
                      ),
                    ),
                  );
                  return;
                }
                context.push(AppRoutes.chatPath(conversation.id));
              },
        icon: const Icon(Icons.add_comment_outlined),
        label: const Text('New chat'),
      ),
      body: SafeArea(
        child: _buildBody(theme, state),
      ),
    );
  }

  Widget _buildBody(ThemeData theme, ConversationListState state) {
    if (state.isLoading && state.conversations.isEmpty) {
      return const IraLoadingIndicator(message: 'Loading conversations...');
    }

    if (state.isError && state.conversations.isEmpty) {
      return IraErrorView(
        title: 'Could not load conversations',
        message: state.failure?.message ??
            'Check that the backend and PostgreSQL are available.',
        onRetry: () {
          ref.read(conversationListControllerProvider.notifier).loadConversations();
        },
      );
    }

    if (state.isEmpty) {
      return Center(
        child: Padding(
          padding: AppDimensions.screenPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.chat_bubble_outline_rounded,
                size: 56,
                color: theme.colorScheme.primary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: AppDimensions.space16),
              Text('No conversations yet', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppDimensions.space8),
              Text(
                'Start a new chat with IRA. History will appear here after conversations are saved.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () {
        return ref
            .read(conversationListControllerProvider.notifier)
            .loadConversations();
      },
      child: ListView.separated(
        padding: AppDimensions.screenPadding,
        itemCount: state.conversations.length,
        separatorBuilder: (_, __) =>
            const SizedBox(height: AppDimensions.space12),
        itemBuilder: (context, index) {
          final conversation = state.conversations[index];
          return IraCard(
            onTap: () => context.push(AppRoutes.chatPath(conversation.id)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conversation.title,
                  style: theme.textTheme.titleSmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat.yMMMd()
                      .add_jm()
                      .format(conversation.updatedAt.toLocal()),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
