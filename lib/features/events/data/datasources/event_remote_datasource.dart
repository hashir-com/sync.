
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sync_event/features/events/data/models/event_model.dart';

abstract class EventRemoteDataSource {
  Future<void> createEvent(EventModel event, {File? docFile, File? coverFile});
  Future<List<EventModel>> getApprovedEvents();
  Stream<List<EventModel>> getApprovedEventsStream();
  Future<void> joinEvent(String eventId, String userId);
  Stream<List<EventModel>> getUserEventsStream(String userId);
  Future<void> updateEvent(EventModel event, {File? docFile, File? coverFile});
  Future<void> deleteEvent(String eventId);
  Future<void> updateEventAvailability(String eventId, int ticketQuantity);
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
    String? docUrl;
    String? imageUrl;

    if (docFile != null) {
      final docSnapshot = await firebaseStorage
          .ref('event_docs/${docRef.id}/document.pdf')
          .putFile(docFile);
      docUrl = await docSnapshot.ref.getDownloadURL();
      print('EventRemoteDataSourceImpl: Uploaded doc for event ${docRef.id}');
    }

    if (coverFile != null) {
      final imgSnapshot = await firebaseStorage
          .ref('event_covers/${docRef.id}/cover.jpg')
          .putFile(coverFile);
      imageUrl = await imgSnapshot.ref.getDownloadURL();
      print('EventRemoteDataSourceImpl: Uploaded image for event ${docRef.id}, url=$imageUrl');
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
      status: event.status,
      categoryCapacities: event.categoryCapacities,
      categoryPrices: event.categoryPrices,
      approvalReason: event.approvalReason,
      rejectionReason: event.rejectionReason,
      availableTickets: event.maxAttendees, // Initialize to maxAttendees
    );

    await docRef.set(model.toMap());
    print('EventRemoteDataSourceImpl: Created event ${docRef.id} with status=${event.status}');
  }

  @override
  Stream<List<EventModel>> getApprovedEventsStream() {
    print('EventRemoteDataSourceImpl: Starting approved events stream');
    return firebaseFirestore
        .collection('events')
        .where('status', isEqualTo: 'approved')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          final events = snapshot.docs.map((doc) {
            final data = doc.data();
            print('EventRemoteDataSourceImpl: Fetched event ${doc.id}: lat=${data['latitude']}, lng=${data['longitude']}, status=${data['status']}, imageUrl=${data['imageUrl']}');
            return EventModel.fromMap(data, doc.id);
          }).toList();
          print('EventRemoteDataSourceImpl: Fetched ${events.length} approved events');
          return events;
        });
  }

  @override
  Future<List<EventModel>> getApprovedEvents() async {
    final query = await firebaseFirestore
        .collection('events')
        .where('status', isEqualTo: 'approved')
        .get();
    return query.docs.map((e) => EventModel.fromMap(e.data(), e.id)).toList();
  }

  @override
  Future<void> joinEvent(String eventId, String userId) async {
    final docRef = firebaseFirestore.collection('events').doc(eventId);
    await docRef.update({
      'attendees': FieldValue.arrayUnion([userId]),
    });
  }

  @override
  Stream<List<EventModel>> getUserEventsStream(String userId) {
    return firebaseFirestore
        .collection('events')
        .where('organizerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => EventModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  @override
  Future<void> updateEvent(
    EventModel event, {
    File? docFile,
    File? coverFile,
  }) async {
    String? docUrl = event.documentUrl;
    String? imageUrl = event.imageUrl;

    if (docFile != null) {
      if (event.documentUrl != null) {
        try {
          await firebaseStorage.refFromURL(event.documentUrl!).delete();
        } catch (e) {
          // Ignore if file doesn't exist
        }
      }
      final docSnapshot = await firebaseStorage
          .ref('event_docs/${event.id}/document.pdf')
          .putFile(docFile);
      docUrl = await docSnapshot.ref.getDownloadURL();
    }

    if (coverFile != null) {
      if (event.imageUrl != null) {
        try {
          await firebaseStorage.refFromURL(event.imageUrl!).delete();
        } catch (e) {
          // Ignore if file doesn't exist
        }
      }
      final imgSnapshot = await firebaseStorage
          .ref('event_covers/${event.id}/cover.jpg')
          .putFile(coverFile);
      imageUrl = await imgSnapshot.ref.getDownloadURL();
    }

    final updatedEvent = EventModel(
      id: event.id,
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
      createdAt: event.createdAt,
      updatedAt: DateTime.now(),
      ticketPrice: event.ticketPrice,
      status: event.status,
      categoryCapacities: event.categoryCapacities,
      categoryPrices: event.categoryPrices,
      approvalReason: event.approvalReason,
      rejectionReason: event.rejectionReason,
      availableTickets: event.availableTickets,
    );

    await firebaseFirestore
        .collection('events')
        .doc(event.id)
        .update(updatedEvent.toMap());
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    final eventDoc = await firebaseFirestore.collection('events').doc(eventId).get();

    if (eventDoc.exists) {
      final eventData = eventDoc.data();
      if (eventData?['imageUrl'] != null) {
        try {
          await firebaseStorage.refFromURL(eventData!['imageUrl']).delete();
        } catch (e) {
          // Ignore if file doesn't exist
        }
      }
      if (eventData?['documentUrl'] != null) {
        try {
          await firebaseStorage.refFromURL(eventData!['documentUrl']).delete();
        } catch (e) {
          // Ignore if file doesn't exist
        }
      }
    }

    await firebaseFirestore.collection('events').doc(eventId).delete();
  }

  @override
  Future<void> updateEventAvailability(String eventId, int ticketQuantity) async {
    try {
      await firebaseFirestore.collection('events').doc(eventId).update({
        'availableTickets': FieldValue.increment(ticketQuantity),
      });
    } catch (e) {
      throw Exception('Failed to update event availability: $e');
    }
  }
}
