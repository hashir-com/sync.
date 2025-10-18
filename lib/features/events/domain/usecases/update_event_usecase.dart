import 'dart:io';
import '../entities/event_entity.dart';
import '../repositories/event_repository.dart';

class UpdateEventUseCase {
  final EventRepository repository;

  UpdateEventUseCase(this.repository);

  Future<void> call(
    EventEntity event, {
    File? docFile,
    File? coverFile,
  }) {
    return repository.updateEvent(
      event,
      docFile: docFile,
      coverFile: coverFile,
    );
  }
}