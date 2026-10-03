import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/router.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/ira_error_view.dart';
import '../../../../core/widgets/ira_loading_indicator.dart';
import '../../domain/entities/chat_message.dart';
import '../controllers/chat_controller.dart';
import '../controllers/chat_state.dart';
import '../controllers/conversation_list_controller.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;

  const ChatScreen({super.key, required this.conversationId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _inputController = TextEditingController();
  final _focusNode = FocusNode();

  void _openVoiceChat() {
    context.push(AppRoutes.voiceLive);
  }

  Future<void> _openConversationHistory() async {
    unawaited(
      ref.read(conversationListControllerProvider.notifier).loadConversations(),
    );

    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Consumer(
          builder: (context, ref, child) {
            final listState = ref.watch(conversationListControllerProvider);
            final conversations = listState.conversations;

            return Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.space16,
                AppDimensions.space8,
                AppDimensions.space16,
                AppDimensions.space16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Recent conversations',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        icon: const Icon(Icons.close_rounded),
                        tooltip: 'Close history',
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.space8),
                  if (listState.isLoading && conversations.isEmpty)
                    const SizedBox(
                      height: 120,
                      child: Center(child: IraLoadingIndicator(message: 'Loading history...')),
                    )
                  else if (listState.isError && conversations.isEmpty)
                    Text(
                      listState.failure?.message ?? 'Unable to load conversation history.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    )
                  else if (conversations.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppDimensions.space20),
                      child: Text(
                        'No saved chats yet. Start a new one to build your history.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    )
                  else
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: conversations.length,
                        separatorBuilder: (_, __) => const SizedBox(height: AppDimensions.space8),
                        itemBuilder: (context, index) {
                          final conversation = conversations[index];
                          final isActive = conversation.id == widget.conversationId;

                          return Material(
                            color: isActive
                                ? Theme.of(context).colorScheme.primaryContainer
                                : Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            child: ListTile(
                              leading: Icon(
                                isActive
                                    ? Icons.chat_bubble_rounded
                                    : Icons.chat_bubble_outline_rounded,
                                color: isActive
                                    ? Theme.of(context).colorScheme.primary
                                    : null,
                              ),
                              title: Text(
                                conversation.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              subtitle: Text(
                                DateFormat.yMMMd().add_jm().format(
                                  conversation.updatedAt.toLocal(),
                                ),
                              ),
                              trailing: isActive ? const Icon(Icons.check_rounded) : null,
                              onTap: () async {
                                Navigator.of(sheetContext).pop();
                                if (conversation.id == widget.conversationId) return;
                                if (!context.mounted) return;
                                context.pushReplacement(AppRoutes.chatPath(conversation.id));
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: AppDimensions.space12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () async {
                        final conversation = await ref
                            .read(conversationListControllerProvider.notifier)
                            .createConversation();
                        if (!context.mounted) return;
                        if (conversation == null) {
                          final failure = ref.read(conversationListControllerProvider).failure;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                failure?.message ?? 'Unable to start a new conversation.',
                              ),
                            ),
                          );
                          return;
                        }
                        if (Navigator.of(sheetContext).canPop()) {
                          Navigator.of(sheetContext).pop();
                        }
                        if (!context.mounted) return;
                        context.pushReplacement(AppRoutes.chatPath(conversation.id));
                      },
                      icon: const Icon(Icons.add_comment_outlined),
                      label: const Text('New chat'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(chatControllerProvider(widget.conversationId).notifier).loadMessages();
      ref.read(conversationListControllerProvider.notifier).loadConversations();
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _inputController.text;
    final sent = await ref
        .read(chatControllerProvider(widget.conversationId).notifier)
        .sendMessage(text);
    if (sent) {
      _inputController.clear();
      _focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(chatControllerProvider(widget.conversationId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('IRA Companion'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: 'Conversation history',
            onPressed: _openConversationHistory,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildMessages(theme, state)),
            if (state.isSending)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.space16,
                  vertical: AppDimensions.space8,
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: AppDimensions.space8),
                    Text(
                      'IRA is responding...',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            if (state.isError && state.failure != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.space16,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        state.failure!.message,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        ref
                            .read(
                              chatControllerProvider(widget.conversationId)
                                  .notifier,
                            )
                            .retryLastFailed();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            _Composer(
              controller: _inputController,
              focusNode: _focusNode,
              enabled: !state.isSending,
              onSend: _send,
              onOpenVoice: _openVoiceChat,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessages(ThemeData theme, ChatState state) {
    if (state.isLoadingMessages && state.messages.isEmpty) {
      return const IraLoadingIndicator(message: 'Loading conversation...');
    }

    if (state.isError && state.messages.isEmpty) {
      return IraErrorView(
        title: 'Unable to load conversation',
        message: state.failure?.message ?? 'This conversation could not be opened.',
        onRetry: () {
          ref
              .read(chatControllerProvider(widget.conversationId).notifier)
              .loadMessages();
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
                Icons.spa_outlined,
                size: 48,
                color: theme.colorScheme.primary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: AppDimensions.space12),
              Text(
                'This conversation is empty',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: AppDimensions.space8),
              Text(
                'Send a message to begin. IRA will reply using the configured AI provider.',
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

    final items = state.messages.reversed.toList();
    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space16,
        vertical: AppDimensions.space12,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _MessageBubble(message: items[index]);
      },
    );
  }
}

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool enabled;
  final VoidCallback onSend;
  final VoidCallback onOpenVoice;

  const _Composer({
    required this.controller,
    required this.focusNode,
    required this.enabled,
    required this.onSend,
    required this.onOpenVoice,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.space12,
        AppDimensions.space8,
        AppDimensions.space12,
        AppDimensions.space12,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              enabled: enabled,
              minLines: 1,
              maxLines: 5,
              textInputAction: TextInputAction.send,
              onSubmitted: enabled ? (_) => onSend() : null,
              decoration: InputDecoration(
                hintText: 'Message IRA',
                filled: true,
                fillColor: theme.colorScheme.surface,
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.space8),
          IconButton.filled(
            onPressed: enabled ? onOpenVoice : null,
            icon: const Icon(Icons.mic_rounded),
            tooltip: 'Open live voice chat',
          ),
          const SizedBox(width: AppDimensions.space8),
          IconButton.filled(
            onPressed: enabled ? onSend : null,
            icon: const Icon(Icons.send_rounded),
            tooltip: 'Send',
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = message.isUser;
    final alignment = isUser ? Alignment.centerRight : Alignment.centerLeft;
    final color = isUser
        ? theme.colorScheme.primary
        : theme.colorScheme.surfaceContainerHighest;
    final textColor = isUser ? Colors.white : theme.colorScheme.onSurface;

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space12,
            vertical: AppDimensions.space8,
          ),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          ),
          child: Text(
            message.content,
            style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
          ),
        ),
      ),
    );
  }
}
