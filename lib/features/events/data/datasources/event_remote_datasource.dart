import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/event_model.dart';

abstract class EventRemoteDataSource {
  Future<void> createEvent(EventModel event, {File? docFile, File? coverFile});
  Future<List<EventModel>> getApprovedEvents();

  /// Add a user to event attendees
  Future<void> joinEvent(String eventId, String userId);
}

class EventRemoteDataSourceImpl implements EventRemoteDataSource {
  final FirebaseFirestore firebaseFirestore;
  final FirebaseStorage firebaseStorage;

  EventRemoteDataSourceImpl({
    required this.firebaseFirestore,
    required this.firebaseStorage,
  });

  @override
  Future<void> createEvent(
    EventModel event, {
    File? docFile,
    File? coverFile,
  }) async {
    final docRef = firebaseFirestore.collection('events').doc();
    await docRef.set(event.toMap());

    String? docUrl;
    String? imageUrl;

    // Upload document
    if (docFile != null) {
      final docSnapshot = await firebaseStorage
          .ref('event_docs/${docRef.id}/document.pdf')
          .putFile(docFile);
      docUrl = await docSnapshot.ref.getDownloadURL();
    }

    // Upload cover image
    if (coverFile != null) {
      final imgSnapshot = await firebaseStorage
          .ref('event_covers/${docRef.id}/cover.jpg')
          .putFile(coverFile);
      imageUrl = await imgSnapshot.ref.getDownloadURL();
    }

    final model = EventModel(
      id: docRef.id,
      title: event.title,
      description: event.description,
      location: event.location,
      startTime: event.startTime,
      endTime: event.endTime,
      imageUrl: imageUrl,
      documentUrl: docUrl,
      organizerId: event.organizerId,
      organizerName: event.organizerName,
      attendees: event.attendees,
      maxAttendees: event.maxAttendees,
      category: event.category,
      latitude: event.latitude,
      longitude: event.longitude,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      ticketPrice: event.ticketPrice,
    );

    await docRef.set(model.toMap());
  }

  @override
  Future<List<EventModel>> getApprovedEvents() async {
    final query = await firebaseFirestore.collection('events').get();
    return query.docs.map((e) => EventModel.fromMap(e.data(), e.id)).toList();
  }

  @override
  Future<void> joinEvent(String eventId, String userId) async {
    final docRef = firebaseFirestore.collection('events_approved').doc(eventId);
    await docRef.update({
      'attendees': FieldValue.arrayUnion([userId]),
    });
  }
}
