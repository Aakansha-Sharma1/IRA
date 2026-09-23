import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/repositories/conversation_repository.dart';
import 'chat_state.dart';
import 'conversation_list_controller.dart';

class ChatController extends StateNotifier<ChatState> {
  final ConversationRepository _repository;
  final String conversationId;
  final void Function()? _onConversationUpdated;

  ChatController(
    this._repository, {
    required this.conversationId,
    void Function()? onConversationUpdated,
  })  : _onConversationUpdated = onConversationUpdated,
        super(const ChatState.initial());

  Future<void> loadMessages() async {
    state = ChatState.loadingMessages(messages: state.messages);
    try {
      final messages = await _repository.getMessages(conversationId);
      state = ChatState.messagesLoaded(messages);
    } on AppException catch (e) {
      AppLogger.error('Failed to load messages', e);
      state = ChatState.error(
        _mapChatFailure(e),
        messages: state.messages,
      );
    } catch (e, st) {
      AppLogger.error('Unexpected error loading messages', e, st);
      state = ChatState.error(
        const ServerFailure(message: 'Unable to load this conversation.'),
        messages: state.messages,
      );
    }
  }

  Future<bool> sendMessage(String content) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty) {
      state = ChatState.error(
        const ValidationFailure(message: 'Message cannot be empty.'),
        messages: state.messages,
      );
      return false;
    }

    state = ChatState.sending(state.messages);
    try {
      final result = await _repository.sendMessage(
        conversationId: conversationId,
        content: trimmed,
      );
      state = ChatState.sent([
        ...state.messages,
        result.userMessage,
        result.assistantMessage,
      ]);
      _onConversationUpdated?.call();
      return true;
    } on AppException catch (e) {
      AppLogger.error('Failed to send message', e);
      await _refreshAfterSendFailure();
      state = ChatState.error(
        _mapChatFailure(e),
        messages: state.messages,
        lastFailedContent: trimmed,
      );
      return false;
    } catch (e, st) {
      AppLogger.error('Unexpected error sending message', e, st);
      await _refreshAfterSendFailure();
      state = ChatState.error(
        const ServerFailure(message: 'Unable to send this message.'),
        messages: state.messages,
        lastFailedContent: trimmed,
      );
      return false;
    }
  }

  Future<bool> retryLastFailed() async {
    final content = state.lastFailedContent;
    if (content == null || content.trim().isEmpty) return false;
    return sendMessage(content);
  }

  Future<void> _refreshAfterSendFailure() async {
    try {
      final messages = await _repository.getMessages(conversationId);
      state = ChatState.messagesLoaded(messages);
    } catch (_) {
      // Keep current messages if refresh fails; caller still sets error.
    }
  }

  void clear() {
    state = const ChatState.initial();
  }
}

Failure _mapChatFailure(AppException exception) {
  if (exception is NetworkException) {
    return NetworkFailure(message: exception.message);
  }
  if (exception is TimeoutException) {
    return TimeoutFailure(message: exception.message);
  }
  if (exception is AuthException) {
    return AuthFailure(message: exception.message);
  }
  if (exception is ValidationException) {
    return ValidationFailure(message: exception.message);
  }
  if (exception is ServerException) {
    return ServerFailure(message: exception.message);
  }
  return UnknownFailure(message: exception.message);
}

final chatControllerProvider =
    StateNotifierProvider.family<ChatController, ChatState, String>(
  (ref, conversationId) {
    final repository = ref.watch(conversationRepositoryProvider);
    return ChatController(
      repository,
      conversationId: conversationId,
      onConversationUpdated: () {
        ref.read(conversationListControllerProvider.notifier).loadConversations();
      },
    );
  },
);
