import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sync_event/features/bookings/data/models/booking_model.dart';
import 'package:sync_event/features/events/domain/entities/event_entity.dart';

abstract class BookingRemoteDataSource {
  Future<BookingModel> bookTicket(BookingModel booking);
  Future<void> cancelBooking(String bookingId);
  Future<void> refundToRazorpay(String paymentId, double amount);
  Future<List<BookingModel>> getUserBookings(String userId);
  Future<BookingModel> getBooking(String bookingId);
  Future<EventEntity> getEvent(String eventId);
}

class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final FirebaseFirestore firestore;
  final String razorpayKey =
      'rzp_test_1DP5mmOlF5G5ag'; // Replace with your Razorpay test key
  final String razorpaySecret =
      'your_secret'; // Replace with your Razorpay secret

  BookingRemoteDataSourceImpl({required this.firestore});

  @override
  Future<BookingModel> bookTicket(BookingModel booking) async {
    final docRef = await firestore.collection('bookings').add(booking.toJson());
    final updatedBooking = booking.copyWith(id: docRef.id);
    // Update event capacity
    final eventRef = firestore.collection('events').doc(booking.eventId);
    await firestore.runTransaction((transaction) async {
      final eventSnap = await transaction.get(eventRef);
      if (!eventSnap.exists) throw Exception('Event not found');
      final eventData = eventSnap.data()!;
      final updatedCapacities = Map<String, int>.from(
        eventData['categoryCapacities'] ?? {},
      );
      if (updatedCapacities[booking.ticketType]! >= booking.ticketQuantity) {
        updatedCapacities[booking.ticketType] =
            updatedCapacities[booking.ticketType]! - booking.ticketQuantity;
        transaction.update(eventRef, {'categoryCapacities': updatedCapacities});
      } else {
        throw Exception('Not enough tickets available');
      }
    });
    return updatedBooking;
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    final bookingRef = firestore.collection('bookings').doc(bookingId);
    await firestore.runTransaction((transaction) async {
      final bookingSnap = await transaction.get(bookingRef);
      if (!bookingSnap.exists) throw Exception('Booking not found');
      final bookingData = bookingSnap.data()!;
      transaction.update(bookingRef, {
        'status': 'cancelled',
        'cancellationDate': FieldValue.serverTimestamp(),
      });
      // Restore event capacity
      final eventRef = firestore
          .collection('events')
          .doc(bookingData['eventId']);
      final eventSnap = await transaction.get(eventRef);
      if (eventSnap.exists) {
        final eventData = eventSnap.data()!;
        final updatedCapacities = Map<String, int>.from(
          eventData['categoryCapacities'] ?? {},
        );
        updatedCapacities[bookingData['ticketType']] =
            updatedCapacities[bookingData['ticketType']]! +
            (bookingData['ticketQuantity'] as num).toInt(); // Cast to int
        transaction.update(eventRef, {'categoryCapacities': updatedCapacities});
      }
    });
  }

  @override
  Future<void> refundToRazorpay(String paymentId, double amount) async {
    final response = await http.post(
      Uri.parse('https://api.razorpay.com/v1/payments/$paymentId/refund'),
      headers: {
        'Authorization':
            'Basic ${base64Encode(utf8.encode('$razorpayKey:$razorpaySecret'))}',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'amount': (amount * 100).toInt(),
        'notes': {'reason': 'Event cancellation'},
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Refund failed: ${response.body}');
    }
  }

  @override
  Future<List<BookingModel>> getUserBookings(String userId) async {
    final snapshot = await firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .get();
    return snapshot.docs
        .map((doc) => BookingModel.fromJson(doc.data()..['id'] = doc.id))
        .toList();
  }

  @override
  Future<BookingModel> getBooking(String bookingId) async {
    final doc = await firestore.collection('bookings').doc(bookingId).get();
    if (doc.exists) {
      return BookingModel.fromJson(doc.data()!..['id'] = doc.id);
    }
    throw Exception('Booking not found');
  }

  @override
  Future<EventEntity> getEvent(String eventId) async {
    final doc = await firestore.collection('events').doc(eventId).get();
    if (doc.exists) {
      return EventEntity.fromJson(doc.data()!..['id'] = doc.id);
    }
    throw Exception('Event not found');
  }
}
