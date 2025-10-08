import '../entities/event_entity.dart';
import '../repositories/event_repository.dart';

class GetApprovedEventsUseCase {
  final EventRepository repository;

  GetApprovedEventsUseCase(this.repository);

  /// Returns a list of all approved events (visible to users)
  Future<List<EventEntity>> call() {
    return repository.getApprovedEvents();
  }
}
