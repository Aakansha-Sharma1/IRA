import 'package:equatable/equatable.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/chat_message.dart';

enum ChatStatus {
  initial,
  loadingMessages,
  messagesLoaded,
  sending,
  sent,
  error,
}

class ChatState extends Equatable {
  final ChatStatus status;
  final List<ChatMessage> messages;
  final Failure? failure;
  final String? lastFailedContent;

  const ChatState({
    this.status = ChatStatus.initial,
    this.messages = const [],
    this.failure,
    this.lastFailedContent,
  });

  const ChatState.initial() : this(status: ChatStatus.initial);

  const ChatState.loadingMessages({List<ChatMessage> messages = const []})
      : this(status: ChatStatus.loadingMessages, messages: messages);

  const ChatState.messagesLoaded(List<ChatMessage> messages)
      : this(status: ChatStatus.messagesLoaded, messages: messages);

  const ChatState.sending(List<ChatMessage> messages)
      : this(status: ChatStatus.sending, messages: messages);

  const ChatState.sent(List<ChatMessage> messages)
      : this(status: ChatStatus.sent, messages: messages);

  const ChatState.error(
    Failure failure, {
    List<ChatMessage> messages = const [],
    String? lastFailedContent,
  }) : this(
          status: ChatStatus.error,
          failure: failure,
          messages: messages,
          lastFailedContent: lastFailedContent,
        );

  bool get isInitial => status == ChatStatus.initial;
  bool get isLoadingMessages => status == ChatStatus.loadingMessages;
  bool get isMessagesLoaded =>
      status == ChatStatus.messagesLoaded || status == ChatStatus.sent;
  bool get isSending => status == ChatStatus.sending;
  bool get isError => status == ChatStatus.error;
  bool get isEmpty => isMessagesLoaded && messages.isEmpty && !isSending;

  @override
  List<Object?> get props => [status, messages, failure, lastFailedContent];
}
