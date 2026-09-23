import 'package:flutter_test/flutter_test.dart';
import 'package:ira_app/core/errors/exceptions.dart';
import 'package:ira_app/features/chat/domain/entities/chat_message.dart';
import 'package:ira_app/features/chat/domain/entities/conversation.dart';
import 'package:ira_app/features/chat/domain/repositories/conversation_repository.dart';
import 'package:ira_app/features/chat/presentation/controllers/chat_controller.dart';
import 'package:ira_app/features/chat/presentation/controllers/chat_state.dart';
import 'package:ira_app/features/chat/presentation/controllers/conversation_list_controller.dart';
import 'package:ira_app/features/chat/presentation/controllers/conversation_list_state.dart';
import 'package:mocktail/mocktail.dart';

class MockConversationRepository extends Mock implements ConversationRepository {}

void main() {
  late MockConversationRepository repository;

  final conversation = Conversation(
    id: 'conv-1',
    title: 'New conversation',
    createdAt: DateTime.utc(2026, 9, 23, 10),
    updatedAt: DateTime.utc(2026, 9, 23, 10),
  );

  final userMessage = ChatMessage(
    id: 'm1',
    conversationId: 'conv-1',
    role: MessageRole.user,
    content: 'Hello IRA',
    createdAt: DateTime.utc(2026, 9, 23, 10, 1),
  );

  final assistantMessage = ChatMessage(
    id: 'm2',
    conversationId: 'conv-1',
    role: MessageRole.assistant,
    content: 'Hello, I am here.',
    createdAt: DateTime.utc(2026, 9, 23, 10, 2),
  );

  setUp(() {
    repository = MockConversationRepository();
  });

  group('ConversationListController', () {
    test('loading conversations transitions to loaded', () async {
      when(() => repository.listConversations())
          .thenAnswer((_) async => [conversation]);

      final controller = ConversationListController(repository);
      expect(controller.state.isInitial, isTrue);

      await controller.loadConversations();

      expect(controller.state.status, ConversationListStatus.loaded);
      expect(controller.state.conversations, [conversation]);
    });

    test('empty list is a genuine empty loaded state', () async {
      when(() => repository.listConversations()).thenAnswer((_) async => []);

      final controller = ConversationListController(repository);
      await controller.loadConversations();

      expect(controller.state.isEmpty, isTrue);
      expect(controller.state.conversations, isEmpty);
    });

    test('load failure sets error state', () async {
      when(() => repository.listConversations()).thenThrow(
        const NetworkException(message: 'No internet connection or server unreachable.'),
      );

      final controller = ConversationListController(repository);
      await controller.loadConversations();

      expect(controller.state.isError, isTrue);
      expect(
        controller.state.failure?.message,
        'No internet connection or server unreachable.',
      );
    });

    test('create conversation uses repository-generated id', () async {
      when(() => repository.createConversation(title: any(named: 'title')))
          .thenAnswer((_) async => conversation);
      when(() => repository.listConversations()).thenAnswer((_) async => []);

      final controller = ConversationListController(repository);
      final created = await controller.createConversation();

      expect(created?.id, 'conv-1');
      expect(controller.state.conversations.first.id, 'conv-1');
    });

    test('clear resets protected conversation list state', () async {
      when(() => repository.listConversations())
          .thenAnswer((_) async => [conversation]);
      final controller = ConversationListController(repository);
      await controller.loadConversations();

      controller.clear();

      expect(controller.state.isInitial, isTrue);
      expect(controller.state.conversations, isEmpty);
    });
  });

  group('ChatController', () {
    test('loadMessages transitions through loading then loaded', () async {
      when(() => repository.getMessages('conv-1')).thenAnswer((_) async => []);
      final controller = ChatController(repository, conversationId: 'conv-1');

      expect(controller.state.isInitial, isTrue);
      final future = controller.loadMessages();
      expect(controller.state.isLoadingMessages, isTrue);
      await future;

      expect(controller.state.status, ChatStatus.messagesLoaded);
      expect(controller.state.isEmpty, isTrue);
    });

    test('sending state then sent with persisted messages', () async {
      when(() => repository.getMessages('conv-1')).thenAnswer((_) async => []);
      when(() => repository.sendMessage(
            conversationId: 'conv-1',
            content: 'Hello IRA',
          )).thenAnswer(
        (_) async => SendMessageResult(
          userMessage: userMessage,
          assistantMessage: assistantMessage,
        ),
      );

      final controller = ChatController(repository, conversationId: 'conv-1');
      await controller.loadMessages();

      final sendFuture = controller.sendMessage('Hello IRA');
      expect(controller.state.isSending, isTrue);
      final result = await sendFuture;

      expect(result, isTrue);
      expect(controller.state.status, ChatStatus.sent);
      expect(controller.state.messages, [userMessage, assistantMessage]);
    });

    test('send error sets error state and does not invent an assistant message', () async {
      when(() => repository.getMessages('conv-1')).thenAnswer((_) async => []);
      when(() => repository.sendMessage(
            conversationId: 'conv-1',
            content: 'Hello IRA',
          )).thenThrow(
        const ServerException(message: 'The AI provider returned an error.'),
      );

      final controller = ChatController(repository, conversationId: 'conv-1');
      await controller.loadMessages();
      final result = await controller.sendMessage('Hello IRA');

      expect(result, isFalse);
      expect(controller.state.isError, isTrue);
      expect(controller.state.lastFailedContent, 'Hello IRA');
      expect(
        controller.state.messages.any((m) => m.role == MessageRole.assistant),
        isFalse,
      );
    });

    test('empty message is a validation error', () async {
      final controller = ChatController(repository, conversationId: 'conv-1');
      final result = await controller.sendMessage('   ');
      expect(result, isFalse);
      expect(controller.state.isError, isTrue);
      verifyNever(() => repository.sendMessage(
            conversationId: any(named: 'conversationId'),
            content: any(named: 'content'),
          ));
    });

    test('clear resets chat state', () async {
      when(() => repository.getMessages('conv-1'))
          .thenAnswer((_) async => [userMessage]);
      final controller = ChatController(repository, conversationId: 'conv-1');
      await controller.loadMessages();
      controller.clear();
      expect(controller.state.isInitial, isTrue);
      expect(controller.state.messages, isEmpty);
    });
  });
}
