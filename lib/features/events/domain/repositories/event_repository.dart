import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:sync_event/core/error/failures.dart';
import '../entities/event_entity.dart';

abstract class EventRepository {
  Future<Either<Failure, void>> createEvent(EventEntity event, {File? docFile, File? coverFile});
  Future<Either<Failure, void>> approveEvent(String eventId, {required String approvedBy});
  Future<Either<Failure, List<EventEntity>>> getApprovedEvents();
  Future<Either<Failure, List<EventEntity>>> getPendingEvents();
  Future<Either<Failure, void>> joinEvent(String eventId, String userId);
  Stream<List<EventEntity>> getApprovedEventsStream();
  Stream<List<EventEntity>> getUserEventsStream(String userId);
  Future<Either<Failure, void>> updateEvent(EventEntity event, {File? docFile, File? coverFile});
  Future<Either<Failure, void>> deleteEvent(String eventId);
  Future<Either<Failure, EventEntity>> getEvent(String eventId);
  Future<Either<Failure, void>> updateEventAvailability(String eventId, int ticketQuantity);
}