// lib/features/bookings/data/datasources/booking_remote_data_source.dart
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
  Future<void> requestRefund(String bookingId, String refundType);
}

class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final FirebaseFirestore firestore;
  final String razorpayKey = 'rzp_test_RU0yq41o7lOiIN';
  final String razorpaySecret = 'Oc9zrPqN7ag3530N4f0QC9lc';

  BookingRemoteDataSourceImpl({required this.firestore});

  @override
  Future<BookingModel> bookTicket(BookingModel booking) async {
    try {
      final eventRef = firestore.collection('events').doc(booking.eventId);
      final bookingsCol = firestore.collection('bookings');

      late BookingModel result;

      await firestore.runTransaction((transaction) async {
        final eventSnap = await transaction.get(eventRef);
        if (!eventSnap.exists) {
          throw Exception('Event not found: ${booking.eventId}');
        }

        final eventData = eventSnap.data()! as Map<String, dynamic>;
        if (!eventData.containsKey('categoryCapacities') ||
            !eventData.containsKey('takenSeats')) {
          throw Exception('Event missing required fields');
        }

        final capacities = Map<String, int>.from(eventData['categoryCapacities']);
        final takenSeats = List<int>.from(eventData['takenSeats'] ?? []);

        if (!capacities.containsKey(booking.ticketType)) {
          throw Exception('Invalid ticket type: ${booking.ticketType}');
        }

        final available = capacities[booking.ticketType] ?? 0;
        if (available < booking.ticketQuantity) {
          throw Exception('Not enough tickets available');
        }

        final newSeats = _allocateSeatNumbers(
          takenSeats: takenSeats,
          quantity: booking.ticketQuantity,
          maxSeats: capacities[booking.ticketType]!,
        );

        final docRef = bookingsCol.doc();
        final bookingJson = {
          'userId': booking.userId,
          'eventId': booking.eventId,
          'ticketType': booking.ticketType,
          'ticketQuantity': booking.ticketQuantity,
          'totalAmount': booking.totalAmount,
          'paymentId': booking.paymentId,
          'status': 'confirmed',
          'seatNumbers': newSeats,
          'bookingDate': FieldValue.serverTimestamp(),
          'startTime': booking.startTime is! Timestamp
              ? Timestamp.fromDate(booking.startTime)
              : booking.startTime,
          'endTime': booking.endTime is! Timestamp
              ? Timestamp.fromDate(booking.endTime)
              : booking.endTime,
          'userEmail': booking.userEmail,
        };

        transaction.set(docRef, bookingJson);
        transaction.update(eventRef, {
          'categoryCapacities': {
            ...capacities,
            booking.ticketType: available - booking.ticketQuantity,
          },
          'takenSeats': FieldValue.arrayUnion(newSeats),
        });

        result = booking.copyWith(
          id: docRef.id,
          seatNumbers: newSeats,
          status: 'confirmed',
          bookingDate: DateTime.now(),
        );
      });

      return result;
    } catch (e, stackTrace) {
      print('✗ BOOKING FAILED: $e\n$stackTrace');
      throw Exception('Failed to book ticket: $e');
    }
  }

  List<int> _allocateSeatNumbers({
    required List<int> takenSeats,
    required int quantity,
    required int maxSeats,
  }) {
    final availableSeats = List.generate(
      maxSeats,
      (index) => index + 1,
    ).where((seat) => !takenSeats.contains(seat)).toList();

    if (availableSeats.length < quantity) {
      throw Exception('Not enough seats available');
    }

    return availableSeats.take(quantity).toList();
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    try {
      final bookingRef = firestore.collection('bookings').doc(bookingId);

      final bookingSnap = await bookingRef.get();
      if (!bookingSnap.exists) throw Exception('Booking not found: $bookingId');

      final bookingData = bookingSnap.data()!;

      await bookingRef.update({
        'status': 'cancelled',
        'cancellationDate': FieldValue.serverTimestamp(),
      });

      // Restore event capacity and seats
      final eventRef = firestore
          .collection('events')
          .doc(bookingData['eventId']);
      final eventSnap = await eventRef.get();
      if (eventSnap.exists) {
        final eventData = eventSnap.data()!;
        final capacities = Map<String, int>.from(
          eventData['categoryCapacities'] ?? {},
        );
        final takenSeats = List<int>.from(eventData['takenSeats'] ?? []);
        final type = bookingData['ticketType'] as String;
        final qty = (bookingData['ticketQuantity'] as num).toInt();
        final seats = List<int>.from(bookingData['seatNumbers'] ?? []);

        capacities[type] = (capacities[type] ?? 0) + qty;
        await eventRef.update({
          'categoryCapacities': capacities,
          'takenSeats': FieldValue.arrayRemove(seats),
        });
      }
      print('✓ Booking cancelled: $bookingId');
    } catch (e, stackTrace) {
      print('✗ Cancellation failed: $e\n$stackTrace');
      throw Exception('Failed to cancel booking: $e');
    }
  }

  @override
  Future<void> refundToRazorpay(String paymentId, double amount) async {
    try {
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
      print('✓ Refund processed: $paymentId');
    } catch (e, stackTrace) {
      print('✗ Refund failed: $e\n$stackTrace');
      throw Exception('Failed to process refund: $e');
    }
  }

  @override
  Future<List<BookingModel>> getUserBookings(String userId) async {
    try {
      print('DEBUG: Starting getUserBookings for userId: $userId');

      final snapshot = await firestore
          .collection('bookings')
          .where('userId', isEqualTo: userId)
          .get();

      print('DEBUG: Query returned ${snapshot.docs.length} documents');

      final bookings = snapshot.docs.map((doc) {
        print('DEBUG: Processing booking doc: ${doc.id}, data: ${doc.data()}');
        return BookingModel.fromJson(doc.data()..['id'] = doc.id);
      }).toList();

      print('✓ Fetched ${bookings.length} bookings for user: $userId');
      return bookings;
    } catch (e, stackTrace) {
      print('✗ Failed to fetch bookings: $e\n$stackTrace');
      return [];
    }
  }

  @override
  Future<BookingModel> getBooking(String bookingId) async {
    try {
      final doc = await firestore.collection('bookings').doc(bookingId).get();
      if (doc.exists) {
        return BookingModel.fromJson(doc.data()!..['id'] = doc.id);
      } else {
        throw Exception('Booking not found: $bookingId');
      }
    } catch (e, stackTrace) {
      print('✗ Failed to fetch booking: $e\n$stackTrace');
      throw Exception('Failed to fetch booking: $e');
    }
  }

  @override
  Future<EventEntity> getEvent(String eventId) async {
    try {
      final doc = await firestore.collection('events').doc(eventId).get();
      if (doc.exists) {
        return EventEntity.fromJson(doc.data()!..['id'] = doc.id);
      } else {
        throw Exception('Event not found: $eventId');
      }
    } catch (e, stackTrace) {
      print('✗ Failed to fetch event: $e\n$stackTrace');
      throw Exception('Failed to fetch event: $e');
    }
  }

  @override
  Future<void> requestRefund(String bookingId, String refundType) async {
    try {
      final requestRef = firestore.collection('refundRequests').doc();
      await requestRef.set({
        'bookingId': bookingId,
        'refundType': refundType, // 'wallet' or 'bank'
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e, stackTrace) {
      print('✗ Failed to create refund request: $e\n$stackTrace');
      throw Exception('Failed to request refund: $e');
    }
  }
}
