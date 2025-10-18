import '../entities/event_entity.dart';
import '../repositories/event_repository.dart';

class GetUserEventsUseCase {
  final EventRepository repository;

  GetUserEventsUseCase(this.repository);

  Stream<List<EventEntity>> call(String userId) {
    return repository.getUserEventsStream(userId);
  }
}