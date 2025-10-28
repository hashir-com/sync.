import 'package:sync_event/features/chat/domain/repositories/chat_repository.dart';

class UpdateOnlineStatusUseCase {
  final ChatRepository repository;

  UpdateOnlineStatusUseCase(this.repository);

  Future<void> call(bool isOnline) {
    return repository.updateOnlineStatus(isOnline);
  }
}