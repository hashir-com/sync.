import 'package:sync_event/features/chat/domain/entities/chat_entity.dart';
import 'package:sync_event/features/chat/domain/repositories/chat_repository.dart';

class GetUserChatsUseCase {
  final ChatRepository repository;

  GetUserChatsUseCase(this.repository);

  Stream<List<ChatEntity>> call() {
    return repository.getUserChats();
  }
}