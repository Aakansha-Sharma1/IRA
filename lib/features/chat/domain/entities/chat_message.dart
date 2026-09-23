import 'package:equatable/equatable.dart';

enum MessageRole { user, assistant, system }

class ChatMessage extends Equatable {
  final String id;
  final String conversationId;
  final MessageRole role;
  final String content;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    required this.createdAt,
  });

  bool get isUser => role == MessageRole.user;
  bool get isAssistant => role == MessageRole.assistant;

  @override
  List<Object?> get props => [id, conversationId, role, content, createdAt];
}

MessageRole messageRoleFromString(String value) {
  switch (value.toLowerCase()) {
    case 'assistant':
      return MessageRole.assistant;
    case 'system':
      return MessageRole.system;
    case 'user':
    default:
      return MessageRole.user;
  }
}

String messageRoleToString(MessageRole role) {
  switch (role) {
    case MessageRole.assistant:
      return 'assistant';
    case MessageRole.system:
      return 'system';
    case MessageRole.user:
      return 'user';
  }
}
