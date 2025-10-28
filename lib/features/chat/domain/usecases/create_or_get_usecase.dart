import 'package:sync_event/features/chat/domain/repositories/chat_repository.dart';

class CreateOrGetChatUseCase {
  final ChatRepository repository;

  CreateOrGetChatUseCase(this.repository);

  Future<String> call(String otherUserId) {
    return repository.createOrGetChat(otherUserId);
  }
}