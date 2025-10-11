import '../repositories/event_repository.dart';

class DeleteEventUseCase {
  final EventRepository repository;

  DeleteEventUseCase(this.repository);

  Future<void> call(String eventId) {
    return repository.deleteEvent(eventId);
  }
}