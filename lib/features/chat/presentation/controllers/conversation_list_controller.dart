import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/logger.dart';
import '../../data/datasources/conversation_remote_data_source.dart';
import '../../data/repositories/conversation_repository_impl.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/repositories/conversation_repository.dart';
import 'conversation_list_state.dart';

final conversationRemoteDataSourceProvider =
    Provider<ConversationRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ConversationRemoteDataSourceImpl(apiClient: apiClient);
});

final conversationRepositoryProvider = Provider<ConversationRepository>((ref) {
  final remoteDataSource = ref.watch(conversationRemoteDataSourceProvider);
  return ConversationRepositoryImpl(remoteDataSource: remoteDataSource);
});

class ConversationListController extends StateNotifier<ConversationListState> {
  final ConversationRepository _repository;

  ConversationListController(this._repository)
      : super(const ConversationListState.initial());

  Future<void> loadConversations() async {
    state = ConversationListState.loading(conversations: state.conversations);
    try {
      final conversations = await _repository.listConversations();
      state = ConversationListState.loaded(conversations);
    } on AppException catch (e) {
      AppLogger.error('Failed to load conversations', e);
      state = ConversationListState.error(
        _mapFailure(e),
        conversations: state.conversations,
      );
    } catch (e, st) {
      AppLogger.error('Unexpected error loading conversations', e, st);
      state = ConversationListState.error(
        const ServerFailure(message: 'Unable to load conversations.'),
        conversations: state.conversations,
      );
    }
  }

  Future<Conversation?> createConversation() async {
    state = ConversationListState.creating(state.conversations);
    try {
      final conversation = await _repository.createConversation();
      final conversations = [conversation, ...state.conversations];
      state = ConversationListState.loaded(conversations);
      return conversation;
    } on AppException catch (e) {
      AppLogger.error('Failed to create conversation', e);
      state = ConversationListState.error(
        _mapFailure(e),
        conversations: state.conversations,
      );
      return null;
    } catch (e, st) {
      AppLogger.error('Unexpected error creating conversation', e, st);
      state = ConversationListState.error(
        const ServerFailure(message: 'Unable to start a new conversation.'),
        conversations: state.conversations,
      );
      return null;
    }
  }

  void clear() {
    state = const ConversationListState.initial();
  }
}

Failure _mapFailure(AppException exception) {
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

final conversationListControllerProvider =
    StateNotifierProvider<ConversationListController, ConversationListState>(
  (ref) {
    final repository = ref.watch(conversationRepositoryProvider);
    return ConversationListController(repository);
  },
);
