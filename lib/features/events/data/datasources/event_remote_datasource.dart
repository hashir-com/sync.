import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

abstract class EventRemoteDataSource {
  Future<List<Map<String, dynamic>>> getEvents();
  Future<Map<String, dynamic>> getEventById(String eventId);
  Future<String> createEvent(Map<String, dynamic> eventData);
  Future<void> updateEvent(String eventId, Map<String, dynamic> eventData);
  Future<void> deleteEvent(String eventId);
  Future<void> joinEvent(String eventId, String userId);
  Future<void> leaveEvent(String eventId, String userId);
  Future<String> uploadEventImage(File imageFile, String eventId);
}

class EventRemoteDataSourceImpl implements EventRemoteDataSource {
  final FirebaseFirestore firebaseFirestore;
  final FirebaseStorage firebaseStorage;

  EventRemoteDataSourceImpl({
    required this.firebaseFirestore,
    required this.firebaseStorage,
  });

  @override
  Future<List<Map<String, dynamic>>> getEvents() async {
    final querySnapshot = await firebaseFirestore
        .collection('events')
        .orderBy('startTime', descending: false)
        .get();

    return querySnapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data()})
        .toList();
  }

  @override
  Future<Map<String, dynamic>> getEventById(String eventId) async {
    final doc = await firebaseFirestore.collection('events').doc(eventId).get();
    if (doc.exists) {
      return {'id': doc.id, ...doc.data()!};
    } else {
      throw Exception('Event not found');
    }
  }

  @override
  Future<String> createEvent(Map<String, dynamic> eventData) async {
    final docRef = await firebaseFirestore.collection('events').add({
      ...eventData,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  @override
  Future<void> updateEvent(
    String eventId,
    Map<String, dynamic> eventData,
  ) async {
    await firebaseFirestore.collection('events').doc(eventId).update({
      ...eventData,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    await firebaseFirestore.collection('events').doc(eventId).delete();
  }

  @override
  Future<void> joinEvent(String eventId, String userId) async {
    await firebaseFirestore.collection('events').doc(eventId).update({
      'attendees': FieldValue.arrayUnion([userId]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> leaveEvent(String eventId, String userId) async {
    await firebaseFirestore.collection('events').doc(eventId).update({
      'attendees': FieldValue.arrayRemove([userId]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<String> uploadEventImage(File imageFile, String eventId) async {
    final ref = firebaseStorage.ref().child('events/$eventId/image.jpg');
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }
}
