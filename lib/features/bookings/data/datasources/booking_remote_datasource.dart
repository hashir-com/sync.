import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sync_event/core/error/exceptions.dart';
import 'package:sync_event/features/bookings/data/models/booking_model.dart';
import 'package:sync_event/features/bookings/domain/entities/booking_entity.dart';

abstract class BookingRemoteDataSource {
  Future<BookingModel> bookTicket(BookingEntity booking);
  Future<void> cancelBooking(String bookingId, String paymentId, String eventId, int ticketQuantity);
  Future<void> refundToRazorpay(String paymentId, double amount);
  Future<void> requestRefund(String bookingId, String refundType);
  Future<void> updateBookingStatus(String bookingId, String status, double refundAmount);
  Future<BookingModel> getBooking(String bookingId);
  Future<List<BookingModel>> getUserBookings(String userId);
}

class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  BookingRemoteDataSourceImpl({required this.firestore, required this.auth});

  @override
  Future<BookingModel> bookTicket(BookingEntity booking) async {
    try {
      final userId = auth.currentUser?.uid;
      if (userId == null) throw ServerException(message: 'User not authenticated');
      if (booking.id.isEmpty) throw ServerException(message: 'Booking ID cannot be empty');
      if (booking.eventId.isEmpty) throw ServerException(message: 'Event ID cannot be empty');
      if (booking.userId != userId) {
        print('BookingRemoteDataSource: User ID mismatch - input=${booking.userId}, auth=$userId');
      }

      print('BookingRemoteDataSource: Fetching event with id=${booking.eventId}');
      final eventDoc = await firestore.collection('events').doc(booking.eventId).get();
      if (!eventDoc.exists) throw ServerException(message: 'Event not found');
      final eventData = eventDoc.data()!;
      final availableTickets = (eventData['availableTickets'] as num?)?.toInt() ?? 0;
      print('BookingRemoteDataSource: Event availableTickets=$availableTickets, requested=${booking.ticketQuantity}');
      if (availableTickets < booking.ticketQuantity) {
        throw ServerException(message: 'Not enough tickets available');
      }

      final bookingMap = {
        'id': booking.id,
        'userId': userId,
        'eventId': booking.eventId,
        'ticketType': booking.ticketType,
        'ticketQuantity': booking.ticketQuantity,
        'totalAmount': booking.totalAmount,
        'paymentId': booking.paymentId,
        'seatNumbers': booking.seatNumbers,
        'status': booking.status ?? 'confirmed',
        'bookingDate': Timestamp.fromDate(booking.bookingDate),
        'startTime': Timestamp.fromDate(booking.startTime),
        'endTime': Timestamp.fromDate(booking.endTime),
        'userEmail': booking.userEmail ?? auth.currentUser?.email ?? '',
      };

      print('BookingRemoteDataSource: Saving booking with id=${booking.id}, userId=$userId, map=$bookingMap');
      await firestore.collection('bookings').doc(booking.id).set(bookingMap);
      print('BookingRemoteDataSource: Booking saved successfully');

      print('BookingRemoteDataSource: Updating event with id=${booking.eventId}, userId=$userId');
      await firestore.collection('events').doc(booking.eventId).update({
        'availableTickets': FieldValue.increment(-booking.ticketQuantity),
        'attendees': FieldValue.arrayUnion([userId]),
      });
      print('BookingRemoteDataSource: Event updated successfully');

      return BookingModel.fromJson(bookingMap, booking.id);
    } catch (e) {
      print('BookingRemoteDataSource: Error - $e');
      throw ServerException(message: 'Failed to book ticket: $e');
    }
  }

  @override
  Future<void> cancelBooking(String bookingId, String paymentId, String eventId, int ticketQuantity) async {
    try {
      if (bookingId.isEmpty) throw ServerException(message: 'Booking ID cannot be empty');
      if (paymentId.isEmpty) throw ServerException(message: 'Payment ID cannot be empty');
      if (eventId.isEmpty) throw ServerException(message: 'Event ID cannot be empty');
      if (ticketQuantity <= 0) throw ServerException(message: 'Ticket quantity must be positive');

      print('BookingRemoteDataSource: Cancelling booking with id=$bookingId');
      await firestore.collection('bookings').doc(bookingId).update({
        'status': 'cancelled',
        'cancellationDate': FieldValue.serverTimestamp(),
      });

      print('BookingRemoteDataSource: Updating event with id=$eventId, ticketQuantity=$ticketQuantity');
      await firestore.collection('events').doc(eventId).update({
        'availableTickets': FieldValue.increment(ticketQuantity),
      });
    } catch (e) {
      print('BookingRemoteDataSource: Error - $e');
      throw ServerException(message: 'Failed to cancel booking: $e');
    }
  }

  @override
  Future<void> refundToRazorpay(String paymentId, double amount) async {
    try {
      if (paymentId.isEmpty) throw ServerException(message: 'Payment ID cannot be empty');
      print('BookingRemoteDataSource: Processing Razorpay refund for paymentId=$paymentId, amount=$amount');
    } catch (e) {
      throw ServerException(message: 'Failed to process Razorpay refund: $e');
    }
  }

  @override
  Future<void> requestRefund(String bookingId, String refundType) async {
    try {
      if (bookingId.isEmpty) throw ServerException(message: 'Booking ID cannot be empty');
      if (refundType.isEmpty) throw ServerException(message: 'Refund type cannot be empty');

      print('BookingRemoteDataSource: Requesting refund for bookingId=$bookingId, refundType=$refundType');
      await firestore.collection('bookings').doc(bookingId).update({
        'refundType': refundType,
        'refundRequestedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('BookingRemoteDataSource: Error - $e');
      throw ServerException(message: 'Failed to request refund: $e');
    }
  }

  @override
  Future<void> updateBookingStatus(String bookingId, String status, double refundAmount) async {
    try {
      if (bookingId.isEmpty) throw ServerException(message: 'Booking ID cannot be empty');

      print('BookingRemoteDataSource: Updating booking status for id=$bookingId, status=$status');
      await firestore.collection('bookings').doc(bookingId).update({
        'status': status,
        'refundAmount': refundAmount,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('BookingRemoteDataSource: Error - $e');
      throw ServerException(message: 'Failed to update booking status: $e');
    }
  }

  @override
  Future<BookingModel> getBooking(String bookingId) async {
    try {
      if (bookingId.isEmpty) throw ServerException(message: 'Booking ID cannot be empty');

      print('BookingRemoteDataSource: Fetching booking with id=$bookingId');
      final doc = await firestore.collection('bookings').doc(bookingId).get();
      if (!doc.exists) throw ServerException(message: 'Booking not found');
      return BookingModel.fromJson(doc.data()!, doc.id);
    } catch (e) {
      print('BookingRemoteDataSource: Error - $e');
      throw ServerException(message: 'Failed to get booking: $e');
    }
  }

  @override
  Future<List<BookingModel>> getUserBookings(String userId) async {
    try {
      final authUserId = auth.currentUser?.uid;
      if (authUserId == null) throw ServerException(message: 'User not authenticated');
      if (userId != authUserId) {
        print('BookingRemoteDataSource: User ID mismatch - input=$userId, auth=$authUserId');
      }

      print('BookingRemoteDataSource: Fetching bookings for userId=$authUserId');
      final querySnapshot = await firestore
          .collection('bookings')
          .where('userId', isEqualTo: authUserId)
          .get();
      return querySnapshot.docs
          .map((doc) => BookingModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('BookingRemoteDataSource: Error - $e');
      throw ServerException(message: 'Failed to get user bookings: $e');
    }
  }
}