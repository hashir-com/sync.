import '../entities/event_entity.dart';
import '../repositories/event_repository.dart';

class GetApprovedEventsUseCase {
  final EventRepository repository;

  GetApprovedEventsUseCase(this.repository);

  /// Returns a stream of all approved events (visible to users)
  Stream<List<EventEntity>> call() {
    return repository.getApprovedEventsStream();
  }
}