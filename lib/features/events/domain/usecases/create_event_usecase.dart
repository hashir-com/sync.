import '../../domain/entities/event_entity.dart';
import '../repositories/event_repository.dart';
import 'dart:io';

class CreateEventUseCase {
  final EventRepository repository;

  CreateEventUseCase(this.repository);

  // Creates a new event (saved as pending)
  Future<void> call(EventEntity event, {File? docFile, File? coverFile}) {
    return repository.createEvent(
      event,
      docFile: docFile,
      coverFile: coverFile,
    );
  }
}
