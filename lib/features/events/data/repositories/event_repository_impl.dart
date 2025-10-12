import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sync_event/features/events/data/datasources/event_remote_datasource.dart';
import '../../domain/entities/event_entity.dart';
import '../../domain/repositories/event_repository.dart';
import '../models/event_model.dart';

class EventRepositoryImpl implements EventRepository {
  final EventRemoteDataSource remoteDataSource;

  EventRepositoryImpl({
    required this.remoteDataSource,
    required Object networkInfo,
    required Object localDataSource,
  });

  @override
  Future<void> createEvent(
    EventEntity event, {
    File? docFile,
    File? coverFile,
  }) async {
    final docRef = FirebaseFirestore.instance.collection('events').doc();
    final eventModel = EventModel(
      id: docRef.id,
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
      imageUrl: event.imageUrl,
      documentUrl: event.documentUrl,
      status: event.status,
      approvalReason: event.approvalReason,
      rejectionReason: event.rejectionReason,
      categoryCapacities: event.categoryCapacities,
      categoryPrices: event.categoryPrices,
    );

    return remoteDataSource.createEvent(
      eventModel,
      docFile: docFile,
      coverFile: coverFile,
    );
  }

  @override
  Future<List<EventEntity>> getApprovedEvents() async {
    final events = await remoteDataSource.getApprovedEvents();
    return events;
  }

  @override
  Stream<List<EventEntity>> getApprovedEventsStream() {
    return remoteDataSource.getApprovedEventsStream();
  }

  @override
  Future<void> joinEvent(String eventId, String userId) async {
    await remoteDataSource.joinEvent(eventId, userId);
  }

  @override
  Stream<List<EventEntity>> getUserEventsStream(String userId) {
    return remoteDataSource.getUserEventsStream(userId);
  }

  @override
  Future<void> updateEvent(
    EventEntity event, {
    File? docFile,
    File? coverFile,
  }) async {
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
      imageUrl: event.imageUrl,
      documentUrl: event.documentUrl,
      status: event.status,
      approvalReason: event.approvalReason,
      rejectionReason: event.rejectionReason,
    );

    return remoteDataSource.updateEvent(
      eventModel,
      docFile: docFile,
      coverFile: coverFile,
    );
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    await remoteDataSource.deleteEvent(eventId);
  }

  @override
  Future<void> approveEvent(String eventId, {required String approvedBy}) {
    throw UnimplementedError();
  }

  @override
  Future<List<EventEntity>> getPendingEvents() {
    throw UnimplementedError();
  }
}
