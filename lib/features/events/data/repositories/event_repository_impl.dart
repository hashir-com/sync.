
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:sync_event/core/error/failures.dart';
import 'package:sync_event/core/network/network_info.dart';
import 'package:sync_event/features/events/data/datasources/event_remote_datasource.dart';
import 'package:sync_event/features/events/data/models/event_model.dart';
import 'package:sync_event/features/events/domain/entities/event_entity.dart';
import 'package:sync_event/features/events/domain/repositories/event_repository.dart';

class EventRepositoryImpl implements EventRepository {
  final EventRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final FirebaseFirestore firebaseFirestore; // Add FirebaseFirestore dependency

  EventRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
    required this.firebaseFirestore, // Inject FirebaseFirestore
  });

  @override
  Future<Either<Failure, void>> createEvent(
    EventEntity event, {
    File? docFile,
    File? coverFile,
  }) async {
    if (!(await networkInfo.isConnected)) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final eventModel = EventModel(
        id: event.id,
        title: event.title,
        description: event.description,
        location: event.location,
        startTime: event.startTime,
        endTime: event.endTime,
        organizerId: event.organizerId,
        organizerName: event.organizerName,
        attendees: event.attendees,
        maxAttendees: event.maxAttendees,
        category: event.category,
        latitude: event.latitude,
        longitude: event.longitude,
        createdAt: event.createdAt,
        updatedAt: event.updatedAt,
        ticketPrice: event.ticketPrice,
        status: event.status,
        approvalReason: event.approvalReason,
        rejectionReason: event.rejectionReason,
        categoryCapacities: event.categoryCapacities,
        categoryPrices: event.categoryPrices,
        availableTickets: event.maxAttendees, // Initialize to maxAttendees
      );
      await remoteDataSource.createEvent(eventModel, docFile: docFile, coverFile: coverFile);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<EventEntity>>> getApprovedEvents() async {
    if (!(await networkInfo.isConnected)) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final events = await remoteDataSource.getApprovedEvents();
      return Right(events.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Stream<List<EventEntity>> getApprovedEventsStream() {
    return remoteDataSource.getApprovedEventsStream().map(
        (events) => events.map((model) => model.toEntity()).toList());
  }

  @override
  Future<Either<Failure, void>> joinEvent(String eventId, String userId) async {
    if (!(await networkInfo.isConnected)) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      await remoteDataSource.joinEvent(eventId, userId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Stream<List<EventEntity>> getUserEventsStream(String userId) {
    return remoteDataSource.getUserEventsStream(userId).map(
        (events) => events.map((model) => model.toEntity()).toList());
  }

  @override
  Future<Either<Failure, void>> updateEvent(
    EventEntity event, {
    File? docFile,
    File? coverFile,
  }) async {
    if (!(await networkInfo.isConnected)) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final eventModel = EventModel(
        id: event.id,
        title: event.title,
        description: event.description,
        location: event.location,
        startTime: event.startTime,
        endTime: event.endTime,
        organizerId: event.organizerId,
        organizerName: event.organizerName,
        attendees: event.attendees,
        maxAttendees: event.maxAttendees,
        category: event.category,
        latitude: event.latitude,
        longitude: event.longitude,
        createdAt: event.createdAt,
        updatedAt: event.updatedAt,
        ticketPrice: event.ticketPrice,
        status: event.status,
        approvalReason: event.approvalReason,
        rejectionReason: event.rejectionReason,
        categoryCapacities: event.categoryCapacities,
        categoryPrices: event.categoryPrices,
        availableTickets: event.availableTickets,
      );
      await remoteDataSource.updateEvent(eventModel, docFile: docFile, coverFile: coverFile);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteEvent(String eventId) async {
    if (!(await networkInfo.isConnected)) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      await remoteDataSource.deleteEvent(eventId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> approveEvent(String eventId, {required String approvedBy}) async {
    if (!(await networkInfo.isConnected)) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      await firebaseFirestore.collection('events').doc(eventId).update({
        'status': 'approved',
        'approvedBy': approvedBy,
        'approvalReason': FieldValue.serverTimestamp(),
      });
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<EventEntity>>> getPendingEvents() async {
    if (!(await networkInfo.isConnected)) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final query = await firebaseFirestore
          .collection('events')
          .where('status', isEqualTo: 'pending')
          .get();
      final events = query.docs.map((e) => EventModel.fromMap(e.data(), e.id).toEntity()).toList();
      return Right(events);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, EventEntity>> getEvent(String eventId) async {
    if (!(await networkInfo.isConnected)) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      final doc = await firebaseFirestore.collection('events').doc(eventId).get();
      if (!doc.exists) {
        return Left(ServerFailure(message: 'Event not found'));
      }
      return Right(EventModel.fromMap(doc.data()!, doc.id).toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateEventAvailability(String eventId, int ticketQuantity) async {
    if (!(await networkInfo.isConnected)) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
    try {
      await remoteDataSource.updateEventAvailability(eventId, ticketQuantity);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
