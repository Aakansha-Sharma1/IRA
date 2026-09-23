import 'package:equatable/equatable.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/conversation.dart';

enum ConversationListStatus {
  initial,
  loading,
  loaded,
  creating,
  error,
}

class ConversationListState extends Equatable {
  final ConversationListStatus status;
  final List<Conversation> conversations;
  final Failure? failure;

  const ConversationListState({
    this.status = ConversationListStatus.initial,
    this.conversations = const [],
    this.failure,
  });

  const ConversationListState.initial()
      : this(status: ConversationListStatus.initial);

  const ConversationListState.loading({
    List<Conversation> conversations = const [],
  }) : this(
          status: ConversationListStatus.loading,
          conversations: conversations,
        );

  const ConversationListState.loaded(List<Conversation> conversations)
      : this(
          status: ConversationListStatus.loaded,
          conversations: conversations,
        );

  const ConversationListState.creating(List<Conversation> conversations)
      : this(
          status: ConversationListStatus.creating,
          conversations: conversations,
        );

  const ConversationListState.error(
    Failure failure, {
    List<Conversation> conversations = const [],
  }) : this(
          status: ConversationListStatus.error,
          failure: failure,
          conversations: conversations,
        );

  bool get isInitial => status == ConversationListStatus.initial;
  bool get isLoading => status == ConversationListStatus.loading;
  bool get isLoaded => status == ConversationListStatus.loaded;
  bool get isCreating => status == ConversationListStatus.creating;
  bool get isError => status == ConversationListStatus.error;
  bool get isEmpty => isLoaded && conversations.isEmpty;

  @override
  List<Object?> get props => [status, conversations, failure];
}
