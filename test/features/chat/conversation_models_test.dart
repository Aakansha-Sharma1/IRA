import 'package:flutter_test/flutter_test.dart';
import 'package:ira_app/features/chat/data/models/chat_message_model.dart';
import 'package:ira_app/features/chat/data/models/conversation_model.dart';
import 'package:ira_app/features/chat/domain/entities/chat_message.dart';

void main() {
  group('ConversationModel serialization', () {
    test('fromJson and toJson round-trip persisted conversation fields', () {
      final json = {
        'id': 'conv-123',
        'title': 'Wind down tonight',
        'created_at': '2026-09-23T10:00:00.000Z',
        'updated_at': '2026-09-23T11:00:00.000Z',
      };

      final model = ConversationModel.fromJson(json);
      expect(model.id, 'conv-123');
      expect(model.title, 'Wind down tonight');
      expect(model.createdAt.isUtc, isTrue);

      final encoded = model.toJson();
      expect(encoded['id'], 'conv-123');
      expect(encoded['title'], 'Wind down tonight');
      expect(encoded['created_at'], isNotEmpty);
    });
  });

  group('ChatMessageModel serialization', () {
    test('fromJson maps roles and content from the API payload', () {
      final json = {
        'id': 'msg-1',
        'conversation_id': 'conv-123',
        'role': 'assistant',
        'content': 'A persisted assistant reply',
        'created_at': '2026-09-23T10:01:00.000Z',
      };

      final model = ChatMessageModel.fromJson(json);
      expect(model.id, 'msg-1');
      expect(model.conversationId, 'conv-123');
      expect(model.role, MessageRole.assistant);
      expect(model.content, 'A persisted assistant reply');

      final encoded = model.toJson();
      expect(encoded['role'], 'assistant');
      expect(encoded['conversation_id'], 'conv-123');
    });

    test('unknown roles default to user', () {
      final model = ChatMessageModel.fromJson({
        'id': 'msg-2',
        'conversation_id': 'conv-123',
        'role': 'unknown',
        'content': 'hello',
        'created_at': '2026-09-23T10:01:00.000Z',
      });
      expect(model.role, MessageRole.user);
    });
  });
}
