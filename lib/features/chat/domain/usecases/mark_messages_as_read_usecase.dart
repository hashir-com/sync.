import 'package:sync_event/features/chat/domain/repositories/chat_repository.dart';

class MarkMessagesAsReadUseCase {
  final ChatRepository repository;

  MarkMessagesAsReadUseCase(this.repository);

  Future<void> call(String chatId) {
    return repository.markMessagesAsRead(chatId);
  }
}