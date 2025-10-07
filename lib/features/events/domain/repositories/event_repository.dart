import 'package:dartz/dartz.dart';
import 'package:sync_event/core/error/failures.dart';
import 'package:sync_event/features/events/domain/entities/event_entity.dart';

abstract class EventRepository {
  Future<Either<Failure, List<EventEntity>>> getEvents();
  Future<Either<Failure, EventEntity>> getEventById(String eventId);
  Future<Either<Failure, String>> createEvent(Map<String, dynamic> eventData);
  Future<Either<Failure, EventEntity>> updateEvent(
    String eventId,
    Map<String, dynamic> eventData,
  );
  Future<Either<Failure, void>> deleteEvent(String eventId);
  Future<Either<Failure, void>> joinEvent(String eventId, String userId);
  Future<Either<Failure, void>> leaveEvent(String eventId, String userId);
  Future<Either<Failure, String>> uploadEventImage(
    String eventId,
    String imagePath,
  );
}
