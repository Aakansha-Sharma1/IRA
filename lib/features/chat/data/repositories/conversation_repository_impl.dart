import '../../domain/entities/chat_message.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/repositories/conversation_repository.dart';
import '../datasources/conversation_remote_data_source.dart';

class ConversationRepositoryImpl implements ConversationRepository {
  final ConversationRemoteDataSource remoteDataSource;

  ConversationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Conversation>> listConversations() async {
    final models = await remoteDataSource.listConversations();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Conversation> createConversation({String? title}) async {
    final model = await remoteDataSource.createConversation(title: title);
    return model.toEntity();
  }

  @override
  Future<Conversation> getConversation(String conversationId) async {
    final model = await remoteDataSource.getConversation(conversationId);
    return model.toEntity();
  }

  @override
  Future<List<ChatMessage>> getMessages(String conversationId) async {
    final models = await remoteDataSource.getMessages(conversationId);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<SendMessageResult> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    final dto = await remoteDataSource.sendMessage(
      conversationId: conversationId,
      content: content,
    );
    return SendMessageResult(
      userMessage: dto.userMessage.toEntity(),
      assistantMessage: dto.assistantMessage.toEntity(),
    );
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    await remoteDataSource.deleteConversation(conversationId);
  }
}
