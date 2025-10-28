import 'package:sync_event/features/chat/domain/repositories/chat_repository.dart';

class DeleteChatUseCase {
  final ChatRepository repository;

  DeleteChatUseCase(this.repository);

  Future<void> call(String chatId) {
    return repository.deleteChat(chatId);
  }
}