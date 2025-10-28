import 'package:sync_event/features/chat/domain/entities/chat_user_entity.dart';
import 'package:sync_event/features/chat/domain/repositories/chat_repository.dart';

class SearchUsersUseCase {
  final ChatRepository repository;

  SearchUsersUseCase(this.repository);

  Future<List<ChatUserEntity>> call(String query) {
    return repository.searchUsers(query);
  }
}