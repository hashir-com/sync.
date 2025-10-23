import 'package:sync_event/features/chat/domain/entities/message_entity.dart';
import 'package:sync_event/features/chat/domain/repositories/chat_repository.dart';

class GetChatMessagesUseCase {
  final ChatRepository repository;

  GetChatMessagesUseCase(this.repository);

  Stream<List<MessageEntity>> call(String chatId) {
    return repository.getChatMessages(chatId);
  }
}