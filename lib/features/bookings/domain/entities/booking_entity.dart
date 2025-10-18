import 'package:equatable/equatable.dart';

// lib/features/bookings/domain/entities/booking_entity.dart
class BookingEntity extends Equatable {
  final String id;
  final String userId;
  final String eventId;
  final String ticketType;
  final int ticketQuantity;
  final double totalAmount;
  final String paymentId;
  final List<int> seatNumbers; // NEW
  final String status;
  final DateTime bookingDate;
  final DateTime? cancellationDate;
  final double? refundAmount;
  final DateTime startTime;
  final DateTime endTime;
  final String userEmail;

  const BookingEntity({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.ticketType,
    required this.ticketQuantity,
    required this.totalAmount,
    required this.paymentId,
    required this.seatNumbers, // NEW
    this.status = 'confirmed',
    required this.bookingDate,
    this.cancellationDate,
    this.refundAmount,
    required this.startTime,
    required this.endTime,
    required this.userEmail,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        eventId,
        ticketType,
        ticketQuantity,
        totalAmount,
        paymentId,
        seatNumbers, // NEW
        status,
        bookingDate,
        cancellationDate,
        refundAmount,
        startTime,
        endTime,
        userEmail
      ];
}