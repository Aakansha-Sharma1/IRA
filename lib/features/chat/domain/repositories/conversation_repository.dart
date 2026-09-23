import '../entities/chat_message.dart';
import '../entities/conversation.dart';

class SendMessageResult {
  final ChatMessage userMessage;
  final ChatMessage assistantMessage;

  const SendMessageResult({
    required this.userMessage,
    required this.assistantMessage,
  });
}

abstract class ConversationRepository {
  Future<List<Conversation>> listConversations();

  Future<Conversation> createConversation({String? title});

  Future<Conversation> getConversation(String conversationId);

  Future<List<ChatMessage>> getMessages(String conversationId);

  Future<SendMessageResult> sendMessage({
    required String conversationId,
    required String content,
  });

  Future<void> deleteConversation(String conversationId);
}
