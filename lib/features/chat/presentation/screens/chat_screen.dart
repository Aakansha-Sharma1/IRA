import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/ira_error_view.dart';
import '../../../../core/widgets/ira_loading_indicator.dart';
import '../../domain/entities/chat_message.dart';
import '../controllers/chat_controller.dart';
import '../controllers/chat_state.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;

  const ChatScreen({super.key, required this.conversationId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _inputController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(chatControllerProvider(widget.conversationId).notifier).loadMessages();
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

  const _Composer({
    required this.controller,
    required this.focusNode,
    required this.enabled,
    required this.onSend,
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
