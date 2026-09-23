import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/chat_message_model.dart';
import '../models/conversation_model.dart';

class SendMessageDto {
  final ChatMessageModel userMessage;
  final ChatMessageModel assistantMessage;

  const SendMessageDto({
    required this.userMessage,
    required this.assistantMessage,
  });
}

abstract class ConversationRemoteDataSource {
  Future<List<ConversationModel>> listConversations();
  Future<ConversationModel> createConversation({String? title});
  Future<ConversationModel> getConversation(String conversationId);
  Future<List<ChatMessageModel>> getMessages(String conversationId);
  Future<SendMessageDto> sendMessage({
    required String conversationId,
    required String content,
  });
  Future<void> deleteConversation(String conversationId);
}

class ConversationRemoteDataSourceImpl implements ConversationRemoteDataSource {
  final ApiClient apiClient;

  ConversationRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<ConversationModel>> listConversations() async {
    final response = await apiClient.get<dynamic>(ApiEndpoints.conversations);
    final data = response.data;
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(ConversationModel.fromJson)
          .toList();
    }
    return const [];
  }

  @override
  Future<ConversationModel> createConversation({String? title}) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.conversations,
      data: {
        if (title != null && title.trim().isNotEmpty) 'title': title.trim(),
      },
    );
    return ConversationModel.fromJson(response.data!);
  }

  @override
  Future<ConversationModel> getConversation(String conversationId) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.conversation(conversationId),
    );
    return ConversationModel.fromJson(response.data!);
  }

  @override
  Future<List<ChatMessageModel>> getMessages(String conversationId) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.conversation(conversationId),
    );
    final messages = response.data?['messages'];
    if (messages is List) {
      return messages
          .whereType<Map<String, dynamic>>()
          .map(ChatMessageModel.fromJson)
          .toList();
    }
    return const [];
  }

  @override
  Future<SendMessageDto> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.conversationMessages(conversationId),
      data: {'content': content},
      options: Options(
        receiveTimeout: const Duration(seconds: 90),
        sendTimeout: const Duration(seconds: 30),
      ),
    );
    final data = response.data!;
    return SendMessageDto(
      userMessage: ChatMessageModel.fromJson(
        data['user_message'] as Map<String, dynamic>,
      ),
      assistantMessage: ChatMessageModel.fromJson(
        data['assistant_message'] as Map<String, dynamic>,
      ),
    );
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    await apiClient.delete<void>(ApiEndpoints.conversation(conversationId));
  }
}
